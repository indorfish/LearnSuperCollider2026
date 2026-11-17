/*
INTRODUCING PATTERNS

- Routine is a control structure that can interrupt what it was doing and remember where it was, so that we can pick up where we left off.

- A Routine is conceptually a type of Stream.
The "stream" is a more general concept.


*/

s.reboot;


// a Routine.
// Recall that in SC, the last line of a function is automatically returned as the value of that function.
(
a = Routine {
	var i = 0;      // often, routines will need local variables.
	loop {
		i.yield;	// the yield statement is what allows us pause execution
		i = i + 1;  // ... and continue from here when next we evaluate.
	};
};
)

// nextN returns an array of the next n values of the routine.
// this will keep incrementing for as long as here is memory to work with.
a.nextN(5).postln;

// an equivalent way to define the above routine. The (0...) is syntactic sugar for the arithmetic.
(
b = Routine {
	(0..).do{
		| i |
		i.yield;
	};
};
)

// next value of i
b.next.postln;
b.nextN(10).postln;


// A Pattern is a terse way of doing the above (arithmetic series)
c = Pseries(start: 0, step: 1, length: inf);
// this won't work. A Pattern is declarative, not imperative.
// it says *what* should happen, not how it should happen.
c.next.postln;
// a stream constructs an executable process from the pattern.
d = c.asStream;
d.nextN(10).postln;


/*
Patterns define behavior; streams execute it.
A pattern is like a blueprint for a building, showing how all the parts fit together. The building doesn't exist until the contractors go and do what the plans specify.

A pattern is supposed to describe behavior, and in general, evaluating the pattern (by way of a stream) should not change anything in the Pattern object itself. In computer science terms, patterns are stateless; their definition does not change over time.
The stream is what keeps track of where we are in the pattern's evaluation.

This explains an easy "gotcha" with patterns -- forgetting to turn the pattern into a stream doesn't get the expected result.
Since a pattern doesn't have any concept of a current state, calling next on it is meaningless, so next does what it does for most objects: return the receiver object itself. The method asStream creates the stream conforming to the pattern's specification, and calling next on the stream advances to its next state and returns the new value.

There is a concrete benefit to this strict division of labor. Since the stream does not modify the original pattern, any
number of streams can be made from the same blueprint. All of those streams maintain their own independent states,
and they can operate concurrently without interfering with each other.
*/
(
x = c.asStream;
y = c.asStream;
z = c.asStream;
)

(
x.nextN(10).postln;
y.nextN(5).postln;
z.nextN(3).postln;
)


// GOODBYE!
s.freeAll;
s.quit;