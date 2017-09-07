% colorSpaceExample
%
% Let's just do camera RGB to LMS in a few different
% ways.
%
% 1/19/06   dhb, pg, ly  Wrote.

% Load some example data files
clear;
S = [400 10 31];
load T_DCS200
T_camera = SplineCmf(S_DCS200,T_DCS200,S);

load B_vrhel
load spd_D65
B_color = diag(SplineSpd(S_D65,spd_D65,S))*SplineSpd(S_vrhel,B_vrhel(:,1:3),S);

load T_cones_ss2
T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,S);

% Make up some RGB values
RGB = [ [1 1 1]' , [1 0 0]', [0 1 0]' , [0 0 1]' ];

% First method.  Find best linear transformation between
% camera sensitivities and cones, and apply this.
M = ((T_camera')\(T_cones'))';
% figure; clf; hold on
% T_cones_fit = M*T_camera;
% plot(T_cones','k');
% plot(T_cones_fit');
LMS_est1 = M*RGB;

% Second method.  Go from RGB to basis weights,
% then from basis weights to LMS.
M_RGBToBasis = inv(T_camera*B_color);
M_BasisToLMS = T_cones*B_color;
LMS_est2 = M_BasisToLMS*M_RGBToBasis*RGB;

% How to go from LMS to spectra
M_LMSToBasis = inv(M_BasisToLMS);
M_LMSToSpectra = B_color*M_LMSToBasis;
spectra = M_LMSToSpectra*LMS_est2;

