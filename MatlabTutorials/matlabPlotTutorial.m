% matlabPlotTutorial
%
% Little examples of how to tune plots in Matlab
%
% 8/18/09  dhb  Started on it.

%% Clear
clear; close all;

%% Define some simple data to plot
x = linspace(0,1,100);
y = sin(2*pi*x);
xPoints = linspace(0,1,10);
yPoints = sin(2*pi*xPoints);

%% Open up basic Matlab plot
%
% This shows how to control line width, set custom colors for points, and
% control the outline and interior color of a point separately, as well as control
% the thickness of the point outline. (I don't make points like this, they
% are pretty ugly.  But I wanted to show the separate control of these
% aspects.)
%
% The font and font size values passed after the figure is open set the
% default for text in the figure.
theFig = figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',12);
plot(x,y,'r','LineWidth',2);
thePoints = plot(xPoints,yPoints,'o','Color',[0.0 0.7 0.0],'MarkerFaceColor',[0.5 0.5 0.5]);
set(thePoints,'MarkerSize',8,'LineWidth',1);

%% Directly set where the axis tick marks show up and control the
% format of the labels.
xLower = 0; xUpper = 1; nXTicks = 6; 
yLower = -1; yUpper = 1; nYTicks = 5;
xlim([xLower xUpper]); ylim([yLower yUpper]);
xTicks = linspace(xLower,xUpper,nXTicks);
yTicks = linspace(yLower,yUpper,nYTicks);

%% Format the labels for each tick.  Note the use of the
% trailing space in the format string for the y-axis ticks.
% This has the effect of moving the text slightly to the 
% left, and reduces the overlap between the tick labels
% between the two axes near the origin.
%
% I think this method works well enough for most things.  If
% you want to get really fancy, I think you need to move to
% using the text() function directly, in which case you can
% put each label directly where you want it, and also use
% LaTex to format the strings. But that's a lot of fussing.
xTickLabel = cell(size(xTicks));
for i = 1:length(xTicks)
    xTickLabel{i} = sprintf('%0.1f',xTicks(i));
end
yTickLabel = cell(size(yTicks));
for i = 1:length(yTicks)
    yTickLabel{i} = sprintf('%0.1f ',yTicks(i));
end
set(gca,'XTick',xTicks,'XTickLabel',xTickLabel);
set(gca,'YTick',yTicks,'YTickLabel',yTickLabel);
xlabel('X axis','FontName','Helvetica','FontSize',16);
ylabel('Y axis','FontName','Helvetica','FontSize',16);

%% Add grids if you like them
set(gca,'XGrid','on','YGrid','on');

%% If you want to save your plot, then use the saveas command.
saveas(theFig,'matlabPlotTutorial.png','png');


