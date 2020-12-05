

% Clear
clear; close all;

% Load data
load('/Users/dhb/Documents/MATLAB/projects/TeachingCode/Circadian/data/theData_Temp')

% Plot frame times for each run
nRuns = length(drawTimes);
figure; 
for rr = 1:nRuns
    clf; hold on;
    deltaTimes = diff(drawTimes{rr});
    plot(deltaTimes,'ko-','MarkerSize',8,'MarkerFaceColor','k');
    plot(1:length(deltaTimes),(1/frameRate)*ones(1,length(deltaTimes)),'r','LineWidth',1);
    ylim([0 4/frameRate]);
    pause
end

% Time for each stimulus cycle.  Red line is max of specified stimulus
% cycle times.
figure; clf; hold on;
nStim = length(stimShownStartTimes);
stimShownDurations = stimShownFinishTimes - stimShownStartTimes(1:length(stimShownFinishTimes));
plot(stimShownDurations,'ko','MarkerSize',10,'MarkerFaceColor','k');
plot(1:length(stimShownFinishTimes),max(stimDurationsSecs)*ones(1,length(stimShownFinishTimes)),'r','LineWidth',1);
ylim([0 2*max(stimDurationsSecs)]);
xlabel('Stimlus Cycle');
ylabel('Cycle Duration Seconds');