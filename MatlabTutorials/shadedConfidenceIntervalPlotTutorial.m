% shadedConfidenceIntervalPlotTutorial.m
%
% This script shows how to make a plot where a confidence interval is shaded.
% It is a bit primative in its current form, but could be tuned up as an example.
%
% 11/16/12  Varsha Shankar    Wrote it.
% 07/22/13  dhb               Added to lab tutorials, and added a few comments.

%% Clear and close
clear; close all;

%% Define some intervals.
data1 = [
   90.9446   91.1393
   90.9402   91.0803
   90.6      91.0324
   90.7      91.0564
   90.8823   91.0184
   90.9276   91.0584
   90.9256   91.0647
   90.8157   90.9888
   90.9431   91.0846
   90.9009   91.0696
   90.9442   91.0836
   90.9079   91.0638
   90.8945   91.0257
   90.8912   91.0450
   90.9353   91.0958
   90.9625   91.0997
   90.9436   91.1072
   90.9133   91.0554
   90.9265   91.0569
   90.8943   91.0333];

data2 = [
   90.9550   91.1340
   90.9424   91.0763
   90.9020   91.0204
   90.9152   91.0462
   90.8800   91.0106
   90.9257   91.0649
   90.9305   91.0609
   90.8231   90.9803
   90.9421   91.0806
   90.9105   91.0706
   90.9532   91.0764
   90.9146   91.3
   90.8876   91.4
   90.9013   91.2
   90.9313   91.1000
   90.9614   91.0995
   90.9474   91.1126
   90.9197   91.0606
   90.9397   91.0429
   90.8950   91.0354];

%% Make a plot of the theory confidence intervals.
% The key is the fill command in Matlab
figure; clf; hold on
dim = get(gcf,'position');
set(gcf,'position',dim .* [1 1 2 2]);
lower = data1(:,1);
upper = data1(:,2);
num_elements = length(upper);
x = (1:num_elements)';
fillFig = fill([x;flipud(x)],[upper;flipud(lower)],'k');

%% Add the bootstrap confidence intervals
lower = data2(:,1);
upper = data2(:,2);
fill([x;flipud(x)],[upper;flipud(lower)],'m');

%% Fuss a little
% The effect can be modulated with
% the camera/lighting commands, although perhaps
% not to good effect
%camlight; lighting gouraud;

% The alpha parameter is applied to the current axis
% and affects the transparency of the bands.
% I'm sure there is a way to fuss with their color.
alpha(0.2);

%% Basic figure settings and tidying
set(gca,'FontName','Helvetica');
set(gca,'FontSize',28);
set(gca, 'ylim', [90 92]);
set(gca, 'ytick', [90 91 92]);
set(gca, 'xlim', [0 num_elements+1]);
xlabel('Simulation Number');
ylabel('Y Value');
lg = legend('Data Set 1','Data Set 2','Location','NorthWest');
set(lg,'FontSize',28);
title('Example Plot','FontSize',30);
grid on;
