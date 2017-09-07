%% pcn 9/07  poissonSetup.m
% this function sets up the vector distrBins, which can then be used
% to generate random integers in a Poisson distribution:
% a. this function poissonSetup(Q) prepares the vector distrBins
% b. to use it in your main routine, initialize with:
% dist=poissonSetup(2)
% (The argument selects the desired mean.) Then say:
% [n,k]=histc(rand,dist)
% which returns 
% k = a sample from the distribution, plus 1 
% (and n = array with zeros except for bin #k)
%
%%
function distrBins=poissonSetup(r);
topBin=max([10 round(10*r)]);
tmpBins(1)=0;
running=exp(-r);
tmpBins(2)=running;
for m=1:(topBin-2);
    running=running*r/m;
    tmpBins(m+2)=running; end;
distrBins=cumsum(tmpBins);
return;