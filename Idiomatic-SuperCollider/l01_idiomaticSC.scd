/*
	LESSON 01 - IDIOMATIC SUPERCOLLIDER
SuperCollider is a complex language. Trying to use SuperCollider by learning its syntax is like trying to use C++ by learning its syntax - you will spend a decade before you build anything useful.
Instead, start by learning to make music with SuperCollider.
There are various ways to do this, but this document presents an idiomatic approach.
1. Boot the server [and modify its parameters]
2. Define your sound-making instruments via anonymous functions or SynthDefs. These are recipes that tell scsynth how to make sound.
3. Schedule audio events in time - via sequencer, or MIDI control, or whatever creative method you can think of.
4. Free up memory and shutdown the server.

During this process, you will also have to watch your memory usage. Isn't this fun?
*/


/* _______________________________________________________________
01 - BOOT UP THE SERVER
s.reboot is often used to apply changes to the server's options
You modify the options, then reboot. For now, that's not important.
*/
s.boot;


/* _______________________________________________________________
02 - DEFINE YOUR INSTRUMENTS
Here, we define our drums, violins, samplers, harpischords, moogs, vocals, etc.
SuperCollider lets us do this with UGens, functions, Buffers, Envelopes, EnvGens, SynthDefs, etc.
The SynthDef is the most important concept to learn;
SuperCollider consists of sclang and scsynth (at least).
sclang is the programming language/interpreter and scsynth is the audio processing and DSP engine.
A SynthDef is a recipe that tells scsynth how to create or modify/process sound.
If a synth is named "sineTone" then the syntax for a SynthDef registry is:
SynthDef(\sineTone, UGEN_GRAPH_FUNC).add;
UGEN_GRAPH_FUNC is a function block which defines the synthesis program basically, the DSP recipe.
The 'add' message registers the SynthDef with the audio server under the name \sineTone.
For the following synthdef, can you guess what its name is? What is the 'UGEN_GRAPH_FUNC'?
*/

(
SynthDef(\simpleSine,
	{arg outputChannel = 0, freq = 440, amp = 0.5;
		var sig = SinOsc.ar(freq: freq, mul: amp);
		// every SynthDef must write its signal somewhere.
		// Out is an audio bus ugen. Channel 0 is your audio speaker.
		Out.ar(outputChannel, sig);
	}
).add;
)

// other SynthDefs or instrument definitions. Think of this phase as "preparing the orchestra's instruments"

/*
Using a synth to generate the partials of some spectrum.
You could run each line separately, but the parentheses let you run all at once.
*/
(
~f0 = 200;
~a0 = 1.0;
Synth(\simpleSine, [\freq, 1*~f0, \amp, ~a0/2]);
Synth(\simpleSine, [\freq, 2*~f0, \amp, ~a0/4]);
Synth(\simpleSine, [\freq, 3*~f0, \amp, ~a0/8]);
Synth(\simpleSine, [\freq, 4*~f0, \amp, ~a0/16]);
Synth(\simpleSine, [\freq, 5*~f0, \amp, ~a0/32]);
)

/*
You will notice by now that there is no way to stop these sounds. In the next lesson we will figure out how to stop sounds, and how to do it properly. for now, just run the following command.
*/
s.freeAll;


/*
sclang is a fully-fledged programming language and supports composition (pun intended).
We can use the synthdef we defined, to compose more complex musical units.
This time we will construct a tone from partials, using a function rather than a SynthDef.
*/
// define a function that generates the tone from all the partials
(
~tone = {
	arg f0 = 100, harmonics = 5;
	var amplitude = 1.0;
	harmonics.do({arg i;
	    var n = i+1; // iteration variables are zero-indexed.
		Synth(\simpleSine, [\freq, f0*n, \amp, amplitude/(2**n)])}
	);
};
)

// now generate several partials at once.
~tone.value(440, 3);
s.freeAll;

// don't worry about what this means yet.
(
Routine({
    for (1, 3, { |i|
        for (1, 5, { |j|
            ("Frequency multiplier: " ++ i
                ++ ", partials: " ++ j).postln;
            x = ~tone.value(220 * i, j);
            1.wait;
			//s.freeAll;
        });
		s.freeAll;
    });
}).play;
)


/* - SHUTDOWN THE SERVER
 You can actually shutdown the audio server at any point.
The language can still work, it just won't produce any audio.

"But what about step 3 - scheduling audio events in time?"
We already did a very crude version of this in the previous step. The reason it is not worth acknowledgement is that it is rather inelegant.
The reason it is inelegant is because  we are not freeing memory in the idomatic way using doneAction.
So far, the Synths that we spawn cannot be despawned in any convenient way - without s.freeAll, they will quickly overwhelm the audio server
But a doneAction is a parameter in many UGens, which can be used to automatically despawn a synth so that it cleans itself up once it is done.
By using doneActions, many of our loops and iterations will become simpler.
Much of our sequencing and scheduling of audio events will become relatively simpler because we no longer have to worry about manually releasing memory.

*/

(
s.freeAll;
s.quit;
)