/* 03
	A
*/
Server.default = s = Server.internal.boot;


/*
	VARIABLES:
The three (four?) ways to declare variables in SC are...
1. Environment variables: These are (I think) global variables limited to the current environment i.e. SC file. Prefixed with a tilde e.g.
	~myVariable;
2. Local variables: Typically used in functions or Synth defs. Preceded by the 'var' keyword e.g.
	var myVariable;
3. single-letter variables: Typically used for convenience. They are the letters a-z (lowercase) except s which is reserved for the server.
4. 'arg'. What's difference between 'arg' and 'var' anyway?
In every case, the first character should be lowercase.
Stop memorizing by reading! Memorize by doing! Experience is the greatest teacher!
*/



/* HARMONIC SWIMMING */
(
play({
	var fundamental, partials, out, offset;
	fundamental = 50;	// fundamental frequency
	partials = 20;		// number of partials
	out = 0.0;			// start of oscillator daisy chain
	offset = Line.kr(0, -0.02, 60);		// causes sound to separate and fade

	partials.do({ arg i;
		out = FSinOsc.ar(
			fundamental * (i+1),	// freq of partial
			0,
			max(0,					// clip negative amplitudes to zero
				LFNoise1.kr(
					6 + [4.0.rand2, 4.0.rand2], // amplitude rate
					0.02,						// amplitude scale
					offset						// amplitude offset
				)
			),
			out
		)
	});
	out
})
)



// WATER CUPS?
(
{
	Mix.fill(15,
		{
			var freq;
			freq = exprand(100, 3000);
			Pan2.ar(
				SinOsc.ar(
					freq * LFNoise1.kr(1.6, 0.4, 1),
					mul: EnvGen.kr(
						Env.perc(0, (freq**(-0.7))*100),
						Dust.kr(1/5)
					)
				), LFNoise1.kr(1/8)
			)
})*0.3
}.play
)



// Ex 11.1
(
var modulatorFreq, carrierFreq;
var modulatorSwing, modulatorOffset, carrierAmp;

modulatorFreq = 512;
modulatorSwing = 673;
modulatorOffset = LFNoise0.kr(7.5, 760, 600);
carrierAmp = 0.6;
carrierFreq = SinOsc.ar(modulatorFreq, modulatorSwing, modulatorOffset);

{SinOsc.ar(freq: carrierFreq, mul: carrierAmp)}.scope
)







/*
METHODS THAT MAY BE USEFUL
range(a, b): transforms the range of a UGen into [a,b]

*/


s.quit;