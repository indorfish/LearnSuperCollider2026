
/*
-	BASIC VOCABULARY OF PATTERNS
The typical taxonomy of patterns in SuperCollider is:
    - List patterns
		consume lists or array-like objects as input
	- Additional/Extra/Miscellaneous

While it is true that a pattern needs to be converted to a stream in order to respond to the `next` message,
a pattern can directly respond to the `play` message (and the `stop`) messages by executing a process on the audio server.
But it's best to use Patterns as arguments to the Pbind object.

Personally, I'm curious to know what necessitated this level of variety in terms of pattern types. Some of them seem quite esoteric - like Place for example.
Perhaps Place is for counterpoint, but is counterpoint common enough to necessitate a special pattern object for it?

Update: Place makes more sense now that I look at it.

The list of pattern objects in this document is not exhaustive.
*/

s.reboot;

/* __________________________________________________________________
-	LIST PATTERNS
	-	Pseq, Prand, Pser,
	-	Pxrand, Pwrand, Pshuf,
	-	Pslide, Pwalk, Place, Ppatlace, Ptuple
*/



/* __________________________________________________________________
-	FUNCTION(?) PATTERS
	-	Pseries, Pgeom,
	-	Pfunc, Pfuncn
	-	Pwhite, Pbrown, Pexprand,
	-	Prout
*/


/* __________________________________________________________________
	RECORDING AUDIO


*/



(
s.quit;
)