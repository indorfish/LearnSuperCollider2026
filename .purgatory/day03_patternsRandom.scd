/* DAY 02: PATTERNS
	STARS OF THE SHOW: Pbind, Pseries
*/

s.boot;


/*
	Prand is a random variable. The argument is the sample space in list format.
		it's almost exactly like Pseq in syntax
*/
// s.record;
// s.stopRecording;
// s.makeWindow;

// Pseq pattern
(
var repeats = 6;
a = Pbind(\degree, Pseq([0,1,2,3,4,5], repeats),
		  \amp, Prand([0.4, 0.9], repeats),
		  \dur, Pseq([0.8, 1.6], repeats),
		  \legato, 1.8
).play;
)


// Prand pattern 1 - select between three notes (degree)
(
var repeats = 6;
b = Pbind(\degree, Prand([0,1,2,3,4,5], repeats),
		  \amp, Prand([0.4, 0.9], repeats),
		  \dur, Pseq([0.8, 1.6], repeats)
).play;
)


// Prand pattern 2 - a note is repeated to bias the distribution
(
var repeats = 6;
c = Pbind(\degree, Prand([0,1,3,3,3,5], repeats),
		  \amp, Prand([0.4, 0.9], repeats),
		  \dur, Pseq([0.8, 1.6], repeats)
).play;
)

// Preview of Pxrand. The x is for xclusive. Can you guess why? Listen carefully and compare with previous
(
var repeats = 6;
c = Pbind(\degree, Pxrand([0,1,3,3,3,5], repeats),
		  \amp, Prand([0.4, 0.9], repeats),
		  \dur, Pseq([0.8, 1.6], repeats)
).play;
)


/* Pwhite is a uniform random variable basically.
 Can work in integer mode or in floating point mode.
 Here, we use it to generate an integer frequency and also use trace.play
(in that order) to see the resulting values for debugging.
 Note how
*/
(
var repeats = 6;
d = Pbind(\freq, Pwhite(440, 444),
		  \amp, Pseq([0.7, 0.9], repeats),
		  \dur, Pseq([0.8, 1.6], repeats)
).trace.play;
)


/* This version of Pwhite is a *continuous* random variable
   Note the decimal point in the argument.
*/
(
var repeats = 6;
e = Pbind(\freq, Pwhite(440, 444.0),
		  \amp, Pseq([0.4, 0.9], repeats),
		  \dur, Pseq([0.8, 1.6], repeats)
).trace.play;
)


// Pick a random integer from 0 to 100 inclusive.
Pwhite(0, 100).postln;



s.quit;