function computedMatches = ComputeMatches(testLuminance,a,b)
% computedMatches = ComputeMatches(testLuminance,a,b)
%
% Computes matches from test luminance assuming simple linear regression function
% in the log-log domain.  Note, however, that the predictions are then returned
% in linear (anti-logged) units.
%
% For the purpose of this excercise, linear regression function is our model of mapping 
% test luminance to match reflectance.  
%   log(matchRef) = a + b*log(testLum) 
% 
% 2/24/10   ar           Adapted the function to predict reflectance matches 
%                        given test luminance from ComputeResponse function
%                        written by DHB and SRA. 
% 3/11/10   dhb, ar      Small cosmetic changes.

logTestLum = log10(testLuminance);
logComputedMatches = a + b.*logTestLum;
computedMatches=10.^logComputedMatches; 
end


