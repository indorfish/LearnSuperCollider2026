
// ============================================================
// Für Elise - Beethoven (Opening Theme)
// ============================================================
// Note: MIDI note numbers. Middle C = 60.
// E5=76, D#5=75, E5=76, D#5=75, E5=76, B4=71, D5=74, C5=72, A4=69
// A2=45, E3=52, A3=57, C4=60, E4=64
// ============================================================

s.boot;

(
s.waitForBoot({

    // ---- SynthDef: simple plucked/struck tone ----
    SynthDef(\elise, { |out = 0, freq = 440, amp = 0.2, dur = 0.9, pan = 0|
        var env, sig;
        env = EnvGen.kr(
            Env([0, 1, 0.6, 0.3, 0], [0.005, 0.1, 0.4, dur - 0.5], -3),
            doneAction: 2
        );
        sig = SinOsc.ar(freq, 0, 0.6)
            + SinOsc.ar(freq * 2, 0, 0.2)
            + SinOsc.ar(freq * 3, 0, 0.08);
        sig = sig * env * amp;
        sig = Pan2.ar(sig, pan);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // ---- Helper: convert MIDI -> Hz ----
    ~m2f = { |m| m.midicps };

    // ---- Melody ----
    // Format: [midinote, duration, amp]
    // Bar 1: pickup E-D#  | Bar 2: E-D#-E-B-D-C | Bar 3: A
    ~melody = [
        // Pickup
        [76, 0.25, 0.22], [75, 0.25, 0.22],
        // E D# E B D C
        [76, 0.25, 0.24], [75, 0.25, 0.24], [76, 0.25, 0.24],
        [71, 0.25, 0.24], [74, 0.25, 0.24], [72, 0.25, 0.24],
        // A (long)
        [69, 0.50, 0.28],

        // Rest, then C E A
        [\rest, 0.25, 0], [60, 0.25, 0.20], [64, 0.25, 0.20], [69, 0.25, 0.22],

        // B (long)
        [71, 0.50, 0.28],

        // Rest, then E G# B
        [\rest, 0.25, 0], [64, 0.25, 0.20], [68, 0.25, 0.20], [71, 0.25, 0.22],

        // C (long)
        [72, 0.50, 0.28],

        // Rest, then E E D# E
        [\rest, 0.25, 0], [76, 0.25, 0.22], [76, 0.25, 0.20],
        [75, 0.25, 0.22], [76, 0.25, 0.22],

        // D# E B D C A
        [75, 0.25, 0.22], [76, 0.25, 0.22],
        [71, 0.25, 0.22], [74, 0.25, 0.22], [72, 0.25, 0.22],
        [69, 0.50, 0.26]
    ];

    // ---- Bass / accompaniment ----
    // (root + fifth pattern under each phrase)
    ~bass = [
        // Under "E D# E B D C A"
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [52, 0.25, 0.12],
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [52, 0.25, 0.12],
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [64, 0.25, 0.10],
        [45, 0.50, 0.14], [52, 0.50, 0.12],

        // Under "C E A"
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [64, 0.25, 0.10],
        [45, 0.50, 0.14], [52, 0.50, 0.12],

        // Under "E G# B"
        [45, 0.25, 0.14], [52, 0.25, 0.12], [56, 0.25, 0.12], [59, 0.25, 0.10],
        [45, 0.50, 0.14], [52, 0.50, 0.12],

        // Under "E E D# E"
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [64, 0.25, 0.10],
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [64, 0.25, 0.10],

        // Under final "D# E B D C A"
        [45, 0.25, 0.14], [52, 0.25, 0.12], [57, 0.25, 0.12], [64, 0.25, 0.10],
        [45, 0.50, 0.14], [52, 0.50, 0.12]
    ];

    // ---- Tempo ----
    // duration 1.0 = 1 beat.  Set a comfortable tempo (~ quarter = 0.4s)
    ~beat = 0.42;

    // ---- Play a note list ----
    ~playSeq = { |notes, beat, ampScale = 1.0, pan = 0|
        var t = 0;
        notes.do { |n|
            var midi = n[0];
            var dur  = n[1] * beat;
            var amp  = n[2] * ampScale;
            if (midi != \rest) {
                SystemClock.sched(t, {
                    Synth(\elise, [
                        \freq, midi.midicps,
                        \amp,  amp,
                        \dur,  dur * 0.95,
                        \pan,  pan
                    ]);
                    nil
                });
            };
            t = t + dur;
        };
    };

    // ---- Fire both voices ----
    ~playSeq.(~melody, ~beat, 1.0,  0.0);
    ~playSeq.(~bass,   ~beat, 1.0, -0.35);

    "Für Elise playing...".postln;
});
)

// ============================================================
// To stop everything:
s.freeAll;
// ============================================================