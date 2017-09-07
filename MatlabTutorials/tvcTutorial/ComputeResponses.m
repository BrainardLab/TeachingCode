function responses = ComputeResponses(intensities,rMax,g,n)
%% responses = ComputeResponses(intensities,rMax,g,n)
% 
% Compute the response from the intensities.  Just a simple Naka-Rushton
% function.  Our goal will be in infer the parameters of a response
% function of this form from the data.
%
% 6/20/06   dhb, sra     Wrote it.
% 6/22/06   dhb          Pulled out as a function.

gIToTheN = (g*intensities).^n;
responses = rMax * (gIToTheN ./ (gIToTheN+1));
