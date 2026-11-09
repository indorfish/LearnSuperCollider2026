/* DAY 02: PATTERNS
	STARS OF THE SHOW: Pbind, Pseries
*/

s.boot;


/*
	Pseries is a stream that behaves like an arithmetic sequence
		arguments are start, stop and length. Useful for ramps.
		use 'inf' as length for infinite sequence

	Pbind aka Pattern-bind
*/
/*
	Pbind: degree is for the note number. 0 is middle C, go up or down.
    	dur means duration in seconds. Default is 1 second.
*/

a = Pbind(\degree, 10, \dur, 0.4).play;
//b.free; // Ctrl+.

x = Pseq([0,2,4,8,16,4], 3);
d = Pseq([0.5, 0.5, 0.6, 0.8, 1.2, 1.5], inf);
a = Pbind(\note, x, \dur, d).play;		// can also try /midinote or /freq

(
b = Pbind(\degree, Pseq([0, 2, 0, 8, 6, 4], 2),
		  \dur, Pseq([0.5, 0.5, 0.6, 0.8, 1.2, 1.5], inf),
          \amp, Pseq([0.5, 0.5, 0.6, 0.8, 1.2, 1.5], inf),
		  \legato, 1.8,
).play;
)





s.quit;