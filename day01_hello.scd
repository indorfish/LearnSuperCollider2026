// DAY 01: This is the first SuperCollider 'patch'. It does not use the sc-synth audio server,
// merely the sc-lang interpreter. It demonstrates some key features of the language.
// The first is that SC is "object-oriented" and procedures may be used either as methods on objects, or as functions acting on objects obj.method vs method(obj)
// The second shows different variable types.


// Press Ctrl + Enter on a line to run it.
"Hello World".postln;
postln("Hi World");


// A block of commands
// Ctrl+Enter to run it.Why is the last line printed twice?
a = "Apple"; b = "Ball"; c = "Cat";
~myEnv = "I am an Environmental Variable";
(
// local variable shadows the global variable
var a = "Suprise! You thought it was Apple but it was me, local variable!";
postln(a); postln(b); postln(c);
postln(~myEnv);
)


/*
QUESTION TIME!

1. about the post window
2. about running commands - single statements, blocks of statements
3. types of variables
4.

*/