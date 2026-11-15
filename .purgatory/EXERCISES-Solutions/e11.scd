/*
	EXERCISES 11 -
	Tip: It may help to think of the synth recursively.
	Start from the outermost level of abstraction and build the innards
*/
s.boot;


/*
11.1
Rewrite this patch replacing all numbers with variables.
(
{SinOsc.ar(
	freq: SinOsc.ar(freq: 512,
		mul: 673,
		add: LFNoise0.kr(7.5, 768, 600)
	),
	mul: 0.6
)}.play;
)
Here, I started by writing SinOsc.ar first with variables not declared,
then started implementing each variable.
Take note of something - an inner synth will not play till you put curly braces around it.
*/

(
var ampOut = 0.6;
var modFreq, modAmp, modShft;
var modShftFreq, modShftMul, modShftAdd;
modFreq = 512; modAmp = 673;
modShftFreq = 7.5; modShftMul = 768; modShftAdd = 600;

modShft = {LFNoise0.kr(modShftFreq, modShftMul, modShftAdd)};
{SinOsc.ar(
	freq: SinOsc.ar(freq: modFreq,
		mul: modAmp,
		add: modShft
	),
	mul: ampOut
)}.play;
)


/*
11.2
Rewrite the patch above with variables so that the scale of the SinOsc (673) is twice the frequency (512), and the offset of LFNoise0 (600) is 200 greater than the scale (768).
*/

(
var ampOut = 0.6;
var frequency, scale, modShft;
var modShftFreq, modShftScale, offset;
frequency = 512;
	scale = 2 * frequency;
modShftFreq = 7.5;
modShftScale = 768;
	offset = 200 + modShftScale;

modShft = {LFNoise0.kr(modShftFreq, modShftScale, offset)};
{SinOsc.ar(
	freq: SinOsc.ar(freq: frequency,
		mul: scale,
		add: modShft
	),
	mul: ampOut
)}.play;
)




/*
11.3
How would you offset and scale an LFNoise0 so that it returned values between the range of C2 and C6 (C4 is 60).
*/
(
// ANSWER
var lfnoise0_0, lfnoise0_1;
var freq0, mul0, add0;
var c2, c6;

freq0 = 1440; mul0 = 19; add0 = 10;
c2 = 58.midicps;
c6 = 62.midicps;

// If generator G produces values in range [a,b] then G.range(p,q) maps the values to range(p,q) as described.
{LFNoise0.ar(freq0, mul0, add0).range(c2, c6)}.play;
)



/*
11.4
An envelope is generating values between 400 and 1000. What is the offset and scale?
*/
/*
The offset is 400 since the default 'floor' is 0 for unipolar envelopes.
The scale will be 1000-400 = 600.
If the envelope is bipolar, then the range is still 600 but now the offset is (1000-400)/2

For Ugens with a default range of +1 to -1:
–The add is the center value of a range.
–The mul is the amount of deviation above and below the center.
–The lowest value is the add minus the mul.
–The highest value is the add plus the mul.
–The range is the mul times 2.
For Ugens with a default range of 0 to 1:
-The add is the low end of the range
-The mul is the amount of deviation above the low.
87-The mul + add is the h
*/



/*
11.5
As in previous chapters, make modifications to the practice examples and save any interesting variations in your collection. You can also record examples for later use in a composition.
*/


s.quit;

