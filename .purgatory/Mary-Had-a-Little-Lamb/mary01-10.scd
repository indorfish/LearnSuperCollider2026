/*
MARY HAD A LITTLE LAMB
*/

s.boot;

/* 01
In this exercise, we create one SinOsc object for each note then manually play and free each note.
What to learn here is the different ways of specifying frequency in SuperCollider. These are:
- cycles-per-second (Hz) e.g. 440.0
- MIDI to cps e.g. 64.midicps
*/
~note_c = 72.midicps;
~note_d = 74.midicps;
~note_e = 76.midicps;
~note_g = 79.midicps;
c = {SinOsc.ar(freq: ~note_c)}.play;
d = {SinOsc.ar(freq: ~note_d)}.play;
e = {SinOsc.ar(freq: ~note_e)}.play;
g = {SinOsc.ar(freq: ~note_g)}.play;




s.quit;