function error = SearchRotateScaleFun(x,centeredInData,centeredTargetData,FLIP)
% error = SearchRotateScaleFun(x,centeredInData,centeredTargetData,FLIP)
% 
% Error function for the mapping search
%
% 11/11/05  dhb, scm     Wrote it.

theta = x(1);
scale = x(2);
translate = x(3:4)';
mappedData = RotateScaleFlip(centeredInData,theta,scale,FLIP) + translate*ones(1,size(centeredTargetData,2));
error = ComputeMapError(centeredTargetData,mappedData);