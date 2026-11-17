/*
REFACTORING WITH PATTERNS
- For this exercise, we will try to see how patterns make composition easier in SuperCollider.
SCD is a really complicated language and you only get good through repeated exposure and practice. You're encouraged to write code from scratch several times until the idea solidifies.
You're also encouraged to read code from others.
*/

s.reboot;

// define our synth - a basic sine pluck.
(
SynthDef(\pluck,
	{ |freq=540.0, amp=1.0, attack=0.01, release=1.0|
		var env, sig;
		env = EnvGen.kr(Env.perc(attackTime: attack,
								 releaseTime: release,
								 level: 1.0,
			                     curve: -4),
			             doneAction: Done.freeSelf);
		sig = SinOsc.ar(freq: freq, mul: amp);
		sig = env * sig;
		sig = Pan2.ar(sig, 0.0); 	// for full stereo
		Out.ar(0, sig);
	}
).add;

Synth(\pluck);
)

/*
LIST PATTERNS
Since we've already seen how to use arrays to define musical data in SCD, let's start by introducing List Patterns.
THE KEY PLAYER (no pun intended) is Pbind.
Pbind(\...).play gives you actual sound.
I believe the .play message schedules audio events on the audio server but we'll explore that in more technical detail later.

E5 (76) → D#5 (75) → E5 (76) → D#5 (75) → E5 (76) → B4 (71) → D5 (74) → C5 (72) → A4 (69).
*/


// testing Pbind. Press `Ctrl + .` to stop
// Pbind().play;

~notes = [76, 75, 76, 75, 76, 71, 74, 72, 69];
// Pbind needs Patterns in order to properly sequence musical events.
// The hwole Pattern architecture automatically converts midi to cps.

Pbind(\midinote, Pseq(~notes)).play;


// Let's play this with our actual instrument.
(
Pbind(\instrument, \pluck,
	\midinote, Pseq(~notes)
).play;
)


// Add some random variation to the notes and play via frequency
(
n = 4;
~perturbation = n*Array.rand(~notes.size, 0.0, 12.0);
)
(
Pbind(\instrument, \pluck,
	\freq, Pseq(~notes.midicps + ~perturbation)
).play;
)


// we can control other parameters of the instrument using additional Pseqs.
// duration, for example.
(
~beat = 1.0; // reference beat duration in seconds
~half = ~beat/2.0; ~qter = ~beat/4.0;
~eigt = ~beat/8.0; ~sixt = ~beat/16.0;
~timing = [~qter, ~qter, ~qter, ~qter,
	~qter, ~qter + ~sixt, ~qter + ~sixt,
	~qter+~sixt, ~qter+~half];
)
(
Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes),
	\dur, Pseq(~timing)
).play;
)


// is there a more elegant way to pack the musical event data?
// one approach is n-tuples of data e.g. [note,dur, etc]
// SuperCollider allows us to do this! We can bundle the values of musical parameters into a single "Event". This would be called a dictionary in Python.
(
~melody = [
    (midinote: 76, dur: ~qter),
    (midinote: 75, dur: ~qter),
    (midinote: 76, dur: ~qter),
    (midinote: 75, dur: ~qter),
    (midinote: 76, dur: ~qter),
    (midinote: 71, dur: ~qter + ~sixt),
    (midinote: 74, dur: ~qter + ~sixt),
    (midinote: 72, dur: ~qter + ~sixt),
    (midinote: 69, dur: ~qter + ~half)
];
)

// this can be played with just Pseq.
(
Pseq(~melody).play;
)

(
Pchain(
    Pbind(
        \instrument, \pluck,
        \amp, 0.2
    ),
    Pseq(~melody, 1)
).play;
)


/*
MORE INTERESTING PROPERTIES OF Pbind
- Lets us notate music in terms of scales and scale degrees.
*/

// The shortest Pattern sequence determines the overall length of the sequence
(
Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes, repeats:2),
	\dur, Pseq(~timing, repeats: 4)
).play;
)

// We can transpose without needing to rewrite the notes
(
Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes, repeats: 2),
	\dur, Pseq(~timing, repeats: 2),
	\ctranspose, 2
).play;
)

// We can sequence Pbinds!
(
var p1, p2, p3, p4, p5;
p1 = Pbind(
	\instrument, \default,
	\midinote, Pseq(~notes),
	\dur, Pseq(~timing)
);
p2 = Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes),
	\dur, Pseq(~timing),
	\ctranspose, 4
);
p3 = Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes),
	\dur, Pseq(~timing),
	\ctranspose, 2
);
p4 = Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes),
	\dur, Pseq(~timing),
	\ctranspose, 3
);
p3 = Pbind(
	\instrument, \pluck,
	\midinote, Pseq(~notes),
	\dur, Pseq(~timing),
	\ctranspose, 1
);

Pseq([p1, p2, p3, p4, p5]).play;
)



// FREE ALL
s.freeAll;

// GOODBYE
(
s.freeAll;
s.quit;
)
