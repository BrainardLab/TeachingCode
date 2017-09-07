function output = SimpleGammaCorrection(nLevels,gammaInput,gamma,input)
% output = SimpleGammaCorrection(nLevels,gammaInput,gamma,input)
%
% Perform gamma correction by exhaustive search.  Just to show idea,
% not worried about efficiency.
%
% 9/14/08  ijk  Wrote it.
% 12/2/09  dhb  Update for [0,1] input table.

min_diff = Inf;
for i=1:nLevels
    currentdiff = abs(gamma(i)-input);
    if(currentdiff < min_diff)
        min_diff = currentdiff;
        output = i;
    end
end
output = gammaInput(output);