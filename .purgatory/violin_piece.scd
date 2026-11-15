// Synthesized violin piece in SuperCollider
// 1) Boot the server: s.boot;
// 2) Run each block below with Cmd/Ctrl+Enter (click inside the parentheses).
s.boot;
// ---------- Block 1: instrument + reverb ----------
(
SynthDef(\violin, { |out=0, freq=440, amp=0.3, gate=1, pan=0,
    vibRate=5.5, vibDepth=0.008, vibDelay=0.25, bow=0.05|

    var vibEnv, vib, f, env, sig, noise, body;

    // Vibrato fades in after a short delay, like a real player
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.6]));
    vib = 1 + SinOsc.kr(vibRate + LFNoise1.kr(1, 0.3), 0, vibDepth * vibEnv);
    f = freq * vib;

    // Slow bowed attack, sustained body, gentle release
    env = EnvGen.kr(Env.adsr(0.09, 0.1, 0.8, 0.3), gate, doneAction: 2);

    // Slightly detuned sawtooth pair = string-like harmonic spectrum
    sig = Saw.ar(f) + (Saw.ar(f * 1.004) * 0.6);

    // Bow noise, filtered around the pitch
    noise = BPF.ar(PinkNoise.ar, f * 2, 0.5) * bow * 4;
    sig = sig + noise;

    // Brightness follows the bow pressure (envelope)
    sig = LPF.ar(sig, (f * 5).clip(300, 9000) * (0.4 + env));

    // Fixed body resonances (the wooden box) give the "violin" color
    body = BPF.ar(sig, 280, 0.5) + (BPF.ar(sig, 450, 0.4) * 0.8)
         + (BPF.ar(sig, 1200, 0.3) * 0.5) + (BPF.ar(sig, 2800, 0.3) * 0.4);
    sig = (sig * 0.3 + body) * env * amp;

    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\reverb, { |in=0, out=0, mix=0.3, room=0.8|
    var sig = In.ar(in, 2);
    Out.ar(out, FreeVerb2.ar(sig[0], sig[1], mix, room, 0.4));
}).add;
)

// ---------- Block 2: the piece ----------
(
~rbus = Bus.audio(s, 2);
~verb = Synth.tail(s, \reverb, [\in, ~rbus]);

Pdef(\melody, Pbind(
    \instrument, \violin,
    \out, ~rbus,
    \scale, Scale.minor,
    \root, 2,                       // D
    \octave, 5,
    \degree, Pseq([
        0, 2, 4, 7,  6, 4, 2, 4,
        5, 4, 2, 0,  -1, 1, 2, 0,
        4, 5, 7, 9,  8, 7, 4, 2,
        3, 2, 1, -1, 0, \rest
    ], 1),
    \dur, Pseq([
        0.5, 0.5, 0.5, 1.5,  0.5, 0.5, 0.5, 1.5,
        0.5, 0.5, 0.5, 1.5,  0.5, 0.5, 0.5, 1.5,
        0.5, 0.5, 0.5, 1.5,  0.5, 0.5, 0.5, 1.5,
        0.5, 0.5, 0.5, 1,    3,   1
    ], 1),
    \legato, 1.05,                  // slight overlap = smooth bowing
    \amp, Pwhite(0.2, 0.35),
    \pan, Pwhite(-0.2, 0.2),
    \vibRate, Pwhite(5.0, 6.2)
));

// Add a low drone voice an octave+ below for harmony
Pdef(\drone, Pbind(
    \instrument, \violin,
    \out, ~rbus,
    \scale, Scale.minor,
    \root, 2,
    \octave, 4,
    \degree, Pseq([0, -2, 0, -3, 0], 1),
    \dur, Pseq([6, 6, 6, 6, 6], 1),
    \legato, 1.02,
    \amp, 0.18,
    \pan, -0.5,
    \vibDepth, 0.004
));

Ppar([Pdef(\melody), Pdef(\drone)]).play;
)

// Stop everything: CmdPeriod / Ctrl+.
