% silentSubstitutionTutorial.
%
% Show how to find cone isolating directions using mixtures of
% monitor primaries.
%
% This first illustrates how to do the computation from first principles,
% and then shows how it is done using PTB and BrainardLabToolbox routines,
% verifying that the different ways yield the same answer.
%
% Input data (these are read by the tutorial):
%   - Monitor primaries natrix B_monitor
%   - SPD of background light spd_bg = B_monitor * [0.5 0.5 0.5]'
%   - Cone spectral sensitivities.  Here we read Smith-Pokorny fundamentals T_cones_sp
%   - Constraint on t_test 0 <= t_test <= 1
%
% This produces:
%   - SPD of test lights s.t. t_cones_sp_test - t_cones_sp_bg = [k 0 0]', [0 k 0]', [0 0 k]'
%               t_cones_sp_test = T_cones_sp * B_monitor * t_test
%               t_cones_sp_bg = T_cones_sp * spd_bg
%   - Largest k and its corresponding spd_test = B_monitor * t_test
%
% Naming convention:
%   t_xx : the tristimulus value corresponding to the monitor primaries
%   t_cones_sp_xx : the tristimulus value corresponding to the SP cone fundamentals. 
%
% 8/22/13  ll   Wrote it.
% 8/27/13  ll   Clean up and add 2 more methods
% 8/28/13  dhb  Tidied up a little.  Mostly comments and plot labels.

%% Clear and close
clear; close all

%% Load SP color matching function response
load T_cones_sp

%% Define wavelengths sampling to be used for
% everything else below as that from the SP
% file.
S = S_cones_sp;
wls = SToWls(S);

%% Load the monitor primaries and spline wavelength sampling
load B_monitor
B_monitor = SplineSpd(S_monitor,B_monitor,S);

%% Set the background light
t_bg = [0.5 0.5 0.5]';
spd_bg = B_monitor * t_bg;
t_cones_sp_bg = T_cones_sp * spd_bg;

%% Find the transformation matrices to map between the monitor and SP cones color space
M_MonitorToConesp = T_cones_sp * B_monitor;
M_ConespToMonitor = inv(M_MonitorToConesp);

%% Find the SPD of the light to stimulate the L, M and S cones separately
%
% We start with an arbitrary choice of k and find the isolating directions.
% Then we find the biggest k we can get within monitor gamut below.
%
% This produces one spectrum for each cone class.
k = 1;
t_cones_sp_diff = [k 0 0; 0 k 0; 0 0 k]; % the desired response for L, M and S cones
t_test = M_ConespToMonitor * (t_cones_sp_diff + repmat(t_cones_sp_bg,1,size(t_cones_sp_diff,2)));
spd_test = B_monitor * t_test;
figure;
plot(wls,spd_test)
title('Spectral power distribution of L, M, and S cone isolating modulations')
xlabel('Wavelength (nm');
ylabel('Power (arbitrary units)');

%% Find the largest k in the L cone isolation [k 0 0]'
% We need to find the t_test in equation
%   M_MonitorToConesp * t_test - t_cones_sp_bg = [k 0 0]'
% such that k is maximum and 0 <= t_test(i) <= 1
%
% This can be formulated as a constrained linear optimization problem, and solved
% using the linprog function in Matlab.
%
% This code just does the calculation for the L cone isolating direction (the first of the
% three computed above).
%
% Solve the constrained optimization problem
%   Maximize        k = a*t_test(1) + b*t_test(2) + c*t_test(3) - t_cones_sp_bg(1)
%   Constraints:    d*t_test(1) + e*t_test(2) + f*t_test(3) = t_cones_sp_bg(2)
%                   g*t_test(1) + h*t_test(2) + k*t_test(3) = t_cones_sp_bg(3)
%                   0 <= t_test(i) <= 1                  
% 	where   t_test(i): independent varibles 
%           a,b,c,d,e,f,g,h,k: constants from entries of M_MonitorToConesp 
f = - M_MonitorToConesp(1,1:3)'; % minus sign to convert max to min problem
Aeq = M_MonitorToConesp(2:3,:);
beq = [t_cones_sp_bg(2),t_cones_sp_bg(3)];
lb = zeros(3,1);
ub = ones(3,1);
[t_test_max_linprog,fvalue,exitflag] = linprog(f,[],[],Aeq,beq,lb,ub);

% Display the result
k_max_linprog = -fvalue - t_cones_sp_bg(1);
spd_test_max = B_monitor * t_test_max_linprog;
LconeInGamutFig = figure; clf; hold on
plot(wls,spd_test_max,'r','LineWidth',3);
title('Spectral power distribution of max in gamut L-cone isolating modulation');
xlabel('Wavelength (nm)');
ylabel('Power (arbitrary units)');
fprintf('Maximum value of k for L-cone isolation (lin prog method): %0.4f\n',k_max_linprog);

%% Use the analytic solution for k via PTB function MaximizeGamutContrast
%
% This is done just for the L cone isolating direction, which for fun is recomputed
% here.  
%
% This gives the same answer as the linear programming solution above, which it should.
t_cones_sp_dir = [1 0 0]'; % direction to maximize 
t_cones_sp_test_dir = t_cones_sp_bg + t_cones_sp_dir;
t_test_dir = M_ConespToMonitor * t_cones_sp_test_dir;
t_dir = t_test_dir - t_bg;
k_max_analytic = MaximizeGamutContrast(t_dir,t_bg);
fprintf('Maximum value of k for L-cone isolation via MaximizeGamutContrast: %0.4f\n',k_max_analytic);

%% Find isolating direction using BrainardLabToolbox function ReceptorIsolate.
%
% This function has lots of bells and whistles, and dealsw with the case where the number
% of primaries exceeds the number of cone classes, as well as allowing other constraints
% to be imposed.  See ReceptorIsolateDemo (in the BrainardLabToolbox) for more on this.
%
% Here we verify that it gives the same answer for the L cone isolating direction
% as our from scratch computations above, when we match the conditions.
%
% Set up the parameters
T_receptors = T_cones_sp;
whichReceptorsToIsolate = 1;        % isolate the L cone
whichReceptorsToIgnore = [];
B_primary = B_monitor;              % device primaries
backgroundPrimary = t_bg; 
initialPrimary = t_bg;              % take background as initial guess
whichPrimariesToPin = [];
primaryHeadRoom = 0;                % go to the full gamut
maxPowerDiff = Inf;                 % No smoothness constraint
t_test_max_receptorIsolate = ReceptorIsolate(T_receptors,whichReceptorsToIsolate,whichReceptorsToIgnore,B_primary,backgroundPrimary,initialPrimary,whichPrimariesToPin,primaryHeadRoom,maxPowerDiff);

% Add to previous plot.  Should (and does) overlay what was plotted there.
spd_test_max_receptorIsolate = B_monitor * t_test_max_receptorIsolate;
figure(LconeInGamutFig);
plot(wls,spd_test_max_receptorIsolate,'k:','LineWidth',2);

% Find k as L cone component of cone responses to isolating direction at max contrast.  Should (and does)
% match the k values we found the other ways.
k_max_receptorIsolate = M_MonitorToConesp(whichReceptorsToIsolate,:) * (t_test_max_receptorIsolate - t_bg);
fprintf('Maximum value of k for L-cone isolation via function ReceptorIsolate: %0.4f\n',k_max_receptorIsolate);

