function SaveHFPResultsTable(red, green, InitialRedSetting)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

if ~exist("ParticipantMatchesHFP.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesHFP=table([], [], [], [], [], ...
        'VariableNames',{'ParticipantCode', 'DateTime', 'RedValue', 'GreenValue', ...
        'InitialRedSetting'});
else
    % Load Structure File
    load('ParticipantMatchesHFP.mat');
end

%% record research participant name
if isempty(ParticipantMatchesHFP.ParticipantCode)
    LastParticipant=['rp_000'];
else
    LastParticipant=ParticipantMatchesHFP.ParticipantCode{end};
end
codenum=str2num(LastParticipant(4:6));
rpCode=['rp_' num2str(codenum+1, '%.3d')];

%% new participant results
newResults=table({rpCode}, CurrentDateAndTime, str2num(red), str2num(green), str2num(InitialRedSetting), 'VariableNames',...
    {'ParticipantCode', 'DateTime', 'RedValue', 'GreenValue', ...
        'InitialRedSetting'});

%% new table
ParticipantMatchesHFP=[ParticipantMatchesHFP; newResults];

%% show and save file

newResults
save('ParticipantMatchesHFP', 'ParticipantMatchesHFP');
clear
