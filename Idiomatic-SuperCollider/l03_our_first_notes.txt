/*
OUR FIRST NOTES
- For this exercise, we will try to play the first few notes of Fur Elise in a tedious manner.
We will do it by Ctrl+Enter note by note, then store the notes in an array and attempt a loop through the array, then find some idiomatic ways of doing this in SuperCollider.

No chords are considered for this lesson.
In a future lesson we will consider how to control polyphony in SC - turning it off completely then extending it.
*/

s.boot;

// define our synth - a basic sine pluck.
(
SynthDef(\pluck,
	{ |freq=440.0, amp=0.8, attack=0.01, release=1.0|
		var env, sig;
		env = EnvGen.kr(Env.perc(attackTime: attack,
								 releaseTime: release,
								 level: amp,
			                     curve: -4),
			             doneAction: 2);
		sig = SinOsc.ar(freq: freq, mul: amp);
		sig = env * sig;
		sig = Pan2.ar(sig, 0.0); 	// for full stereo
		Out.ar(0, sig);
	}
).add;
)

// quick test
Synth(\pluck);


/*
THE OPENING NOTES OF FUR ELISE
E5 (76) → D#5 (75) → E5 (76) → D#5 (75) → E5 (76) → B4 (71) → D5 (74) → C5 (72) → A4 (69).
*/
~e5 = Synth(\pluck, [\freq, 76.midicps]);
~ds5 = Synth(\pluck, [\freq, 75.midicps]);
~b4 = Synth(\pluck, [\freq, 71.midicps]);
~d5 = Synth(\pluck, [\freq, 74.midicps]);
~c5 = Synth(\pluck, [\freq, 72.midicps]);
~a4 = Synth(\pluck, [\freq, 69.midicps]);


/*
CAN WE DO BETTER THAN THAT?
First let's try defining the sequence of notes in a native SC array and we'll see if we can loop through the notes quickly.
*/
~furEliseNotes = [76, 75, 76, 75, 76, 71, 74, 72, 69];
// This happens too quickly. Is there any way to slow it down?
(
~furEliseNotes.do({
	| x |
	Synth(\pluck, [\freq, x.midicps]);
});
)



/*
ROUTINES
Seems a bit complex, but my understanding is that a routine allows you execute a function step-by-step.
So what? How is that special?
The catch is that a Routine, in my own words, allows you decide when to execute the next step. Hence with a Routine you can execute sluggishly or quickly or unevenly, however you like.

- Its parent class is `Thread`
- The two most important methods of a Routine are yield and next.
yield suspends execution and next continues execution, while the function is yet to reach a return value.
next has effect only while the function has not yet returned a value.
- reset and stop are also useful methods

Defining a routine:
- r = Routine.new(func, stackSize: 512); Maybe just experiment with it?
- r.run(func, stackSize, clock);
- r.next;
- r.play; You may need to read up on the Clock class and the play method specifically.
*/
(
r = Routine.new({
	~furEliseNotes.do({
		| x |
		Synth(\pluck, [\freq, x.midicps]);
	});
});
)
// still happens too fast.
r.play;

// LET'S TRY THAT AGAIN. THIS TIME WE USE THE 'wait' MESSAGE
(
r = Routine.new({
	~furEliseNotes.do({
		| x |
		Synth(\pluck, [\freq, x.midicps]);
		1.wait;			// wait for one second
	});
});
)
// NOW IT WORKS!
r.play;


/*
WHAT NOW?
We have seen a basic way of using Routines to sequence musical events.
What if we wanted different note durations? Well, we could use an array of duples - [note_value, note_dur] in order to communicate this information. In fact, let's try it.
*/
(
var beat=1; // 1 second reference
var half=beat/2, quarter=beat/4, eighth=beat/8;

~furEliseSequence = [
	[76, beat],
	[75, beat],
	[76, quarter+eighth],
	[75, quarter+eighth],
	[76, quarter],
	[71, quarter],
	[74, eighth],
	[72, beat],
	[69, beat+half],
];
)

// always remember the type of argument expected by Routine.
(
r = Routine.new(
	{
	~furEliseSequence.do({
		| x |
		var freq = x[0].midicps, dur = x[1];
		Synth(\pluck, [\freq, freq]);
		dur.wait;
	});
});
)
r.play;


/*
PATTERNS AND THE FUTURE
The approach of using arrays has some issues.
First of all, it is not terse enough. Conventional music features some amount of repetition. Shouldn't we have a way to easily indicate that a section repeats a certain number of times?
It can be done with a for loop perhaps, but does SC have a more convenient way of doing this?
Second, what if we wanted to control note velocity, timbre and a dozen other parameters?
We could use an array of n-tuples but how would you remember which index corresponds to what parameter? 
If this were C or C++, an array of structs of parameters would be quite helpful since each parameter can be directly accessed by name. Does SuperCollider have something similar? Something better?

These will not be covered in this lesson, but Patterns seem to be the idomatic way to sequence musical events in Supercollider.
Even from reading the documentation, it seems that Routines are general-purpose and intended for threading and all that nerd stuff. It's true that anyone using Supercollider probably has some knowledge about programming, but if SuperCollider is a musical instrument, a musical instrument that exposes bare Operating System concepts doesn't seem very elegant if you ask me.
Metaphors are an important concept in software usability - a musician should not have to think of threads and mutexes, but simply musical events sequenced in time.

Patterns seem more metaphorical, more within the domain of musicality than Routines do.
As programmers we can probably mess around with Routines, but as musicians we should probably focus on Patterns. These will be covered in subsequent exercises.
*/


// GOODBYE
(
s.freeAll;
s.quit;
)
