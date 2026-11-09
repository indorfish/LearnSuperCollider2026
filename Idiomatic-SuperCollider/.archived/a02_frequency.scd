/* 02 FREQUENCY
	And all the ways to specify it in SCD
*/
Server.default = s = Server.internal.boot;

/*
	THIS IS HANDY FOR RECORDING
*/
s.recSampleFormat = "int16";
s.recChannels = 1; // for mono
// saves file in the SC folder, will be overwritten if repeated
//	s.prepareForRecord("audio1");
// or saved in recordings folder of SC folder
//	s.prepareForRecord("recordings/audio1");
// or saved in Music folder (replace students with your user name)
s.prepareForRecord("/home/tayo/Music/SCRecordings/day1_test");
// Then to record, don't use the button, but this:
// Before running these lines go back and play a previous example
// so you have something to record.
s.record;
// Then
s.stopRecording;


/*
	METHOD 1: Just directly specify the frequency as a parameter.
		This one sounds like a DTMF tone. 440 in the left, 470 in the right
		Here, we introduce a new method - scope - which lets us visualize the waveform.
		The 2 in scope(2) indicates that we want to view the two channels
*/
(
{
	SinOsc.ar(freq:[440,470]).scope(2)
}.play;
)


/*
	METHOD 2: Specify MIDI values which are then converted to frequency
		How to do it - number.midicps, where number is a valid MIDI number e.g. 64
		This one plays a minor third
*/
(
{
	SinOsc.ar(freq:[56.midicps,59.midicps]).scope(2)
}.play;
)


/*
	METHOD 3: Obtain the frequency from another UGen. In this case, it's another SinOsc
		which oscillates slowly, giving us a vibrato effect.
		I use only SinOsc since that's the only UGen we're allowed to use in this patch.
		This is technically phase modulation btw
*/
(
{
	var modulatorFreq = -50.midicps;
	var swing = 4;
	var offset = 500 + swing/2; // to make it unipolar
	SinOsc.ar(
		freq: SinOsc.ar(freq:modulatorFreq, mul:swing, add:offset),
		mul: 0.6
	).scope
}.play;
)


// 0 phase
{SinOsc.ar(SinOsc.ar(0.3, 0, 7, 72).round(1).midicps, 0, 0.7)}.play


// 0.5pi (1/4) phase
{SinOsc.ar(SinOsc.ar(0.3, 0.5pi, 7, 72).round(1).midicps, 0, 0.5)}.play
// 1pi (1/2) phase
{SinOsc.ar(SinOsc.ar(0.3, 1pi, 7, 72).round(1).midicps, 0, 0.5)}.play

// 1.5pi (3/4) phase
{SinOsc.ar(SinOsc.ar(0.3, 1.5pi, 7, 72).round(1).midicps, 0, 0.7)}.play



// There are no mistakes, only happy accidents. Check out this beautiful drone sound
// I think it is being clipped, which adds extra harmonics to it.
(
{
	SinOsc.ar(freq:[20,20.3])
}.play;
{
	SinOsc.ar(freq:[120,120.3])
}.play;
)


s.quit;