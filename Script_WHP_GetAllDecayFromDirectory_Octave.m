% Kyle Ramsey - Whitehill Project - MSc Heritage Visualisation 20/21 - GSA
% Script that loops through a directory and plots the delay from first peak in the signal to the last peak before hitting the baseline
pkg load signal; % Load the signal octave package


% Load the specific working directory
dataDir = 'D:/Users/MSC_HER_VIS/MASTERS_PROJECT/DataSets/Audio/OutputSignals/DenseTreeCover/OnListener/';
% load the files of the firectory into variable
audioFiles = dir(dataDir);

allDecay = zeros(numel(audioFiles)-2,1); % create array to store the decay value 
%(we minus two from the length value because the first two files are folder files or void).


fs = 48000; % samples of the audio file;
onsetDelay = 1*fs; %the amount of the signal we want to ignore
% the baseline of which we want to check if the amplitude is higher
baselineDur = round(.9*fs); 

% define butterworth lowpass filter (cutoff: 200Hz) 
% Link: https://octave.sourceforge.io/signal/function/butter.html
[b,a] = butter(3,200*2/fs,'low');

% anonymous function to compute euclidean distance
% Link: https://en.wikipedia.org/wiki/Euclidean_distance
eucDist = @(source,target) sqrt(sum(bsxfun(@minus,target,source).^2,2))
% location of signal emission in coordinates
sourceLoc = [164.2 41.89 176.8];
% load p (81 x 3 matrix) to get locations of virtual microphones
p = csvread('D:\Users\MSC_HER_VIS\MASTERS_PROJECT\DataSets\PositionData\TXT_UnityProjectPositionValues.csv');

% compute distances of signal emission to virtual microphones
distances = eucDist(sourceLoc,p);

% colormap of ridiculously high resolution
cMapRes = 512;
cMap = viridis(cMapRes);
%cMap = [cool(cMapRes/2); viridis(cMapRes/2)];
% map distances into that space
normalisedDistances = distances./max(distances);
cIdx = round(normalisedDistances*cMapRes);

# we begin a for-loop to iterate through the variables in audioData.
for ii = 1:numel(allDecay)
  % load data
  [y, fs] = audioread([dataDir audioFiles(ii+2).name]);
  % get amplitude envelope (abs of complex signal using hilbert)
  % Link: https://octave.sourceforge.io/signal/function/hilbert.html
  env = abs(hilbert(y));
  
  % apply zero-phase low pass filter
  % Link: https://octave.sourceforge.io/signal/function/filtfilt.html
  envF = filtfilt(b,a,env);
  % get maximum of pre-onset
  maxValBaseline = max(envF(1:baselineDur));
  % get location of overall peak
  [peak, loc] = max(envF);
  
  % measure decay time in samples (measured as: first sample at which signal
  % goes back below max of pre-onset baseline)
  decay = loc+min(find(envF(loc:end)<maxValBaseline))-onsetDelay;
  % transform in units of seconds
  decaySeconds = decay/fs;
  % store in array
  allDecay(ii,1) = decaySeconds;
  
  figure(1)
  subplot(3,2,2)
  t = 1/fs:1/fs:numel(env)/fs;
  plot(t,envF,'Color',cMap(cIdx(ii),:))
  hold on
end
hold off

xlabel('Time [s]')
ylabel('Amplitude [a.u.]')
xlim([47900 50500]./fs)
title({'lowpass filtered impulse responses', ...
  'coloured according to distances of virtual microphones', ...
  'from location of sound source'})

  
subplot(3,2,[3:6])
scatter3(p(:,1),p(:,3),p(:,2),50,allDecay,'filled')
xlim("auto")
ylim("auto")
zlim("image")
title({'Decay of sound signal in world space [s]',...
  'Dense tree Cover scene with acoustic simulation data'...
  'Listener Location is the same as sound emission source'})
ch = colorbar;
view([163 75])
hold on
scatter3(sourceLoc(:,1),sourceLoc(:,3),sourceLoc(:,2),200, [1 0 1], 'filled')
hold off


subplot(3,2,1)
t = 1/fs:1/fs:numel(env)/fs;
plot(t,zscore(y),'k')
hold on
plot(t,zscore(env),'b')
plot(t,zscore(envF),'r')
hold off
legend('raw signal','envelope','lowpass filtered envelope')
legend boxoff
xlim([47900 50500]./fs)
xlabel('Time [s]')
ylabel('Amplitude [a.u.]')
title('Example impulse response')
