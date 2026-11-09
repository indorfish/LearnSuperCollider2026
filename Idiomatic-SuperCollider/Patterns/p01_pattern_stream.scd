/* EXPLORING PATTERNS
via Mary Had a Little Lamb
*/

Server.local.boot;


//help(Pattern);

/*
Simplified mental model: a Pattern is a "score".
This is distinct from the performance of the score (which is a Stream).
A Pattern gives you a recipe for performing a score, and when a score is performed we may call that a "stream".

A Stream is to a Pattern as a process is to a program.
Multiple independent instances of a stream can be created from the same pattern.
*/

// Pseries
p = Pseries(start:0, step:1, length:20);

a = p.asStream;
b = p.asStream;
c = p.asStream;

3.do{a.next};
7.do{b.next};
10.do{c.next};








Server.local.quit;