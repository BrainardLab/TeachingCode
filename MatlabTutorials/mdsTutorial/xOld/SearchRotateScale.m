function [theta,scale,translate] = SearchRotateScale(theta0,scale0,translate0,centeredInData,centeredTargetData,FLIP)
% [theta,scale,translate] = SearchRotateScale(theta0,scale0,translate0,centeredInData,centeredTargetData,FLIP)
%
% Use numerical search to find the theta and scale parameters taht map the
% inData as close as possible to the target data.
%
% 11/11/05  dhb, scm      Wrote it
% 2/9/06    scm, dhb    Relax angle bounds on search to allow wrap

% Set search options
options = optimset;
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off');

% Do the search
x0 = [theta0,scale0,translate0'];
x = fmincon('SearchRotateScaleFun',x0,[],[], ...
        [],[],[-360 0 -1e6 -1e6],[720 1e10 1e6 1e6],[],options,centeredInData,centeredTargetData,FLIP);

% Extract the parameters
theta = x(1);
scale = x(2);
translate = x(3:4)';