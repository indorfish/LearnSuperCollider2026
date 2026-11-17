/*
-	PBIND
Introducing Pbind

*/

s.reboot;

(
SynthDef(\harpsi, { |outbus = 0, freq = 440, amp = 0.1, gate = 1|
var out;
out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp *
Pulse.ar(freq, 0.25, 0.75);
Out.ar(outbus, out ! 2);
}).add;
)

/* ____________________________________________________________________
-	EVENTS
This discussion begins by understanding events.
An event in SuperCollider is similar to what Python would call a "dictionary".
It's a list (or set) of key-value pairs.
For example, we can describe the A4 key on a piano with the following event:
-	e = (freq: 440, dur: 1/32, vel:64/100);
We can access each parameter
-	e.at[\freq]; // or e[\freq] or e.freq
And we can write a new value...
-   e.put(\freq, 460);
-   e.put(\vel, nil);   // remove the key-value pair.

with this in mind, what then is Pbind? See the next section.

Interestingly, an event can respond to the .play message. The following is perfectly valid. Try it out.
-	(freq: 440, dur: 1*3).play;

Also, event prototype blah-blah.

*/
(freq: 440, dur: 1*3).play;





/* ___________________________________________________________________
-	SECTION 2: PBIND
What is Pbind?
You can think of a Pbind as a pattern that sequences *events* rather than values.
Pbind is an event pattern, while regular patterns are value patterns.
Note that Pbind is used slightly differently from normal patterns, but that's not much of a shock; most pattern types are idiosyncratic in their own way.

This may not necessarily be how Pbind works internally, but it's a good-enough mental model for most use-cases.
I think a more accurate statement is that Pbind works its internal machinery then creates an event object representing the current state of the stream or whatever.
Or "Pbind can generate a sequence of events"

Pbind does not produce a stream per se - rather it uses an object called an EventStreamPlayer which is what converts the sequence of events into a stream or whatever.
Honestly, use it first and worry about how it works later.

*/


/* ___________________________________________________________________
-	SECTION 3: PMONO
A monophonic version of Pbind? We'll see!

*/


s.quit;