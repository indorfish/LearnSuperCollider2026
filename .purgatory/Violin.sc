// Violin.sc
// An abstract violin: the MODEL enforces what a violinist's body can do,
// the CONTROLLER is a text command language, and the VIEW (renderer backend)
// is swappable (synthesis, physical model, samples...).
//
// Install: copy into Platform.userExtensionDir, then recompile the class library.

Violin {
	classvar <stringMidi, <maxOffset, <bowLength = 0.65;
	classvar <articulations, <dynamics, <contacts, <vibratos, <backends;

	var <>server, <>out, <>tempo = 60, <>mode = \adaptive, <>backend = \saw;
	var <timeline, <beat = 0, <warnings;
	var dynamicLevel, contactName, vibratoName;
	var curString, curOffset, lastFreq, lastStrings, lastBowed, lastDir, bowPos, retakeFree;

	*initClass {
		stringMidi = [55, 62, 69, 76];     // G3 D4 A4 E5
		maxOffset  = [28, 26, 24, 24];     // semitones above the open string

		// bow speeds in m/s
		dynamics = (pp: 0.08, p: 0.14, mp: 0.2, mf: 0.3, f: 0.42, ff: 0.55);
		// bow contact point as fraction of string length from the bridge
		contacts = (tasto: 0.2, normal: 0.1, ponticello: 0.04);
		vibratos = (none: 0, light: 0.004, normal: 0.008, wide: 0.014);

		// sustain = fraction of notated duration that sounds
		// use     = how much bow length the stroke consumes (relative)
		articulations = (
			detache:  (kind: \arco, sustain: 0.92, attack: 0.05,  release: 0.15, force: 0.45, speedMul: 1.0, use: 1.0, slur: false),
			legato:   (kind: \arco, sustain: 1.0,  attack: 0.09,  release: 0.25, force: 0.40, speedMul: 0.9, use: 1.0, slur: true),
			martele:  (kind: \arco, sustain: 0.7,  attack: 0.012, release: 0.08, force: 0.85, speedMul: 1.3, use: 0.7, slur: false),
			staccato: (kind: \arco, sustain: 0.4,  attack: 0.02,  release: 0.06, force: 0.6,  speedMul: 1.1, use: 0.6, slur: false),
			spiccato: (kind: \arco, sustain: 0.15, attack: 0.006, release: 0.05, force: 0.7,  speedMul: 1.2, use: 0.2, slur: false),
			pizz:     (kind: \pizz, sustain: 1.0,  attack: 0,     release: 0,    force: 0.5,  speedMul: 1.2, use: 0,   slur: false)
		);

		// Backends are just events with a \note function: (g, server, out, clock) -> synths.
		// Add your own (e.g. samples) with Violin.backends[\mine] = (note: { |g, server, out, clock| ... });
		backends = (
			saw:      this.synthBackend(\violinSaw, \violinPizz),
			additive: this.synthBackend(\violinAdd, \violinPizz)
		);
	}

	// ---------------------------------------------------------------- note helpers

	*midi { |n|
		var s, base, acc = 0, i = 1, oct;
		if(n.isNumber) { ^n };
		s = n.asString;
		base = Dictionary[$C -> 0, $D -> 2, $E -> 4, $F -> 5, $G -> 7, $A -> 9, $B -> 11][s[0].toUpper];
		if(base.isNil) { Error("Violin: can't parse note " ++ s).throw };
		while { (i < s.size) and: { "#sb".includes(s[i]) } } {
			acc = acc + (if(s[i] == $b) { -1 } { 1 });
			i = i + 1;
		};
		oct = s.copyToEnd(i).asInteger;
		^((oct + 1) * 12) + base + acc
	}

	*noteName { |midi|
		var names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
		var m = midi.round.asInteger;
		^names[m % 12] ++ (m.div(12) - 1)
	}

	// every (string, finger offset) pair that can produce this pitch
	*fingerings { |midi|
		var res = List.new;
		stringMidi.do { |open, s|
			var off = midi - open;
			if((off >= 0) and: { off <= maxOffset[s] }) {
				res.add((string: s, offset: off, midi: midi));
			};
		};
		^res.asArray
	}

	// ---------------------------------------------------------------- construction / state

	*new { |backend = \saw, server|
		^super.new.init(backend, server ? Server.default)
	}

	init { |bk, srv|
		backend = bk;
		server = srv;
		out = 0;
		this.reset;
	}

	reset {
		timeline = List.new;
		warnings = List.new;
		beat = 0;
		dynamicLevel = \mf;
		contactName = \normal;
		vibratoName = \normal;
		curString = nil; curOffset = 0;
		lastFreq = nil; lastStrings = nil;
		lastBowed = false; lastDir = -1; bowPos = 0; retakeFree = true;
		^this
	}

	// the "violin.set(...)" part of the controller
	set { |key, val|
		switch(key,
			\dynamic, {
				if(dynamics[val].isNil) { Error("Violin: unknown dynamic " ++ val).throw };
				dynamicLevel = val;
			},
			\contact, {
				if(contacts[val].isNil) { Error("Violin: unknown contact point " ++ val).throw };
				contactName = val;
			},
			\vibrato, {
				if(vibratos[val].isNil) { Error("Violin: unknown vibrato " ++ val).throw };
				vibratoName = val;
			},
			\tempo, { tempo = val },
			\mode, { mode = val },
			\backend, { backend = val },
			{ Error("Violin: unknown setting " ++ key).throw }
		);
		^this
	}

	// ---------------------------------------------------------------- commands

	play { |note, dur = 1, art = \detache|
		^this.chord([note], dur, art)
	}

	rest { |dur = 1|
		beat = beat + dur;
		lastBowed = false;     // bow leaves the string...
		retakeFree = true;     // ...so repositioning it is free
		^this
	}

	chord { |notes, dur = 1, art = \detache|
		var midis, plan, start, t;
		if(articulations[art].isNil) { Error("Violin: unknown articulation " ++ art).throw };

		midis = notes.asArray.collect { |n| this.prFit(Violin.midi(n)) }.asSet.asArray.sort;
		if(midis.size > 4) {
			Error("Violin: only four strings, can't sound % notes".format(midis.size)).throw;
		};

		// 3-4 note chords can't be bowed at once: they are rolled
		plan = case
			{ midis.size <= 2 } { [[(0..(midis.size - 1)), 1]] }
			{ midis.size == 3 } { [[[0], 0.25], [[1, 2], 0.75]] }
			{ midis.size == 4 } { [[[0, 1], 0.3], [[2, 3], 0.7]] };

		start = beat;
		t = start;
		plan.do { |p, k|
			var group = p[0].collect { |i| midis[i] };
			var d = dur * p[1];
			var fing = this.prFinger(group);
			if(fing.isNil) {
				this.prProblem("% can't be fingered together; spreading as an arpeggio".format(
					group.collect { |m| Violin.noteName(m) }));
				group.do { |m, j|
					this.prEmit([this.prBest(m)], t + (d * j / group.size), d / group.size, art, (k > 0) or: { j > 0 });
				};
			} {
				this.prEmit(fing, t, d, art, k > 0);
			};
			t = t + d;
		};
		beat = start + dur;
		^this
	}

	// ---------------------------------------------------------------- playing the timeline

	go { |clock|
		var be = backends[backend], tl = timeline.copy, srv = server, o = out;
		if(be.isNil) { Error("Violin: unknown backend " ++ backend).throw };
		clock = clock ? TempoClock(tempo / 60);
		Routine {
			var last = 0;
			tl.do { |g|
				(g[\beat] - last).wait;
				last = g[\beat];
				be[\note].value(g, srv, o, clock);
			};
		}.play(clock);
		^clock
	}

	show {
		timeline.do { |g|
			var names = g[\midis].collect { |m| Violin.noteName(m) }.join("+");
			var strs = g[\strings].collect { |s| ["G", "D", "A", "E"][s] }.join("+");
			var fings = g[\offsets].collect { |o| if(o == 0) { "open" } { "+" ++ o } }.join(", ");
			var how = if(g[\kind] == \pizz) { "pizz" } {
				"% % bow, %m/s".format(g[\art], if(g[\dir] > 0) { "down" } { "up" }, g[\bowSpeed].round(0.01))
			};
			"beat %: %  string %  finger %  [%]".format(g[\beat].round(0.01), names, strs, fings, how).postln;
		};
		warnings.do { |w| ("  ! " ++ w).postln };
		^this
	}

	// ---------------------------------------------------------------- model internals

	prProblem { |msg|
		if(mode == \strict) {
			Error("Violin (strict): " ++ msg).throw;
		} {
			("Violin (adaptive): " ++ msg).postln;
			warnings.add(msg);
		};
	}

	// bring a pitch into the violin's range
	prFit { |midi|
		var m = midi;
		if(Violin.fingerings(m).isEmpty) {
			this.prProblem("% is outside the violin's range".format(Violin.noteName(m)));
			while { m < 55 } { m = m + 12 };
			while { m > 100 } { m = m - 12 };
		};
		^m
	}

	// heuristic difficulty of a fingering given where the hand is now
	prCost { |f|
		var c = (f[\offset] - 7).max(0) * 0.25;          // high positions are harder
		if(f[\offset] == 0) { c = c - 0.3 };             // open strings are convenient
		if(curString.notNil) {
			c = c + (if(f[\string] == curString) {
				(f[\offset] - curOffset).abs * 0.15      // shifting
			} {
				(f[\string] - curString).abs             // string crossing
			});
		};
		^c
	}

	prBest { |midi|
		^Violin.fingerings(midi).minItem { |f| this.prCost(f) }
	}

	// midis sorted ascending. Returns fingerings, or nil if physically impossible.
	prFinger { |midis|
		var best = nil, bestCost = inf;
		if(midis.size == 1) { ^[this.prBest(midis[0])] };

		// double stop: adjacent strings, reachable hand span
		(0..2).do { |s|
			var fa = Violin.fingerings(midis[0]).detect { |x| x[\string] == s };
			var fb = Violin.fingerings(midis[1]).detect { |x| x[\string] == s + 1 };
			var stopped, span, cost;
			if(fa.notNil and: { fb.notNil }) {
				stopped = [fa, fb].select { |x| x[\offset] > 0 }.collect { |x| x[\offset] };
				span = if(stopped.size > 1) { stopped.maxItem - stopped.minItem } { 0 };
				if(span <= 5) {
					cost = this.prCost(fa) + this.prCost(fb);
					if(cost < bestCost) { bestCost = cost; best = [fa, fb] };
				};
			};
		};
		^best
	}

	// the bow: finite length, alternating direction, slurs share one stroke
	prPlanBow { |speed, useSec, slur|
		var dir, frac, avail, held = slur and: { lastBowed };
		dir = if(held) { lastDir } { lastDir.neg };
		frac = speed * useSec / bowLength;
		avail = if(dir > 0) { 1 - bowPos } { bowPos };

		if(frac > avail) {
			if(held) {
				this.prProblem("slur broken: not enough bow left, changing direction");
				held = false;
				dir = dir.neg;
				avail = if(dir > 0) { 1 - bowPos } { bowPos };
			};
			if(frac > avail) {
				if(retakeFree.not) {
					this.prProblem("bow runs out mid-stroke: needs an (audible) retake");
				};
				bowPos = if(dir > 0) { 0 } { 1 };
				avail = 1;
			};
		};
		if(frac > 1) {
			this.prProblem("note needs more than a whole bow at this dynamic; playing it softer");
			speed = speed * 0.97 / frac;
			frac = 0.97;
		};
		bowPos = (bowPos + (dir * frac)).clip(0, 1);
		lastDir = dir;
		^[dir, speed, held]
	}

	// turn one playable group of fingerings into a gesture event on the timeline
	prEmit { |fing, startBeat, durBeats, artName, forceSlur = false|
		var spec = articulations[artName];
		var g = ();
		var top = fing.last;
		var freqs = fing.collect { |f| f[\midi].midicps };
		var sec = durBeats * 60 / tempo;
		var plan, semis;

		g[\beat] = startBeat;
		g[\dur] = durBeats;
		g[\sustain] = durBeats * spec[\sustain];
		g[\art] = artName;
		g[\kind] = spec[\kind];
		g[\midis] = fing.collect { |f| f[\midi] };
		g[\freqs] = freqs;
		g[\strings] = fing.collect { |f| f[\string] };
		g[\offsets] = fing.collect { |f| f[\offset] };
		g[\force] = spec[\force];
		g[\attack] = spec[\attack];
		g[\release] = spec[\release];
		g[\contact] = contacts[contactName];
		g[\vibDepth] = vibratos[vibratoName];

		if(spec[\kind] == \arco) {
			plan = this.prPlanBow(
				dynamics[dynamicLevel] * spec[\speedMul],
				sec * spec[\sustain] * spec[\use],
				spec[\slur] or: { forceSlur }
			);
			g[\dir] = plan[0];
			g[\bowSpeed] = plan[1];

			// slurred shift on the same string = audible portamento
			if(plan[2] and: { fing.size == 1 } and: { lastFreq.notNil } and: { lastStrings == [top[\string]] }
				and: { lastFreq != freqs[0] }) {
				semis = (freqs[0] / lastFreq).ratiomidi.abs;
				g[\glideFrom] = lastFreq;
				g[\glideTime] = (0.03 + (semis * 0.006)).clip(0.03, 0.25);
			};
			lastBowed = true;
			retakeFree = false;
		} {
			g[\bowSpeed] = dynamics[dynamicLevel] * spec[\speedMul];
			g[\dir] = 0;
			lastBowed = false;
		};

		timeline.add(g);
		curString = top[\string];
		curOffset = top[\offset];
		lastFreq = freqs.last;
		lastStrings = fing.collect { |f| f[\string] };
	}

	// ---------------------------------------------------------------- views (renderers)

	// gesture -> parameters shared by the synth backends
	*synthArgs { |g, i, out|
		var n = g[\freqs].size;
		var spd = g[\bowSpeed];
		var amp = ((spd / 0.6) * (0.1 / g[\contact]).sqrt * 0.35 / n.sqrt).clip(0.02, 0.6);
		var bright = ((0.5 + g[\force]) * (0.1 / g[\contact]).sqrt).clip(0.3, 3);
		var args = [
			\out, out, \freq, g[\freqs][i], \amp, amp,
			\pan, (g[\strings][i] - 1.5) * 0.25,
			\attack, g[\attack], \release, g[\release],
			\bright, bright, \bow, 0.02 + (g[\force] * 0.06),
			\vibDepth, g[\vibDepth]
		];
		if(g[\glideFrom].notNil) {
			args = args ++ [\glideFrom, g[\glideFrom], \glideTime, g[\glideTime]];
		};
		^args
	}

	*synthBackend { |arcoDef, pizzDef|
		^(
			note: { |g, server, out, clock|
				var syns = g[\freqs].collect { |fr, i|
					var args = Violin.synthArgs(g, i, out);
					if(g[\kind] == \pizz) {
						args = args.clump(2).select { |p| [\out, \freq, \amp, \pan].includes(p[0]) }.flatten;
					};
					Synth(if(g[\kind] == \pizz) { pizzDef } { arcoDef }, args, server)
				};
				if(g[\kind] == \arco) {
					clock.sched(g[\sustain], { syns.do { |s| s.set(\gate, 0) }; nil });
				};
				syns
			}
		)
	}

	*prepare {
		// View 1: detuned saws + body resonances
		SynthDef(\violinSaw, { |out = 0, freq = 440, glideFrom = 0, glideTime = 0.05, amp = 0.3, gate = 1, pan = 0,
			vibRate = 5.5, vibDepth = 0, vibDelay = 0.25, attack = 0.08, release = 0.25, bright = 1, bow = 0.05|
			var f0, vib, f, env, sig, noise, body;
			f0 = XLine.kr(Select.kr(glideFrom > 0, [freq, glideFrom]), freq, glideTime);
			vib = 1 + SinOsc.kr(vibRate + LFNoise1.kr(1, 0.3), 0, vibDepth * EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.5])));
			f = f0 * vib;
			env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
			sig = Saw.ar(f) + (Saw.ar(f * 1.004) * 0.6);
			noise = BPF.ar(PinkNoise.ar, f * 2, 0.5) * bow * 4;
			sig = sig + noise;
			sig = LPF.ar(sig, (f * 5 * bright).clip(300, 12000) * (0.4 + env));
			body = BPF.ar(sig, 280, 0.5) + (BPF.ar(sig, 450, 0.4) * 0.8)
				+ (BPF.ar(sig, 1200, 0.3) * 0.5) + (BPF.ar(sig, 2800, 0.3) * 0.4);
			sig = (sig * 0.3 + body) * env * amp;
			Out.ar(out, Pan2.ar(sig, pan));
		}).add;

		// View 2: additive, same interface, different sound
		SynthDef(\violinAdd, { |out = 0, freq = 440, glideFrom = 0, glideTime = 0.05, amp = 0.3, gate = 1, pan = 0,
			vibRate = 5.5, vibDepth = 0, vibDelay = 0.25, attack = 0.08, release = 0.25, bright = 1, bow = 0.05|
			var f0, vib, f, env, sig, k;
			f0 = XLine.kr(Select.kr(glideFrom > 0, [freq, glideFrom]), freq, glideTime);
			vib = 1 + SinOsc.kr(vibRate, 0, vibDepth * EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.5])));
			f = f0 * vib;
			env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
			k = 0.35 / bright.clip(0.3, 3);
			sig = Mix.fill(16, { |i|
				var n = i + 1;
				SinOsc.ar(f * n, 0, n.reciprocal * (n * k.neg).exp)
			});
			sig = LPF.ar(sig, 12000) + (HPF.ar(PinkNoise.ar, 2000) * bow * 0.2);
			sig = sig * env * amp * 0.8;
			Out.ar(out, Pan2.ar(sig, pan));
		}).add;

		// Plucked string (used by both backends for pizzicato)
		SynthDef(\violinPizz, { |out = 0, freq = 440, amp = 0.3, pan = 0, decay = 1.5|
			var sig = Pluck.ar(BrownNoise.ar(0.5), Impulse.kr(0), 0.05, freq.reciprocal, decay, 0.35);
			sig = sig + (BPF.ar(sig, 450, 0.4) * 0.5);
			DetectSilence.ar(sig, 0.0005, 0.2, doneAction: 2);
			Out.ar(out, Pan2.ar(sig * amp * 3, pan));
		}).add;

		SynthDef(\violinReverb, { |in = 0, out = 0, mix = 0.3, room = 0.8|
			var sig = In.ar(in, 2);
			Out.ar(out, FreeVerb2.ar(sig[0], sig[1], mix, room, 0.4));
		}).add;
	}
}
