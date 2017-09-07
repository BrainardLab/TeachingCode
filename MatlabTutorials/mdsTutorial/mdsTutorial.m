% mdsTutorial
%
% A little program for exploring multi-dimensional scaling through
% simulation.
%
% Mulltidimensional scaling is a method for analyzing dissimilarity
% scalings between stimuli.  The underlying model is that each stimulus is
% represented as a point in an N-dimensional space, and that the dissimilarities
% are a monotonic transformation of the interpoint distances.
%
% Requires statistics toolbox.
%
% 9/30/05   dhb, scm      Wrote it.
% 10/10/05  scm           Scaling figures and matching points
% 10/11/05  scm           Continuing
% 10/12/05  scm           Added the RotateScaleFlip to match data
% 10/24/05  scm           Added Gaussian random noise to the distribution
% 06/28/06  scm           Added dissimilarity predictions
% 06/29/06  scm           MDS Tutorial
% 06/30/06  scm           MDS Tutorial
% 7/4/06    dhb           Polished
% 7/9/06    dhb           Procrustes!

%% Clear old figures
clear; close all;

%% Set up simulated data
% Let's set up some dissimilarities consistent with the MDS model.
% We do so by choosing points in an N-dimensional space, computing the
% distances, transforming them, and adding some noise.  This section
% prompts for parameters and then creates the simulated data.

% Number of stimuli
defaultN = 20;
N = input(sprintf('Enter number of stimuli [%d]: ',defaultN));
if (isempty(N))
    N = defaultN;
end

% Dimension of underlying space
defaultSimulatedDimension = 2;
simulatedDimension = input(sprintf('Enter dimmensionality of simulated data [%d]: ',defaultSimulatedDimension));
if (isempty(simulatedDimension))
    simulatedDimension = defaultSimulatedDimension;
end

% Generate simulated coordinates.  These data represent the "correct"
% solution.  The goal of the analysis is to recreate a result as close to
% this as possible, from the dissimilarities.  We make sure there are no duplicate points.
simulatedPoints = rand(simulatedDimension,N);
POINTSOK = 0;
while (~POINTSOK)
    POINTSOK = 1;
    for i = 1:N
        for j = (i+1):N
            if (simulatedPoints(1,i) == simulatedPoints(1,j) & simulatedPoints(2,i) == simulatedPoints(2,j))
                simulatedPoints(:,j) = rand(2,1);
                POINTSOK = 0;
            end
        end
    end
end

% Compute dissimilarity matrix. Start with interpoint distances.
stimulusDistances = zeros(N,N);
for i = 1:N
    for j = 1:N
         stimulusDistances(i,j) = norm(simulatedPoints(:,i)-simulatedPoints(:,j));
    end
end

% Put distances through a power law transform.
power = 2;
dissimilarities = stimulusDistances.^power;

% Add noise to get simulated dissimilarities.  The data matrix must have
% zeros along the diagonal, be symmetric and be non-negative, so we enforce this.
defaultNoiseSigma = 0.01;
noiseSigma = input(sprintf('Enter sigma value for random noise [%d]: ',defaultNoiseSigma));
if (isempty(noiseSigma))
    noiseSigma = defaultNoiseSigma;
end
dissimilarities = dissimilarities + normrnd(0,noiseSigma,size(dissimilarities));
dissimilarities = dissimilarities-min(dissimilarities(:));
for i = 1:N
    dissimilarities(i,i) = 0;
    for j = i+1:N
        dissimilarities(j,i) = dissimilarities(i,j);
    end
end

%% Run the MDS analysis
% Here we just use MATLAB's (Statistics Toolbox) routine -- we don't really know
% the implementation details.  But we can see how well it works, and explore various
% aspects of its performance.
%
% The routine requires that we specify the dimensionality of the solution, it will
% produce a solution for dimension you give it.
%
% The routine returns a solution, the stress (a measure of how well the
% data are predicted), and the disparities.  The disparities are the
% monotonic transformation of the dissimilarities that come as close as
% possible to the interpoint distances in the solution.  It is the
% disparities that are compared to the interpoint distances of the solution
% to compute the stress.
defaultAnalysisDimension = 2;
analysisDimension = input(sprintf('Enter dimensionality of MDS analysis [%d]: ',defaultAnalysisDimension));
if (isempty(analysisDimension))
    analysisDimension = defaultAnalysisDimension;
end
[mdsSolution,mdsStress,mdsDisparities] = mdscale(dissimilarities,analysisDimension);
mdsSolution = mdsSolution';

% Put various distance-like quantities in convenient form and make some
% plots.
stimulusDistancesList = stimulusDistances(tril(true(size(stimulusDistances)),-1))';
dissimilaritiesList = dissimilarities(tril(true(size(dissimilarities)),-1))';
solutionDistancesList = pdist(mdsSolution');
disparitiesList = mdsDisparities(tril(true(size(mdsDisparities)),-1))';
figure; clf;

% Dissimilarities versus stimulus distance.  This should be a monotonic
% function, since we built them this way.  Noise will perturb the relation,
% so this plot gives a sense of how noisy the simulated data are.  Note
% that in a real problem, we don't have the stimulus distances and can't 
% make this type of plot.
subplot(2,2,1); hold on
plot(stimulusDistancesList,dissimilaritiesList,'ro');
xlabel('Stimulus Distance'); ylabel('Dissimilarity');
axis('square');

% Solution distances versus stimulus distances.  In the absence of noise,
% this should be a straight line.  Because the solution can have a
% different scale from the stimulus, the slope isn't necessarily unity.
subplot(2,2,2); hold on
plot(stimulusDistancesList,solutionDistancesList,'ro');
xlabel('Stimulus Distance'); ylabel('Solution Distances');
axis('square');

% Disparities versus dissimilarities.  The disparities are a monotonic
% transformation of the dissimilarities, so this should always be a
% monotonic transformation.  
subplot(2,2,3); hold on
plot(dissimilaritiesList,disparitiesList,'ro');
xlabel('Dissimilarities'); ylabel('Disparities');
axis('square');

% Disparities versus solution distances.  If the analysis fits the data, the
% disparities should be close to the solution distances.
subplot(2,2,4); hold on
plot(solutionDistancesList,disparitiesList,'ro');
xlabel('Solution Distances'); ylabel('Disparities');
axis('square');
drawnow;

%% Computation of stress
% Stress is a measure of how well the solution fits the data.  It is
% computed in the solution space, which at first is a bit counterintuitive.
% The rationale for this has to do with the view that dissimilarity ratings
% don't satisfy metric axioms.  By assumption, however, the solution space
% is a metric space so computing error as distances there is more
% compelling.
%
% Although the mdscale function automatically calculates stress for us,
% let's calculate it on our own as well.  The default stress measures
% normalizes the prediction differences by the actual distances, which
% makes the measure independent of a change of scale in the solution space.
%
% The stress formula we are using is Kruskal's STRESS1 formula (Kruskal
% 1964a, 1964b).
diffsList = solutionDistancesList - disparitiesList;
sumDiffSq = sum(diffsList.^2);
sumDistSq = sum(solutionDistancesList.^2);
stressCheck = sqrt(sumDiffSq ./ sumDistSq);
fprintf('MDS returned stress: %g, our direct computation: %g\n',mdsStress,stressCheck);

%% Comparing the stimulus configuration and the solution
% We now have a MDS solution provided for us.  The important thing to note
% about a solution from multidimensional scaling is that the absolute location of
% the points isn't critical, it's just the interpoint distances.  And those
% distances get passed through a monotonic transformation before being used
% to predict the dissimilarities.  So to compare the solution to the stimulus
% configuration, we have to account for freedom to scale, shift, rotate, and flip
% the solution.
%
% It turns out that the analysis required to do this is called a procrustes
% analysis, and such a routine is included in the statistics toolbox.  We
% only do this when the simulated and anslysis dimensions are the same.
if (simulatedDimension == analysisDimension)
    [nil,mappedSolution] = procrustes(simulatedPoints,mdsSolution);
   
    % Here's a graph of the correct solution and the recovered solution.  Note
    % that the axes in this case have no actual meaning other than just
    % representing separate dimensions.  We don't exhaustively show all the
    % dimensions in the plots.
    if (simulatedDimension == 2)
        figure; clf; hold on
        title('Solution Match');
        plot(simulatedPoints(1,:),simulatedPoints(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
        plot(mappedSolution(1,:),mappedSolution(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
        xlabel('Dimension I');
        ylabel('Dimension J');
        axis('square');
    elseif (simulatedDimension == 3)
        figure; clf;
        subplot(1,2,1); hold on
        title('Solution Match');
        plot(simulatedPoints(1,:),simulatedPoints(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
        plot(mappedSolution(1,:),mappedSolution(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
        xlabel('Dimension I');
        ylabel('Dimension J');
        axis('square');
        subplot(1,2,2); hold on
        title('Solution Match');
        plot(simulatedPoints(1,:),simulatedPoints(3,:),'ro','MarkerFaceColor','r','MarkerSize',6);
        plot(mappedSolution(1,:),mappedSolution(3,:),'bo','MarkerFaceColor','b','MarkerSize',4);
        xlabel('Dimension I');
        ylabel('Dimension K');
        axis('square');
    else
        figure; clf;
        subplot(1,3,1); hold on
        title('Solution Match');
        plot(simulatedPoints(1,:),simulatedPoints(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
        plot(mappedSolution(1,:),mappedSolution(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
        xlabel('Dimension I');
        ylabel('Dimension J');
        axis('square');
        subplot(1,3,2); hold on
        title('Solution Match');
        plot(simulatedPoints(1,:),simulatedPoints(3,:),'ro','MarkerFaceColor','r','MarkerSize',6);
        plot(mappedSolution(1,:),mappedSolution(3,:),'bo','MarkerFaceColor','b','MarkerSize',4);
        xlabel('Dimension I');
        ylabel('Dimension K');
        axis('square');
        subplot(1,3,3); hold on
        title('Solution Match');
        plot(simulatedPoints(1,:),simulatedPoints(4,:),'ro','MarkerFaceColor','r','MarkerSize',6);
        plot(mappedSolution(1,:),mappedSolution(4,:),'bo','MarkerFaceColor','b','MarkerSize',4);
        xlabel('Dimension I');
        ylabel('Dimension L');
        axis('square');
    end   
end

%% Predicting Dissimilarities
% Although dissimilarity judgments don't have good metric properties,
% it still seems of interest to ask how well the solution predicts the
% actual measurements.  We have the interpoint distances of the solution,
% and we want to find the monotonic transformation of these distances that
% comes as close as possible to the data.  The function 'lsqisotonic' will
% find this transformation.  It is a little hard to run as it's buried in
% the private part of the statistics toolbox.

% Find path to function lsqisotonic
statspath = fileparts(which('mdscale'));
privatepath = [statspath filesep 'private'];
curdir = pwd;

% Get predictions.
eval(['cd(''' privatepath ''');']);
dissimPredictions = lsqisotonic(solutionDistancesList,dissimilaritiesList);
eval(['cd(''' curdir ''');']);

% Now you have some predictions about how participants should act if your
% model is correct.
figure; clf; hold on
maxVal = max([dissimilaritiesList(:) ; dissimPredictions(:)]);
plot(dissimilaritiesList,dissimPredictions,'ro');
plot([0 maxVal],[0 maxVal],'b');
xlabel('Dissimilarities'); ylabel('MDS predictions');
axis([0 maxVal 0 maxVal]);
axis('square');

%% References
% 1. Kruskal, J.B.  (1964a).  Multidimensional scaling by optimizing
% goodness-of-fit to a nonmetric hypothesis.  Psychometrika, 29, 1-27.
% 2. Kruskal, J.B.  (1964b).  Nonmetric multidimensional scaling: A
% numerical method.  Psychometrika, 29, 115-129.