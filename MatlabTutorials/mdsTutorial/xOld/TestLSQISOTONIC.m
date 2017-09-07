% TestLSQISOTONIC
%
% Let's figure out how this sucker works.
%
% 6/26/06   dhb, scm   Wrote it.

% Find path to function
statspath = fileparts(which('mdscale'));
privatepath = [statspath filesep 'private'];

% Can we just run it
dissimilarity = [1 2 3 4 5 6 7  9 10];
distance = log(dissimilarity);

% Because lsqisotonic lives in private directory, we have to do headstands
% to run it.  But this seems cleaner than trying to make a copy and keep it
% elsewhere.
curdir = pwd;
eval(['cd(''' privatepath ''');']);
disparity = lsqisotonic(dissimilarity,distance);
dissimPredictions = lsqisotonic(distance,dissimilarity);
eval(['cd(''' curdir ''');']);




