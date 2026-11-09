/*
	THE GENERAL IDIOM FOR MAKING MUSIC IN SC
1. Boot up the server and configure its parameters
2. Define the instruments for making music - functions, ugens, synthdefs, etc.
3.Define the musical *program* i.e. the recipe for using the isntruments to actually make music. This step may be merged with the next.
This may often involve writing a "sequencer" and its sequence.
-Feed data to the sequencer. The data is where the score actually lives.
- Trigger it. Call the sequencer. This allocates and frees synth nodes over time.
*/


// SET-UP AUDIO SERVER AND BOOT IT
s.boot;

// DEFINE A SYNTHDEF OR FUNCTION
(
SynthDef(\fur,
	{
		arg out = 0, freq = 440, amp = 0.2, dur = 0.5;
		var env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
		var sig = SinOsc.ar(freq) * env * amp;
		Out.ar(out, sig);
	}
).add;
)

// play a single instant. The doneAction frees it I think
Synth(\fur, [\freq, 440, \amp, 0.3]);

// DEFINING A SCHEDULE FOR EVENTS VIA A FUNCTION
(
~beat = 0.4;
~playSeq = { |notes|
	var t = 0;
	notes.do {
		SystemClock.sched(t, {
			Synth(\fur, [\freq, n.midicps, \amp, 0.2, \dur, ~beat*0.9]);
			nil
		});
		t = t + ~beat;
	};
};
)


// PLAYING
~playSeq.([76, 75, 76, 75, 76, 71, 74, 72, 69]);