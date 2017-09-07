% SNREstTest
%
% Try to understand sensor optimization a little better.  This is written to explore
% the two pixel two color case.
%
% x is a four vector, with the first two entries being the first pixel, and the second
% two the second pixel.
%
% We keep everything symmetric between the color bands, and just muck with the spatial
% and color correlation, and the overall light intensity.
% 
% I'm pretty sure this got written as we were making early sense of the pixelWorld
% project.
%
% 2/29/08  dhb  Wrote it.

% Clear
clear all
close all

% Parameters
Kn0 = [1  0 ; 0 1];                             % Baseline noise covariance.
un = [1 1]';                                    % Noise mean.  This doesn't affect calculation but must be defined.
ux = [1 1 1 1]';                                % Signal mean.  As with noise mean, doesn't affect calculation.

% There are really only two distinct sensor arrangements, monochrome (T1) or color (T2).
blur = 0.25;
T1 = [1-blur blur 0 0 ; blur 1-blur 0 0];
T2 = [1-blur blur 0 0 ; 0 0 blur 1-blur];
T3 = [1-blur blur 0 0 ; 0 0 1-blur blur];

% Define correlations and light intensities to study
theSpatialCorrs = linspace(0.01,0.99,10);
theColorCorrs = linspace(0.01,0.99,10);
theAlphas = linspace(0.00001,100,100);

% Compute error for all crossings of correlations
for i = 1:length(theSpatialCorrs)
    rs = theSpatialCorrs(i);
    for j = 1:length(theColorCorrs)
        rc = theColorCorrs(j);

        % Define basic signal covariance.  This is just done by hand for the
        % two pixel two color case we're considering.  I think I've got this
        % right.
        Kx0 = [1 rs rc rs*rc ; rs 1 rs*rc rc ; rc rs*rc 1 rs ; rs*rc rc rs 1];

        % Do all light intensities for these correlations
        for k = 1:length(theAlphas)
            alpha = theAlphas(k);

            % Noise variance is dark noise plus term proportional to
            % light intensity
            Kn = (1+alpha)*Kn0;

            % Signal variance goes as the square of the light intensity
            Kx = (alpha^2)*Kx0;

            % Compute expected error for the two sensor arrangements.
            % Note that ux and un aren't actually used the underlying
            % routine.  They're there because the design of the toolbox
            % was to use uniform calling across the various computations
            % within a model.
            postCov1{i,j,k} = BayesMvnNormalPosteriorCov(T1,ux,Kx,un,Kn);
            postCov2{i,j,k} = BayesMvnNormalPosteriorCov(T2,ux,Kx,un,Kn);
            var11(i,j,k) = postCov1{i,j,k}(1,1);
            var21(i,j,k) = postCov1{i,j,k}(3,3);

            var12(i,j,k) = postCov2{i,j,k}(1,1);
            var22(i,j,k) = postCov2{i,j,k}(2,2);
            err1(i,j,k) = BayesMvnNormalExpectedSSE(T1,ux,Kx,un,Kn);
            err2(i,j,k) = BayesMvnNormalExpectedSSE(T2,ux,Kx,un,Kn);
            err3(i,j,k) = BayesMvnNormalExpectedSSE(T3,ux,Kx,un,Kn);
        end
    end
end

% Make plots, and run through them.
fig1 = figure;
fig2 = figure;
for i = 1:length(theSpatialCorrs)
    for j = 1:length(theColorCorrs)
        fprintf('i = %d, j = %d, rs = %g, rc = %g\n',i,j,theSpatialCorrs(i),theColorCorrs(j));
        theDiffs1 = squeeze(err1(i,j,:)-err2(i,j,:));
        theDiffs2 = squeeze(err1(i,j,:)-err3(i,j,:));
        %if (any(theDiffs1 < -1e-12))
        %    fprintf('\tSome diffs less than 0\n');
        %end
        %if (any(theDiffs1 > 1e-12))
        %    fprintf('\tSome diffs greater than 0\n');
        %end

        figure(fig1); clf;
        subplot(1,2,1); hold on;
        plot(theAlphas,squeeze(err1(i,j,:)),'k');
        plot(theAlphas,squeeze(err2(i,j,:)),'r');
        %plot(theAlphas,squeeze(err3(i,j,:)),'g');

        subplot(1,2,2); hold on
        plot(theAlphas,theDiffs1,'r');
        %plot(theAlphas,theDiffs2,'g');
        %negIndex = find(theDiffs1 < 0);
        %if (~isempty(negIndex))
        %    plot(theAlphas(negIndex),theDiffs1(negIndex),'g');
        %end
        %xlim([0 .2]); ylim([-0.01 .01]);

        figure(fig2); clf;
        subplot(1,2,1); hold on
        plot(theAlphas,squeeze(var11(i,j,:)),'k');
        plot(theAlphas,squeeze(var12(i,j,:)),'r');
        subplot(1,2,2); hold on
        plot(theAlphas,squeeze(var21(i,j,:)),'k');
        plot(theAlphas,squeeze(var22(i,j,:)),'r');

        pause;
    end
end
