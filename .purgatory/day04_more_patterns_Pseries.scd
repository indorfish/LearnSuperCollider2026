/* DAY 02: PATTERNS
	STARS OF THE SHOW: Pbind, Pseries
*/

s.boot;


// Pseries. Plays do re mi for some reason. Won't stop.
(
var repeats = 1;
a = Pbind(\degree, Pseries([1], repeats),
		  \amp, 1.0
).play;
)


// Pseries: major chord, forever ascending. Amplitude scaled down to avoid clipping
(
var repeats = 1;
b = Pbind(\degree, Pseries([1,3,5], repeats),
		  \amp, 0.3
).trace.play;
)


/* Pseries: major chord. Now, we clarify the arguments.
Pseries generates a stream that is like an AP. Its args are (start, stop, step)
which are 0, 1 and inf by default. The repetitions from before are due to length being inf.
The start is the start value, which may be a chord, and step is the step size.
*/
(
var count = 8;
var step = 2;
c = Pbind(\degree, Pseries([1,3,5], step, count),
		  \amp, 0.3
).trace.play;
)


// For complexity, play two patterns simulatneously
(
var count = 8;
var step = 2;
e = Pbind(\degree, Pseries([1,5], step, count),
		  \amp, 0.25
).play;
f = Pbind(\degree, Pseries(start:2, step:1, length:2*count),
		  \amp, 0.45,
		  \dur, 0.5
).play;
)


// A preview of Pgeom which generates a geometric sequence
(
var count = 8;
var step = 2;
c = Pbind(\degree, Pgeom([1,3,5], step, count/2),
		  \amp, 0.3
).trace.play;
)

/*
	ACTUALLY...
    Pseries does not generate a mathematical series i.e. sum. THis is what confused me.
    What it generates is technically an arithmetic sequence, but Pseq already exists so calling
	this Pseq would be confusing.
    Pseq also generates a sequence, but that sequence is arbitrary as specified by the user.
	Pseries in contrast specifically generates an arithmetic sequence.
*/

// OTHERS: Pshuf, Pser, Pslide,
// More parameters for Pbind - strum,scale,ctranspose,

s.quit;