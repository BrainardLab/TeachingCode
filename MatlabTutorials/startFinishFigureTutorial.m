% startFinishPlotTutorial
%
% Work out how tone mapping should operate on an LMS image.
%
% 1/5/09  dhb, kmo   Wrote it up.


%% Generate some functions to plot.  It doesn't matter what for 
% purposes of thinking about plot format.
S = [380 4 101];
wls = SToWls(S);
load T_xyzJuddVos ;
T_xyz = 683*SplineCmf(S_xyzJuddVos,T_xyzJuddVos,S);
load T_cones_ss2;
T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,S);
MConesToXYZ = ((T_cones')\(T_xyz'))';
MXYZToCones = inv(MConesToXYZ);
T_check = MXYZToCones*T_xyz; %#ok<MINV>

%% This illustrates basic use of Brainard Lab
% StartFigure and FinishFigure routines.
[checkPlot,f] = StartFigure('standard');
f.xrange = [350 800]; f.nxticks = 10;
f.yrange = [0 1]; f.nyticks = 6;
f.xtickformat = '%d'; f.ytickformat = '%0.1f ';

plot(wls,T_cones(1,:)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
plot(wls,T_cones(2,:)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
plot(wls,T_cones(3,:)','bo','MarkerSize',f.basicmarkersize,'MarkerFaceColor','b');
plot(wls,T_check(1,:)','r','LineWidth',f.smalllinewidth);
plot(wls,T_check(2,:)','g','LineWidth',f.smalllinewidth);
plot(wls,T_check(3,:)','b','LineWidth',f.smalllinewidth);

xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('Check Transform Matrix','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(checkPlot,f);
