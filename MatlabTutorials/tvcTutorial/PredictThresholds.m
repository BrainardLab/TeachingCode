function predictedThresholds = PredictThresholds(pedestalIntensities,rMax,g,n)
%% predictedThresholds = PredictThresholds(pedestalIntensities,rMax,g,n)
%
% Compute predicted thresholds on the assumption that threshold occurs when
% the response difference between pedestal alone and pedestal plus
% predicted threshold is one.  We can set the criterion to one without
% lossped of generality because rMax absorbs the effect of changing criterion.
%
% 6/20/06  dhb, sra  Wrote it.
% 6/22/06  dhb       Separate function.
%          dhb       Handle case of saturation by returning Inf.

nPedestals = length(pedestalIntensities);
predictedThresholds = zeros(size(pedestalIntensities));
for i = 1:nPedestals
    % This is an analytic inversion of the response function find desired
    % input to produce desired response.
    pedestalResponse = ComputeResponses(pedestalIntensities(i),rMax,g,n);
    thresholdResponse = pedestalResponse+1;
    if (thresholdResponse > rMax)
        predictedThresholds(i) = Inf;
    else
        gIToTheN = (thresholdResponse/rMax)/(1-thresholdResponse/rMax);
        gI = gIToTheN.^(1/n);
        I = gI/g;
        predictedThresholds(i) = I-pedestalIntensities(i);
    end
end




