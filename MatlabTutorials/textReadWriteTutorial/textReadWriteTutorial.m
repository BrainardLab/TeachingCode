% textReadWriteTutorial
%
% There are a number of ways to get data in and out of text files.
% Here, we illustrate at least one.  The idea is that we should
% be able to write a text file in some format, and then read back
% in what we wrote.
%
% This is particularly useful for cleaving data analysis into two
% cleanly separated parts.  One part reads all the .mat files
% for the experiment (and perhaps condition files), and produces
% a set of text files that are organized in a human interptretable
% manner.  The other part reads these and then produces all the
% analyses for a paper.  That way, we can be sure tha our analyses
% programs are drawing on the data we post on a supplemental web
% site, and thus that they can be recreated from the same data
% we make available.
%
% 7/5/13  dhb, ar  Wrote it.

%% Clear
clear; close all

%% Generate some dummy data to play with
%
% We assume no spaces or other really weired characters in the column header names,
% which is probably a good idea in any case
theHeaders = {'Column_A', 'Column_B', 'Column_C'};
nDataRows = 100;
nDataCols = length(theHeaders);
theData = rand(nDataRows,nDataCols);

%% Write some tab delimted text.
%
% See help WriteDataWithHeadersToText (in BrainardLabToolbox).
theTabDelimitedTextFile = 'tabDelimtedTextData.txt';
WriteDataWithHeadersToText(theTabDelimitedTextFile,theData,theHeaders,'%g');

%% Read it back in.  ReadDataWithHeadersFromText is also in BrainardLabToolbox
% and is basically a call through to importdata.
[theReadData,theReadHeaders] = ReadDataWithHeadersFromText(theTabDelimitedTextFile);

%% Make sure what we read is what we wrote
if (length(theHeaders) ~= length(theReadHeaders))
    error('Error reading number of column headers');
end
for i = 1:length(theHeaders)
    if (~strcmp(theHeaders{i},theReadHeaders{i}))
        error('Header read error');
    end
end
if (any(abs(theData-theReadData) > 1e-6))
    error('Did not read what we wrote.');
end

%% Another way to do this, using PTB's WriteStructsToText and ReadStructsFromText.
%
% Although this is clunkier and probably slower, it allows for some of the columns
% to contain string data.  That usage is not shown here, but by making one of the
% fields of the struct contain strings, it should work (but note that more care
% in unpacking is required, as the code below unpacks the data as numerical.)
%
% This requires setting up a struct array of the data
theStructTextFile = 'structWrittenTextData.txt';
for c = 1:length(theHeaders)
    for i = 1:nDataRows
        eval(['theDataStructs(' num2str(i) ').' theHeaders{c} ' = theData(i,c);']);
    end
end
WriteStructsToText(theStructTextFile,theDataStructs);

%% Read back the struct array
theReadStructs = ReadStructsFromText(theStructTextFile);
theStructReadHeaders = fieldnames(theReadStructs);
theStructReadData = zeros(length(theReadStructs),length(theStructReadHeaders));
for c = 1:length(theReadHeaders)
    for i = 1:length(theReadStructs)
        theStructReadData(i,c) = eval(['theReadStructs(' num2str(i) ').' theStructReadHeaders{c} ';']);
    end
end

%% Make sure what we read is what we wrote
if (length(theHeaders) ~= length(theStructReadHeaders))
    error('Struct rror reading number of column headers');
end
for i = 1:length(theHeaders)
    if (~strcmp(theHeaders{i},theStructReadHeaders{i}))
        error('Struct header read error');
    end
end
if (any(abs(theData-theStructReadData) > 1e-5))
    error('Struct id not read what we wrote.');
end
