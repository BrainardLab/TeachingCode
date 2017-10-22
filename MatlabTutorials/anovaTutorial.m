%%anovaTutorial  Show how to use Matlab's anovan function to run an anova.
%
% Description:
%    This little script sets up some a simple data set for three variables
%    and then uses Matlab's anovan function to run an anova.  The example
%    is set up so that you can play with the model used in the anova, and 
%    also change variables from fixed to random.
%
%    A more advanced example would add replications for the same conditions,
%    so you could see that.
%
%    This tutorial should let you play around with the underlying linear model,
%    which might lead to clarity in terms of how it works.
%
%    There is a newer class in Matlab that does anovas, and it might make
%    sense to change this to work with that.  
%
%    Another long term objective is to check whether we can get the same answers
%    out of Matlab's mixed-model repeated measures code, as we do from other
%    stats packages.  Ana is dubious.

% 10/06/17  dhb  Simplified a version Ana gave me.
% 10/09/17  dhb  Couldn't stand the fact that it wasn't commented. Added comments
%                and improved variable names.

%% Clear
clear;

%% Dependent variable, some univariate measure of something
theDependentMeasure = [0.21
    0.67
    0.35
    0.56
    0.31
    0.70
    0.43
    0.47
    0.27
    0.57
    0.24
    0.58
    0.32
    0.62
    0.17
    0.77
    0.24
    0.67
    0.06
    0.67
    0.27
    0.63
    0.27
    0.66
    0.15
    0.56
    0.16
    0.56
    0.30
    0.60
    0.32
    0.56];

%% Independent variables
%
% These are subject, illuminant, and target.  For
% our demonstration purposes, it doesn't matter what
% these mean, except that it is natural to consider
% subject a random variable (each subject is a draw
% from a population) and illuminant and target to
% be independent variables that are under experimental
% controlled (and thus fixed variables).
subject = [...
    1 1 1 1 1 1 1 1 ...
    2 2 2 2 2 2 2 2 ...
    3 3 3 3 3 3 3 3 ...
    4 4 4 4 4 4 4 4 ]';

illuminant = {...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    'yellow';'blue';...
    };

target =  {...
    't1';'t1';...
    't2';'t2';...
    't3';'t3';...
    't4';'t4';...
    't1';'t1';...
    't2';'t2';...
    't3';'t3';...
    't4';'t4';...
    't1';'t1';...
    't2';'t2';...
    't3';'t3';...
    't4';'t4';...
    't1';'t1';...
    't2';'t2';...
    't3';'t3';...
    't4';'t4'};

%% Specs for anovan
%
% random is a vector containing the indices of variables that should
% be considered random.  One's not listed are considered fixed.
%
% Set to [] to have all variables considered fixed.  Making the
% change does effect the significance of the main effect of some
% of the fixed variables, in some cases.  So we ought to understand
% clearly which we want when we design the anova.  Searching on
% 'fixed versus random effect anoval' on the web returns a number
% of reasonable clear descriptions.
random = 1;

% Names vfor the variables, to make the anova table more readable
varNames = strvcat('Subject', 'Illumination', 'Target');

%% Run the full 3-way model with all interactions
%
% The full model is the default
[pFull, tabFull] = anovan(theDependentMeasure',{subject,illuminant target}, 'model','full','varnames', varNames, 'random', random);

% Specify a 2-way model that focusses on illumination and target.
% 
% It looks like that in this case, subject variability is treated as measurement noise,
% and the significance values of the various effects change. At least I think that
% is why they change.  I am not completely sure that this is the correct interpretation.
model = [0 1 0; 0 0 1; 0 1 1];
[pTwoWay, tabTwoWay] = anovan(theDependentMeasure',{subject,illuminant target}, 'model',model,'varnames', varNames, 'random', random);

% Specify a three way model, but without the three-way interaction.  I tried
% this because the three-way interaction comes out as NaN in the full table.
% I'm guessing this is because there isn't enough data to lock it down and it
% is ignored in that case.  I am not sure this is the correct interpretation.
model = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
[pNoThreeWayInteraction, tabNoThreeWayInteraction] = anovan(theDependentMeasure',{subject,illuminant target}, 'model',model,'varnames', varNames, 'random', random);
