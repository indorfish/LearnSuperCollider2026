/* 01 GETTING TO KNOW SUPERCOLLIDER IDE
*/


/*
	PRINTING TO THE CONSOLE HELLO WORLD
Run a line of code by hitting Ctrl+Enter on Windows or Linux
*/
"Hullo World";
//"Hallo World".speak;
postln("Hello World");
"Hi, World".postln;


// Booting the server
Server.default = s = Server.internal.boot;

/*
	AUDIO HELLO WORLD
SuperCollider is for generating sound, so let's generate a sine wave, the simplest sound.
Hit Ctrl + . to terminate all audio.
*/
{SinOsc.ar(freq:367.0, mul:1.0, phase:0.0)}.play;


// Playing three frequencies at once
(
{SinOsc.ar(freq:440.0, mul:0.4)}.play;
{SinOsc.ar(freq:440.9, mul:0.3)}.play;
{SinOsc.ar(freq:441.9, mul:0.3)}.play;
)

// ah, the beautiful sounds of music. Don't ya just love it?
(
{
	SinOsc.ar(freq: LFNoise0.kr([4, 10], 400, 300),
		phase:0.0,
		mul:0.3)
}.play;
)


//{LFNoise0.ar(100, 1.0, 1.0)}.play;
(
{
	SinOsc.ar(freq:LFNoise1.kr([4, 10], 440, 300),
		mul:0.3)
}.play;
)


// Another beautiful trash
(
{
	RLPF.ar(
		LFSaw.ar([8, 12], 0, 0.2),
		LFNoise1.ar([2,8].choose, 1500, 1600),
		0.05,
		mul: 0.6
	);
}.play;
)


/* WEIRD BUBBLY GHOSTLY SYNTH
	I did not make this.
*/
(
{
	CombN.ar(
		SinOsc.ar(
			LFNoise2.kr(
				3,
				10,
				LFSaw.kr([8, 16], 0, 3, 80)
			).midicps,
			0,
			0.1),
		0.2,            // max delay
		0.2,            // actual delay
		4				// decay
	)
}.play
)


// help(MIDIOut)

{CombN.ar(WhiteNoise.ar(0.01), [1, 2, 3, 4], XLine.kr(0.0001, 0.01, 20), -0.2)}.play;


s.quit;