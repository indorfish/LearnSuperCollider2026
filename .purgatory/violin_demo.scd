// violin_demo.scd
// 1) Copy Violin.sc into Platform.userExtensionDir, then recompile the class library
//    (Language > Recompile Class Library, Cmd/Ctrl+Shift+L).
// 2) Run each block with Cmd/Ctrl+Enter.

s.boot;

// ---------- Block 1: SynthDefs + reverb bus ----------
(
Violin.prepare;
~bus = Bus.audio(s, 2);
~rev = Synth.tail(s, \violinReverb, [\in, ~bus]);
)

// ---------- Block 2: compose with the text controller ----------
(
~v = Violin(\saw);
~v.out = ~bus;
~v.reset;
~v.set(\tempo, 90).set(\dynamic, \mf).set(\vibrato, \normal);

// A slurred run. One bow can't last forever: watch the Post window,
// the model will break the slur when the bow runs out.
[\D4, \E4, \F4, \G4, \A4, \Bb4, \A4, \G4].do { |n| ~v.play(n, 0.5, \legato) };
~v.play(\F4, 1.5, \legato);
~v.rest(0.5);

// Different articulations are just names
~v.set(\dynamic, \f);
[\D5, \C5, \A4, \F4].do { |n| ~v.play(n, 0.5, \spiccato) };
[\G4, \A4, \Bb4, \C5].do { |n| ~v.play(n, 0.5, \martele) };

// Double stop: the model picks strings and checks the hand can reach
~v.set(\dynamic, \mp);
~v.chord([\D4, \F4], 2, \legato);

// Four notes can't sound at once: the model rolls them
~v.chord([\G3, \D4, \A4, \E5], 2, \legato);

// Sul ponticello (bow near the bridge) is a state change, not a new note
~v.set(\contact, \ponticello).set(\vibrato, \none);
~v.play(\A5, 2, \legato);
~v.set(\contact, \normal).set(\vibrato, \normal);
~v.rest(0.5);

// Pizzicato
[\D4, \F4, \A4, \D5].do { |n| ~v.play(n, 0.5, \pizz) };

// Inspect what the model decided: string, finger, bow direction, speed
~v.show;
)

// ---------- Block 3: render it with different views ----------
~v.go;                           // synthesized saw backend
~v.set(\backend, \additive); ~v.go;   // same performance, different sound

// ---------- Experiments: the model pushing back ----------
(
~v.reset;
~v.play(\C3, 1);                 // below the G string: adaptive mode moves it up an octave
~v.chord([\C4, \F#5], 1);        // can't double-stop this: spread as an arpeggio
~v.set(\dynamic, \ff);
~v.play(\A4, 12, \legato);       // longer than a whole bow at ff: model plays it softer
~v.show;
)

// Strict mode refuses instead of adapting (run it to see the error)
(
~v.reset;
~v.set(\mode, \strict);
~v.play(\C3, 1);
)
~v.set(\mode, \adaptive);

// To add a sample-based view later:
// Violin.backends[\samples] = (note: { |g, server, out, clock| /* read g[\freqs], g[\art], g[\bowSpeed]... */ });
// ~v.set(\backend, \samples);
