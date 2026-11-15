// DAY 01: This shows how to boot the sc-synth server from the interpreter
// s.boot .... s.quit

s.boot;

/* SinOsc is a unit generator or UGen object
   it is generally advised to assign them to variables so you can handle them properly
   kr stands for kontrol rate and is intended for control signals i.e. modulators. Uses lower CPU
   ar stands for audio rate and is intended for carrier signals i.e. audible audio
   the code inside the brace { ... } define a synth
*/


a = { SinOsc.ar(freq:430.1, phase:0.3, mul:0.8) }.play;
a.free;
// beep-bop. LFNoise is also a UGen. UGens can be composed i.e. used to control parameters, but it's advicsed that the controling UGen be at kr to save CPU

t = 8;
x = 50;
y = 600;
/*
  Basic example of UGEN composition
Another thing I've noticed is that if Line 10 depends on Line 1 and you update Line 1 while running Line 10,
SC will not use the updated state of Line 1. You'll have to run Line 1 again to propagate the changes.
This is why it is better to bundle dependent code into one abstraction - whether a block of code or a synthDef.
*/
b = { SinOsc.ar(freq: LFNoise0.kr(t).range(x, y) ) }.play;
b.free;


/*
c = {
	(
	var t = 6, x = 50, y = 500;
	var ctrlFreq = LFNoise0.kr(t).range(x, y);
	sig = SinOsc.ar(freq: ctrlFreq )
	)
}.play

c.free;
*/

s.quit;