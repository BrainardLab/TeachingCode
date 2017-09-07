% IteratedLearningTutorial
%
% See if the iterated learning procedure converges to the prior, for 
% a simple example.
% 
% This checks a theorem quoted in Kalish, Griffiths, and Lwwandowsky
% (2007), Psych. Bulletin and Review,288-294.  The theorem seems to
% hold, although with a model of memory where what you recall is based
% on a draw from the posterior (METHOD 0 below), rather than your best
% guess based on the posterior (METHOD 1 below).  METHOD 1 seems like 
% a more natural model of performance to me, at least in the sense that
% it's what I coded from first principles.  
%
% 12/18/08  dhb  Wrote it.

%% Clear
clear; close all;

%% Parameters
priorMean = 10;
priorSd = 5;
memoryNoiseSd = 5;
startingMean = 0;
startingSd = 20;
nSubjectsPerChain = 10;
nChains = 2000;

%% Simuluate an interative learning experiment over and
% over.
guesses = zeros(nChains,nSubjectsPerChain+1);
for chain = 1:nChains
    % Choose a random starting stimulus
    guesses(chain,1) = BayesMvnNormalPriorDraw(1,startingMean,startingSd^2);
    
    % Simulate chain of observers
    for subject = 1:nSubjectsPerChain
        % Retrieve trained stimulus from memory, which is noisy
        memory = guesses(chain,subject) + BayesMvnNormalNoiseDraw(1,0,memoryNoiseSd^2);
        
        % Guess what stimulus was, based on memory trace and prior
        METHOD = 1;
        switch (METHOD)
            case 0,
                % Guess is a draw from a posterior.  This seems to be the
                % model that the theorem applies to.
                guesses(chain,subject+1) = BayesMvnNormalPosteriorDraw(1,memory,1,priorMean,priorSd^2,0,memoryNoiseSd^2);
            case 1,
                % Guess is posterior mean.  This is how I'd build a memory
                % model
                guesses(chain,subject+1) = BayesMvnNormalPosteriorMean(memory,1,priorMean,priorSd^2,0,memoryNoiseSd^2);
            otherwise
                error('Unknown modeling method');
        end
    end
end

% Make a figure that shows distribution of end points along with prior
figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',14);
binCenters = linspace(priorMean - 4*priorSd, priorMean + 4*priorSd,30);
hist(guesses(:,nSubjectsPerChain+1),binCenters);
predicted = nChains*BayesMvnNormalPriorProb(binCenters,priorMean,priorSd^2)*(binCenters(2)-binCenters(1));
xlabel('Value','FontName','Helvetica','FontSize',18); ylabel('Probability','FontName','Helvetica','FontSize',18);
plot(binCenters,predicted,'r','LineWidth',2);
saveas(gcf,'ConvergedDistribution.png','png');

% Just the prior
figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',14);
plot(binCenters,predicted,'r','LineWidth',2);
xlabel('Value','FontName','Helvetica','FontSize',18); ylabel('Probability','FontName','Helvetica','FontSize',18);
saveas(gcf,'PriorDistribution.png','png');

% Explanatory figure of prior plus posterior, for a given observation.
desired = -5;
memory = desired + BayesMvnNormalNoiseDraw(1,0,memoryNoiseSd^2);
posterior = nChains*BayesMvnNormalPosteriorProb(binCenters,memory,1,priorMean,priorSd^2,0,memoryNoiseSd^2)*(binCenters(2)-binCenters(1));
plot(binCenters,posterior,'b','LineWidth',2);
plot([desired desired],[0 100],'g');
plot([memory memory],[0 100],'k');
saveas(gcf,'PosteriorDistribution.png','png');


% Explanatory figure of just memory locations
figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',14);
plot([desired desired],[0 100],'g');
plot([memory memory],[0 100],'k');
axis([-10 30 0 350]);
xlabel('Value','FontName','Helvetica','FontSize',18); 
saveas(gcf,'MemoryLocations.png','png');

% Add prior to above graph
plot(binCenters,predicted,'r','LineWidth',2);
xlabel('Value','FontName','Helvetica','FontSize',18); ylabel('Probability','FontName','Helvetica','FontSize',18);
saveas(gcf,'MemroyWithPriorDistribution.png','png');
