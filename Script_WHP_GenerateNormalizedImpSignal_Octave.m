## Kyle Ramsey - Whitehill Project - MSc Heritage Visualisation 20/21 - GSA
## Octave Script to generate normalized Impulse signal to be used as input signal to capture reverberations.
## Create string for filename.
filename = ('NormalizedImpulseSignal.wav');
## Set Frequecy of signal.
fs = 44100;
## Set duraction of clip.
impDur = 50
## Normalizes the signal to prevent clipping of audio.
normalize = @(x) x./max(abs(x));
## Generates random impulse signal;
mySignal = [zeros(fs,1); randn(impDur,1); zeros(4*fs-impDur,1)];
## Normalize signal.
newSignal = normalize(mySignal);
## Write signal to a wav file at the base C;/ directory
audiowrite(filename, newSignal, fs);
