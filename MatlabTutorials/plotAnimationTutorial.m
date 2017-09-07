% plotAnimationDemo.m
%
% This codelet demonstrates how to make GIF animations with MATLAB of 
% time-varying signals. 
%
% The code makes direct calls to 'mogrify' (part of ImageMagick) and 'gifsicle'.
% These programs need to be installed (e.g. via MacPorts). See 
% http://www.imagemagick.org/ and http://www.lcdf.org/gifsicle/.
%   a) Install MacPorts if you don't already have it.
%   b) Install XCode if you don't already have it.  Go to 
%      preferences/downloads in XCode and install the command line tools.
%   c) Log into an admin account on the computer.  Open a terminal window.
%   d) Run "sudo port install ImageMagick"
%   e) Run "sudo port install gifsicle"
%
% t is useful to know that some programs have difficulty displaying the GIFs in that method.
% Generally, they are displayed properly in Firefox and as part of mails in the OS X mail program,
% but Safari and Preview don't seem to like the GIFs The gifsicle developers point out that the problem
% lies in the Safari implementation of the GIF standard.

% 1/9/13    mspits      Wrote it.
% 1/11/13   mspits      Fixed some path problems.

% Clear and close all
clear all; close all

% File names
fileNameBase = 'plots';
outFileName = 'plotAnimationTutorial.gif';

% GIF animation properties
delayTime = 10; % Delay of each frame in 1/100 of a sec 

% Go to /tmp
currDir = pwd;
cd('/tmp')

% Generate a "signal" (sine/cosine), and corrupt it with noise
steps = 100;
x = linspace(0, 2*pi-2*pi/steps, steps);
y1 = sin(x);
y1noise = y1+0.05*randn(1, steps);
y2 = cos(x);
y2noise = y2+0.05*randn(1, steps);

% Open figure
figure;

% Iterate over the signal and plot it
for i = 1:steps
    % Plot sine
    subplot(1, 2, 1);
    % Note that the index leads to drawing the signal up to the ith position 
    % in thh signal vector
    plot(x(1:i), y1(1:i), '--k');
    hold on;
    plot(x(1:i), y1noise(1:i), '-b');
    hold off;
    
    xlabel('Time');
    ylabel('Signal');
    
    % Set axes properties. It is important to do this, because otherwise, 
    % the axis limits will be different in every iteration of drawing
    set(gca,'XLim',[0 2*pi]);
    set(gca,'YLim',[-1.2 1.2]);
    title('Sine function');
    pbaspect([1 1 1]);
    
    % Plot cosine
    subplot(1, 2, 2);
    plot(x(1:i), y2(1:i), '--k');
    hold on;
    plot(x(1:i), y2noise(1:i), '-r');
    hold off;
    
    xlabel('Time');
    ylabel('Signal');
    
    set(gca,'XLim',[0 2*pi]);
    set(gca,'YLim',[-1.2 1.2]);
    title('Cosine function');
    pbaspect([1 1 1]);
    
    % Set the position of the plot on the canvas and the paper size
    set(gcf, 'PaperPosition', [0 0 12 6]);
    set(gcf, 'PaperSize', [12 6]);
    
    % Save the plot as PNG
    saveas(gcf, [fileNameBase '-' sprintf('%04d',i) '.png'], 'png');
end

% Make sure gifsicle and morgify can be found in the path
oldPath = getenv('PATH');
if isempty(strfind(oldPath, '/opt/local/bin')) && isdir('/opt/local/bin')
    setenv('PATH', [oldPath ':/opt/local/bin']);
end

% Set the DYLD library path to empty, so that we can run mogrify
oldLibPath = getenv('DYLD_LIBRARY_PATH');
setenv('DYLD_LIBRARY_PATH', '');

% Convert the resulting PNG files to GIF by calling mogrify
[status, result] = system(['mogrify -format gif ' fileNameBase '-*.png']);

% Check for error
if status ~= 0
    disp('WARNING: mogrify failed.');
    disp(['Error message: ', result]);
end

% Loop the resulting GIF files with gifsicle
[status, result] = system(['gifsicle --loopcount=0 --delay ' num2str(delayTime) ' ' fileNameBase '*.gif > ' fullfile(currDir, outFileName)]);

% Check for error
if status ~= 0
    disp('WARNING: gifsicle failed.');
    disp(['Error message: ', result]);
end

% Revert changes we made to the path
setenv('PATH', oldPath);
setenv('DYLD_LIBRARY_PATH', oldLibPath);

cd(currDir);
