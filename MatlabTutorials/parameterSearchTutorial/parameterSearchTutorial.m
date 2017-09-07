function parameterSearchTutorial
% parameterSearchTutorial
%
% A little modeling excercise: How to fit a line through some data, using parameter search.
% Although fitting a line is an analytically solved problem, it allows us a test bed for
% invoking the various MATLAB search routines.
%
% A few broad points worth noting.
%   a) By using an explicit function definition for the objective function, it is possible to switch
%   between the the various MATLAB search functions very easily.  It's worth setting things up this way.
%   We used to use inline functions, which is another method, but that is less readable.
%
%   b) There is a real speed win to running searches on the cluster.  The search functions
%   know about the distributed computing engine, and if you set the 'UseParallel' option
%   to always, they'll do so.  For search, so far our experience is that this is better
%   than setting up multiple parallel searches by hand.  Instead, do you searches sequentially
%   but use multiple processors for each search.
%
%   This program is set up to use the parallel seach code when you are on rhino and when a
%   matlabpool is open.
%
%   There are two ways to run the program with a matlab pool
%     First, you can run the program directly from matlab.  Here you have to open the matlab pool by hand,
%     and then close it again at the end.  See the help for the function matlabpool.  This is good
%     for debugging, because you are basically sitting in the matlab environment and can work
%     interactively.  Once things are working it is not so good, though.  If your computer drops its
%     connection to rhino, for example, you lose your job.  See code that does this below, conditional
%     on running on the cluster and being invoked without a pool open (i.e. not being invoked by parmgo.)
%
%   The second method is to invoke your program from the unix prompt using parmgo. Example:
%     parmgo parameterSearchTutorial.m 10
%   will run this program with a matlab pool of 10 processors. It then runs the thing for you.
%   Use qstat to see the processor queue.  This is good once your job is debugged.  You can't see
%   plots, though.  That's why the code here separates computing and plotting.
%
%   c) This program relies on some helper functions in a pretty standard way.
%     FitLineFunction -- this is the objective function minimized.
%     ComputeMatches  -- compute predictions of the model being fit from the parameters.
%     ComputerError   -- compute the error, given data and predictions.
%
%   d) In addition to illustrating parameter search, this tutorial also shows how one can try to
%   make sense of the size of the error by comparing fit models to the precision of the data and
%   to the variability in the data, by using some simple bounding models as benchmarks.  This is
%   quite generally useful, and relies on fitting models and computing error with respect to
%   individual replications rather than to mean data.
%
% This uses real data palette matching data, but that isn't critical either.
%
% Someday could add examples of using constraints to this.  Note that it is tricky to write
% an efficient constraint and non-linear constraint function.  See 
%   http://www.mathworks.com/matlabcentral/newsreader/view_thread/269936
% for one way.
%
% 2/19/10 ar        Started working on this.
% 3/09/10 ar        Turned it into "fit a straight" line tutorial.
%                   Added an estimate the quality of fit tutorial.
% 3/11/10 dhb, ar   Review and fuss.
% 3/15/10 dhb, ar   Fix up model comparison section.
%                   Convert to use inline function syntax.
% 3/18/10 ar        Added pattern search and ga algorithms and regression.
%                   Added graphs that measure elapsed time and error for each algorithm.
%                   Integrated the fminunc function.
% 3/23/10 dhb       Make it cluster ready, because we often want to run on the cluster and
%                   it's useful to have everything set up so that works from the start.
%         dhb       Split compute and plot parts.
%         dhb       More comments, and rename.
% 8/12/10 dhb       Add try/catch to close pool.  Good idea in general.
% 9/16/12 dhb       Get rid of inline functions, and use explicit function syntax instead.

%% INITIALIZE
%
% This includes code that forces the current working directory to be the one in which
% the calling file resides.  If you're invoking the file from the editor, you get
% this behavior for free.  But if you're on the cluster and being called by parmgo,
% then the calling directory will be wrong.
clear;
close all;
launchDir = pwd;
cd(fileparts(mfilename('fullpath')));
runDir = pwd;

%% CONTROL COMPUTING AND PLOTTING
% It is useful to separate computation from plotting. You can't always see the plots
% when you run on the cluster (e.g. if you use parmgo). So in that case, you want
% compute and save a .mat file.  Then you later load and plot.
COMPUTE = 1;
PLOT = 1;

% Here is the compute part.
try
    if (COMPUTE)
        %% DO WE NEED TO OPEN A MATLAB POOL?
        % Only do this if we are running on the cluster and were not invoked with parmgo.
        % That means we're running interactively on the cluster.
        %
        % In real code, make sure to choose desiredPoolSize judiciously and with an eye
        % to what the cluster queue looks like.
        if (IsCluster && matlabpool('size') == 0)
            desiredPoolSize = 10;
            matlabpool(desiredPoolSize);
            NEEDTOCLOSEPOOL = 1;
        else
            NEEDTOCLOSEPOOL = 0;
        end
        
        %% LOAD AND PLOT SOME DATA
        % Let's start with some data. These are just typed in, but to be helpful the comments say what
        % they represent.
        
        % We presented an observer with some target, which across trials varied in
        % luminance. This is our independent variable (testLuminance) and here are the values it takes
        testLuminance=[0.0300; 0.2352; 0.3281; 0.4403; 0.5910; 0.7805; 1.0476; 1.4125; 1.8958; 2.5381;3.4196;4.5832;...
            6.1515;8.2698;11.0861;14.8932;19.9894;26.8432;36.0147;48.3454;64.9024;116.9546; 157.0104];
        
        % The observer made a reflectance match for each test luminance using some standard scale.
        % Here are data for three trials from one observer () (dependent variable, matchRef1/2/3 expressed as match reflectance).
        
        % trial 1
        matchRef1=[0.007435;0.015119; 0.019188;0.04626;0.015119;0.04626;0.030481;0.064177;0.064177;0.090635;0.090635;...
            0.159665;0.090635;0.159665;0.201465;0.201465;0.25038;0.36589;0.36589;0.432816;0.482619;0.707097;0.942907];
        % trial 2
        matchRef2=[0.007435;0.015119;0.030481;0.019188;0.019188; 0.04626;0.04626;0.064177;0.090635; 0.11515;0.11515;...
            0.11515;0.159665;0.159665;0.159665;0.11515;0.311731;0.36589;0.36589;0.432816;0.616475;0.811587;0.942907];
        % trial 3
        matchRef3=[0.007435;0.019188;0.030481;0.030481; 0.04626;0.04626;0.090635;0.064177; 0.11515;0.090635; 0.11515;...
            0.159665;0.201465; 0.25038;0.159665;0.311731; 0.25038;0.432816;0.482619;0.432816;0.616475;0.811587;0.942907];
        
        % Collect all the data into one matrix
        allMatches = [matchRef1 matchRef2 matchRef3];
        meanMatches = mean(allMatches,2);
        
        % Plot the mean matches on a log-log plot. Note that when plotted this way, the
        % data are resonably well characterized by a straight line.
        basicPlot = figure; clf;
        subplot(1,2,1); hold on
        %plot(log10(testLuminance),log10(meanMatches),'ro','MarkerSize',6,'MarkerFaceColor','r');
        plot(log10(testLuminance),log10(allMatches),'ro','MarkerSize',4,'MarkerFaceColor','r');
        xlabel('Log10 Test Luminance'); ylabel('Log10 MatchRef');
        xlim([min(log10(testLuminance)),max(log10(testLuminance))]);
        ylim([min(log10(meanMatches)),max(log10(meanMatches))]);
        axis('square');
        title('Actual Data')
        
        %% HOW DO WE FIT A LINE THROUGH THE DATA? -- PART 1
        % Although we can fit a line to the data using linear regression, our
        % purpose here is to use this problem as an example of more general
        % model fitting techniques.  The first thing to realize, therefore, is
        % that a line is a 'model' whose predictions are controlled by some parameters.
        %
        % The model is
        %    log(testLum)= a + b.*log(matchRef);
        % where the parameters are
        %   a is the intercept;
        %   b is the slope of our function;
        %
        % In this context then, fitting the line consists of finding the parameters
        % a and b that bring the line as close as possible to the data we are trying
        % to fit.
        %
        % To develop this intuition a little more, we can look at how the predictions
        % depend on the parameters.  (This idea adopted from tvcTutorial).
        
        % Here are two vectors of possible parameter values for a and b
        a=[-1 -0.5 0];
        b=[0.5 1 1.5];
        
        % We can compute the matches that would be predicted by our model, given
        % each pair of these parameters and the input test luminance.  For convenience,
        % this is done by the function ComputeMatches, which simply returns the
        % points on the line that corresponds to the model above.
        for i = 1:length(a)
            matchRefResponse(:,i) = ComputeMatches(testLuminance, a(i), b(i)); %#ok<*SAGROW>
        end
        
        % We plot the data to see how the predicted matches change depending on
        % parameter values.
        figure(basicPlot);
        subplot(1,2,2); hold on
        plot(log10(testLuminance),log10(matchRefResponse),'b','LineWidth',2);
        xlabel('Log10 Test Luminance'); ylabel('Log10 Matched Reflectance'); axis('square');
        xlim([min(log10(testLuminance)),max(log10(testLuminance))]);
        ylim([min(log10(meanMatches)),max(log10(meanMatches))]);
        axis('square');
        title('Different Parameters')
        
        %% FIT DATA USING FMINCON
        % We now return to the real data. Use numerical search to find the response
        % function parameters that result in the best fit to the data.
        %
        % This is commented in some detail for fmincon, and less so for the other
        % search algorithms below.
        %
        % The function FitLinFunction computes the error to the data, given
        % the test luminance and our parameteres (intercept and slope).
        
        % Choose initial parameters.
        %
        % This is VERY important, beacause the outcome can change dramatically depending on initial parameters.
        % You may want to play with these values, and see how much are your
        % parameter values varying. You may also want to set these values by trial and error
        % in case you don't have specific assumptions about parameter values.
        %
        % In real search problems, thinking hard about how to get the intitial parameters into the
        % right ballpark is an excellent use of some brain power.  When the initial parameters are
        % off by an order of magnitude, the search algorithm generally barfs.
        a = 0.5;
        b = 0.1;
        x0 = [a b];
        
        % Set reasonable bounds on parameters
        vlb = [-10 0.01];
        vub = [10 10];
        
        % Set options
        %
        % Function optimset creates an options structure with all parameter names
        % and default values relevant to the optimization function we want to use.
        % That's why we call an option structure specifically for fmincon. The other
        % option arguments are set by hand, and are a reasonable choice for many problems.
        %   LargeScale determines something about the search algorithm, and it should be off
        %     if there aren't too many parameters.
        %   Display controls how much information the search routine prints out as it works.
        %     It can be interesting and helpful for debugging to turn it to 'iter' but that slows
        %     things down for real problems.
        %   Algorithm controls the actual algorithm used by fmincon.  Setting to 'active-set' seems
        %     to minimize warnings in recent versions of the toolbox.
        %
        % The 'UseParallel' option allows the distributed computing engine to run the objective
        % function in parallel  This is fast on the cluster if it's a big search problem.  But
        % there is overhead to it trying to do this, so if you're running without multiple processors
        % in an open matlab pool, it actually slows things down.
        %
        % There are many other options that can be set to control the behavior of fmincon, fminunc,
        % patternsearch, and ga.  See the help for each function.  Although the defaults behave
        % reasonably, there are times when you need to delve in and tweak things by hand.
        if (verLessThan('optim','4.1'))
            error('Your version of the optimization toolbox is too old.  Update it.');
        end
        options = optimset('fmincon');
        options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
        if (IsCluster && matlabpool('size') > 1)
            options = optimset(options,'UseParallel','always');
        end
        
        % Call fmincon function and we pass it following arguments:
        %  'FitLinFunction, which computes an error we want to minimize (see 'FitLinFunction.m')
        %   x0 = initial values of paramters
        %   vlb, vub = lower and upper bounds on parameter search
        %   options = defined above
        %   and variables to be passed to the error function, here test luminance and observed match reflectance
        %
        % fmincon will then do numerical search in order to find the value of parameters that, when passed
        % to our model will predict the set of matches that will be the best fit
        % (i.e. the smallest deviation) of predicted to observed matches.
        %
        % The returned value x contains a and b.  This meaning is conferred by the behavior of FitLinFunction,
        % which we wrote to use them in this way.  In general, fmincon needs its parameters in a vector and
        % the user supplied error function determines what they mean.  The same convention applies to variables
        % x0 (intial value) and vlb and vub (lower and upper bounds).
        fminconStart=tic;
        xFmincon = fmincon(@(x)FitLinFunction(x,testLuminance,allMatches),x0,[],[],[],[],vlb,vub,[],options);
        fminconTime=toc(fminconStart);
        
        %% SEARCH USING FMINUNC INSTEAD.
        %
        % DHB notes that in his experience, fminunc doesn't work as well as fmincon even for
        % unconstrained problems.  Even if you don't have any great desired to constrain the solution,
        % you can usually put some bounds on the parameters and thus pass these to fmincon.  Also,
        % setting up to use fmincon makes it easy to add constraints if you discover they'd be helpful.
        %
        % The warning suppression elimates a warning that fminunc is using an algorithm that works when
        % we don't explicitly supply a gradient.
        optionsFminunc = optimset('fminunc');
        optionsFminunc = optimset(optionsFminunc,'Display','off','Diagnostics','off');
        warning('off','optim:fminunc:SwitchingMethod');
        fminuncStart=tic;
        xFminunc = fminunc(@(x)FitLinFunction(x,testLuminance,allMatches),x0,optionsFminunc);
        fminuncTime=toc(fminuncStart);
        
        %% NOW USE PATTERNSEARCH FUNCTION, WHICH USES A DIFFERENT CLASS OF ALGORITHM.
        optionsPS=psoptimset('patternsearch');
        optionsPS=psoptimset(optionsPS,'Display','off');
        if (IsCluster && matlabpool('size') > 1)
            optionsPS=psoptimset(optionsPS,'UseParallel','always');
        end
        psStart=tic;
        xPS = patternsearch(@(x)FitLinFunction(x,testLuminance,allMatches),x0,[],[],[],[],vlb,vub,[],optionsPS);
        patternSearchTime=toc(psStart);
        
        %% USE THE GA FUNCTION, WHICH UES A GENETIC ALGORITHM.
        %
        % The genetic algorithm doesn't actually take in initial starting point.  It
        % may be a good choice for finding good starting points for other algorithms,
        % although that isn't demonstrated here.
        %
        % The specification of a mutation function appropriate for constrained optimization
        % is desirable when we pass constraints.
        optionsGA = gaoptimset('ga');
        optionsGA = gaoptimset(optionsGA,'Display','off');
        optionsGA = gaoptimset(optionsGA,'MutationFcn',@mutationadaptfeasible);
        if (IsCluster && matlabpool('size') > 1)
            gaoptimset(optionsGA,'UseParallel','always');
        end
        nParams=size(x0,2);
        gaStart=tic;
        xGA = ga(@(x)FitLinFunction(x,testLuminance,allMatches),nParams,[],[],[],[],vlb,vub,[],optionsGA);
        gaTime=toc(gaStart);
        
        %% LINEAR REGRESSION
        % Function regress finds regression coefficients for the form Y=b*X
        % In the regress function, enter (y, [ones(size(x)), x)], the column of
        % ones in the independent variable serves as a constant term (intercept).
        % the first coeff is intercept, the second is slope.
        %
        % Note that this fits a line to the mean matches, not to the individual matches.
        % Exercise for the reader -- modify to do an analytic fit to the individual matches.
        % The fact that the mean data are fit is why the error currently comes out a little
        % higher than for the search methods, I am pretty sure.
        regressStart=tic;
        [coeffs]=regress(log10(meanMatches), [ones(size(testLuminance)) log10(testLuminance)]);
        regressTime=toc(regressStart);
        intercept=coeffs(1,1);
        slope=coeffs(2,1);
        
        %% PREDICT THE MATCHES WITH A LINE, GIVEN THE RETURNED PARAMETERS.
        predictedMatchesFmincon = ComputeMatches(testLuminance,xFmincon(1),xFmincon(2));
        predictedMatchesFminunc = ComputeMatches(testLuminance,xFminunc(1),xFminunc(2));
        predictedMatchesPS = ComputeMatches(testLuminance,xPS(1),xPS(2));
        predictedMatchesGA = ComputeMatches(testLuminance,xGA(1),xGA(2));
        predictedMatchesRegress=10.^(intercept+slope*log10(testLuminance(:)));
        
        %% SAVE THE DATA
        close all
        save parameterSearchTutorial
        
        %% CLOSE MATLAB POOL
        if (NEEDTOCLOSEPOOL)
            matlabpool('close');
        end
    end
    
    % Here is the analysis part, that uses what was computed above.  When the compute part
    % may take days on the cluster, this separate makes sense.
    if (PLOT)
        
        %% LOAD THE RESULTS OF THE COMPUTE STEP
        load parameterSearchTutorial
        
        %% MAKE A PLOT
        % We now plot the predicted matches, based on the best parameter fit
        % from our numerical search. We compare these to the observed matches (all trials).
        fitFig = figure; clf; hold on
        plot(log10(testLuminance),log10(predictedMatchesFmincon),'b--','LineWidth',2);
        plot(log10(testLuminance),log10(predictedMatchesFminunc),'k--','LineWidth',2);
        plot(log10(testLuminance),log10(predictedMatchesPS),'g:','LineWidth',5);
        plot(log10(testLuminance),log10(predictedMatchesGA),'m--','LineWidth',2);
        plot(log10(testLuminance),log10(predictedMatchesRegress),'b--','LineWidth',2);
        plot(log10(testLuminance),log10(allMatches),'ro','MarkerSize',6,'MarkerFaceColor','r');
        xlabel('Log10 Test Luminance'); ylabel('Inferred Matches');
        
        %% PLOT TIME FOR EACH ALGORITHM
        timeFig=figure; clf;
        bTime=bar([fminconTime,fminuncTime, patternSearchTime, gaTime, regressTime]);
        bTimeColormap=colormap([.6 .2 .4]);
        ylim([0 , max([fminconTime, fminuncTime, patternSearchTime, gaTime, regressTime])+((max([fminconTime,fminuncTime, patternSearchTime, gaTime, regressTime])/10))]);
        axes = get(timeFig,'CurrentAxes');
        XTickLabels = {'Fmincon','Fminunc', 'Pattern Search', 'GA', 'Regression'};
        ylabel('Elapsed Time');
        set(axes,'XTickLabel',XTickLabels);
        
        %% EVALUATING THE QUALITY OF THE FIT
        % We can evaluate the quality of fit of our model by comparing the deviation
        % of obtained matches from the matches predicted by our model, and compare this
        % to some other very simple models.
        %
        % For example, for such comparisons we can use
        %     (1) a dumb model that predicts all matches by a single value obtained as
        %     the grand mean of the data
        % and
        %     (2) a minimal error model that predicts each match by its own mean (taken over
        %     replications for the same test luminance.
        
        % First, we can compute the sum of errors for our model
        % This is equal to what the fmincon(FitLinFunction) is trying to minimize.
        % It is equal to sum of squared deviations of actual matches from predicted
        % matches, with the error computed in the log domain. (note, we will use logs, because we plot on a log-log scale).
        
        % These are errors for all of our models
        modelErrorFmincon = ComputeError(allMatches, predictedMatchesFmincon);
        modelErrorFminunc = ComputeError(allMatches, predictedMatchesFminunc);
        modelErrorGA = ComputeError(allMatches, predictedMatchesGA);
        modelErrorPS = ComputeError(allMatches, predictedMatchesPS);
        modelErrorRegress=ComputeError(allMatches, predictedMatchesRegress);
        
        % This is error for a dumb model.
        dumbModel = 10.^(mean(log10(allMatches(:))))*ones(size(predictedMatchesFmincon));
        errorDumbModel = ComputeError(allMatches, dumbModel);
        
        % This is error for minimal error model (deviations of the all obsereved matches from their mean).
        minErrorModel = NaN*ones(size(predictedMatchesFmincon));
        nTrials=size(allMatches,1);
        for i=1:nTrials;
            minErrorModel(i) = 10.^mean(log10(allMatches(i,:)));
        end
        minError= ComputeError(allMatches, minErrorModel);
        
        % NOTE: when you have a more complex model than linear, simple line
        % fit can serve as one type of a "dumb" model you can compare your
        % model to (by computing the deviations of observed matches from the fitted line.
        
        % We can now plot the error size of different models and estimate
        % by eye how does each of these models relate to others.
        errFig=figure; clf;
        bErr=bar([minError, modelErrorFmincon, modelErrorFminunc, modelErrorPS, modelErrorGA, modelErrorRegress, errorDumbModel]);
        bErrColormap=colormap([.4 .7 .7]);
        ylim([0 , max([minError, modelErrorFmincon, modelErrorFminunc, modelErrorPS, modelErrorGA, modelErrorRegress, errorDumbModel])+((max([minError, modelErrorFmincon, modelErrorPS, modelErrorGA, modelErrorRegress, errorDumbModel])/10))]);
        axes = get(errFig,'CurrentAxes');
        XTickLabels = {'Min Error', 'Fmincon', 'Fminunc','PS', 'GA', 'Regress','Dumb'};
        ylabel('Error Size');
        set(axes,'XTickLabel',XTickLabels);
    end
    
%% Close Matlab pool on error
catch theErr
    if (NEEDTOCLOSEPOOL)
        matlabpool('close');
    end
    rethrow(theErr);
end

end