function TestPredictNRAffineMatches
% TestPredictNRAffineMatches
%
% Work out what the little model does for various choices of input
%
% 12/4/10 dhb  Wrote it.
% 4/20/11 dhb  Lot's of little changes.  Switch polarity of data plots

%% Clear
clear; close all;

%% Choose model parameters and generate predictions, plot.
% Let's one explore what the model can do.
DO_PRELIM_STUFF = 0;
if (DO_PRELIM_STUFF)
    yRef = logspace(-2,4);
    
    %% Set up parameters
    params0.rmaxRef = 1.0;
    params0.gainRef = 10e-4;
    params0.offsetRef = 0;
    params0.expRef = 2.5;
    params0.rmax = 1.01;
    params0.gain =  0.5*10e-4;
    params0.offset = 1;
    params0.exp = 1;
    
    %% Plot effect of mucking with exponent
    figure; clf; hold on
    exponents = [1.5 2 2.5];
    for i = 1:length(exponents)
        params0.exp = exponents(i);
        yMatch{i} = PredictNRAffineMatches(yRef,params0);
        
        % Plot
        plot(log10(yMatch{i}),log10(yRef),'k','LineWidth',3);
        xlim([-3 5]); ylim([-3 5]);
        xlabel('Log10 Target Lum');
        ylabel('Log10 Standard Lum/Refl');
    end
end

%% Fit some matching data
SARAH_TEST_DATA = 0;
if (SARAH_TEST_DATA)
    someData = [ ...
        %[-1.4666   -1.3279   -1.1376   -1.0155   -0.8727   -0.7791   -0.6807   -0.6039   -0.5046   -0.4332   -0.3622 -0.3050   -0.2280   -0.1671   -0.0941   -0.0472]; ...
        -0.3425   -0.1963    0.0211    0.2595    0.4734    0.5964    0.8080    0.9776    1.1431    1.3214    1.4757    1.6494    1.8117    1.9341    2.0687    2.1320;...
        NaN   -0.7632   -0.6575   -0.4410   -0.3869   -0.2870   -0.0619   -0.0495    0.1377    0.3261    0.5331    0.8137    1.0949    1.2788    1.4755    1.7163;...
        -0.8488   -0.6492   -0.3507   -0.1405    0.0320    0.1059    0.5055    0.5369    0.6712    0.9123    1.1550    1.4602    1.6382    1.7404    1.9184    2.0872;...
        -0.7557   -0.5774   -0.3305   -0.0248    0.1117    0.4900    0.5283    0.7715    0.8772    1.0994    1.3277    1.4880    1.7048    1.7955    2.0763    2.1066;...
        -0.6644   -0.3730   -0.2039   -0.0068    0.2048    0.4702    0.6319    0.8008    0.9775    1.1454    1.4122    1.5620    1.6963    1.8275    1.8847    2.1487;...
        -0.4542   -0.1567    0.0871    0.3464    0.5848    0.7929    1.0680    1.1379    1.2462    1.4850    1.6129    1.7910    1.9263    1.9863    2.2012       NaN;...
        -0.3636   -0.1035    0.2051    0.4746    0.7457    0.9043    1.1863    1.2533    1.4154    1.6568    1.7909    1.9330    2.0616    2.0808    2.1693    2.2539;...
        -0.1974    0.0098    0.2721    0.6128    0.8488    1.0728    1.2161    1.3985    1.4178    1.6738    1.7163    1.9348    1.9615    2.1480    2.1840    2.2982;...
        -0.2089    0.1448    0.4346    0.7253    0.9232    1.1556    1.3072    1.4958    1.5687    1.7282    1.8244    2.0339    2.0361    2.1448    2.2066       NaN];
        
    someDataRef = 10.^[someData(1,:)];
    xDataLim = [-2 3];
    yDataLim = [-2 3];
    fid = fopen('SARAH_TEST_DATA/ParamDump.txt','w');
    figPrefix = 'SARAH_TEST_DATA/';
    RESPONSE_REMAP = 0;
else
    someData = [ ...
        [-2.0458e+00  -1.8447e+00  -1.6840e+00  -1.4881e+00  -1.3251e+00  -1.1838e+00  -1.0424e+00  -9.2046e-01  -8.1417e-01  -7.1175e-01 ...
         -6.2160e-01  -5.3180e-01  -4.5087e-01  -3.7192e-01  -2.9654e-01  -2.2746e-01  -1.6488e-01  -1.0768e-01  -4.3064e-02]; %palette
         
        [-1.4012   -0.9285   -0.7862   -0.4952   -0.2476    0.0172    0.2259    0.4565    0.5586    0.7049 ...
        0.8431    1.0677    1.1933    1.3972    1.6246    1.7266    1.8868    2.1460    2.2618]; % full4
        
        [-1.2469   -1.0194   -0.6968   -0.3888   -0.1960    0.1387    0.3627    0.6095    0.8034    0.8159 ...
        0.9833    1.1952    1.3942    1.5388    1.5710    1.7905    2.0848    2.0719    2.3168]; % full3
        
        [NaN       NaN       NaN       NaN    1.1345    1.1445    1.2867    1.3138    1.3704    1.5017 ...
        1.5732    1.6708    1.7791    1.8904    1.9778    2.0832    2.2022    2.3184    2.4071]; % full30 3
        
        [NaN       NaN       NaN       NaN       NaN       NaN    1.1932    1.2166    1.2841    1.4061 ...
        1.4842    1.6065    1.6801    1.8158    1.9317    2.0486    2.1714    2.2893    2.4259]; % full30 4
        
        [ -0.3140   -0.2027   -0.0686    0.0819    0.2873    0.4310    0.5986    0.7905    0.8960    1.0847 ...
        1.2355    1.3290    1.4651    1.6356    1.7116    1.8833    1.9983    2.1780    2.3949]; % full 1000
        
        [ NaN       NaN       NaN       NaN    0.4098    0.4786    0.6039    0.7330    0.8416    0.8923 ...
        0.9797    1.1226    1.1993    1.3123    1.4279    1.5174    1.6544    1.6851       NaN]; % full Gray30
        
        [ -1.0961   -0.8952   -0.7221   -0.4952   -0.3652   -0.1803   -0.0603    0.0522    0.3139    0.3222 ...
        0.4816    0.6810    0.8161    0.9925    1.1563    1.3792    1.5010    1.6713    1.7328]; % full gray 1000;
        
        [-1.2028   -0.9204   -0.6084   -0.2414   -0.0021    0.0723    0.2916    0.5297    0.6825    0.8876 ...
        0.9969    1.2277    1.2544    1.4292    1.6247    1.8370    2.0001    2.1447    2.2880]; % full mean plus;
        
        [NaN       NaN       NaN       NaN       NaN       NaN    1.1726    1.2939    1.3940    1.5356 ...
        1.5940    1.7435    1.8141    1.9606    2.0642    2.1749    2.3042    2.3794    2.4674]; % full30 mean plus;
        
        [NaN       NaN       NaN       NaN    0.4270    0.4158    0.5322    0.6765    0.7749    0.8527 ...
        0.9992    1.1176    1.2819    1.3642    1.4917    1.6065    1.6876       NaN       NaN]; % fullgray30
        
        [-7.5486e-01  -6.3016e-01  -3.7002e-01  -7.5043e-02   2.5521e-01   4.1869e-01   6.5650e-01   8.2140e-01   9.3936e-01 ...
        1.1518e+00   1.3266e+00   1.3894e+00   1.4861e+00   1.7282e+00   1.8061e+00   1.9940e+00   2.1053e+00   2.2826e+00 2.3641e+00]; % fullmeanplus2
        
        [-8.8795e-01  -7.5641e-01  -5.6947e-01  -4.3999e-01  -2.9319e-01  -1.1604e-01   5.8502e-02   2.5986e-01   3.7464e-01 ...
        5.2778e-01   6.5286e-01   8.2851e-01   9.8959e-01   1.1379e+00   1.4417e+00   1.6340e+00   1.7811e+00   2.0558e+00 2.1961e+00]; % fullmeanminus
        ];
    
    
    someDataRef = 10.^[someData(1,:)];
    xDataLim = [-2 3];
    yDataLim = [-3 0];
    fid = fopen('ANA_TEST_DATA/ParamDump.txt','w');
    figPrefix = 'ANA_TEST_DATA/';
    RESPONSE_REMAP = 0;
end

%% Initialize parameters.  Set reference rmax to 1 and exponent to 2.  Find
% gain and offset that map the luminances across the central portion
% of the response range.
useDataRef = someDataRef;
clear params0
params0.rmaxRef = 1.0;
params0.expRef = 3;
critValue = 0.01;
minResp = InvertNakaRushton([params0.rmaxRef 1 params0.expRef],critValue);
maxResp = InvertNakaRushton([params0.rmaxRef 1 params0.expRef],1-critValue);
minRef = min(someDataRef);
maxRef = max(someDataRef);
params0.gainRef = (maxResp-minResp)/(maxRef-minRef);
params0.offsetRef = minRef-minResp/params0.gainRef;
paramsRefNoFit = params0;

% Optional search to find reference parameters that put the responses rougly equally spaced on the y-axis.  This isn't theoretically critical, but
% seems as good an idea as any.
FITREF = 0;
if (FITREF)
    if (verLessThan('optim','4.1'))
        error('Your version of the optimization toolbox is too old.  Update it.');
    end
    options = optimset('fmincon');
    options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');
    options = optimset(options,'MaxFunEvals',1200);
    targetRespRef = linspace(critValue,1-critValue,length(someDataRef));
    conTolRef = (targetRespRef(2)-targetRespRef(1));
    x0 = ParamsToListRef(params0);
    vlb = [x0(1)/100 x0(2) -100*mean(someDataRef) 1];
    vub = [x0(1)*100 x0(2) 100*mean(someDataRef) 4];
    x1 = fmincon(@InlineMinFunctionRef,x0,[],[],[],[],vlb,vub,@InlineConFunctionRef,options);
    params0 = ListToParamsRef(x1,params0);
end

%% Plot of remapping between response and reference log10
% luminance/reflectance
lumVals = logspace(log10(someDataRef(1)),log10(someDataRef(end)),1000);
lumVals = logspace(-3,0,1000);
ySub = params0.gainRef*(lumVals-params0.offsetRef);
ySub(ySub <= 0) = 0+eps;
respRefForRemap = ComputeNakaRushton([params0.rmaxRef 1 params0.expRef],ySub);
respRefRemapped = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respRefForRemap)/params0.gainRef+params0.offsetRef);
remapFig = figure; clf; hold on
plot(respRefForRemap,respRefRemapped,'r','LineWidth',2);
xlim([0 1]);
ylim(yDataLim);
xlabel('Visual Response');
ylabel('Predicted Reflectance Match');
cd(figPrefix);
savefig('ResponseRemapping.pdf',remapFig,'pdf');
save('ResponseRemappingData','respRefForRemap','respRefRemapped');
cd ..

%% Now do the fitting wrt to the reference paramters
rangeFig = figure;
dataFig = figure;
position = get(gcf,'Position');
position(3) = 1000; position(4) = 400;
set(gcf,'Position',position);
for whichData = 2:size(someData,1)
    %clear params0
    someDataMatch = 10.^[someData(whichData,:)];
    
    okIndex = find(~isnan(someDataMatch));
    useDataMatch = someDataMatch(okIndex);
    useDataRef = someDataRef(okIndex);
    
    figure(dataFig); clf;
    subplot(1,2,1); hold on
    plot(log10(useDataMatch),log10(useDataRef),'bo','MarkerFaceColor','b','MarkerSize',8);
    xlabel('Log10 Target Lum');
    ylabel('Log10 Standard Lum/Refl');
    
    % Parameter search options
    if (verLessThan('optim','4.1'))
        error('Your version of the optimization toolbox is too old.  Update it.');
    end
    options = optimset('fmincon');
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
    
    % Initialize match parameters in same way
    endPointWeight = 0;
    params0.rmax = params0.rmaxRef;
    params0.exp = params0.expRef;
    params0.gain = params0.gainRef;
    params0.offset = params0.offsetRef;
    someDataPred0 = PredictNRAffineMatches(someDataRef,params0);
    %plot(log10(someDataRef),log10(someDataPred0),'y','LineWidth',1);
    %params0
    fprintf(fid,'Dataset %d\n',whichData);
    fprintf(fid,'\tReference params: gain = %0.2g, offset = %0.2g, rmax = %0.5g, exp = %0.2g\n',params0.gainRef,params0.offsetRef,params0.rmaxRef,params0.expRef);
    
    % Fit, first just gain
    x0 = ParamsToList(params0);
    vlb = [x0(1) x0(2)/100 x0(3:end)];
    vub = [x0(1) x0(2)*100 x0(3:end)];
    x1 = fmincon(@InlineMinFunction,x0,[],[],[],[],vlb,vub,[],options);
    params0 = ListToParams(x1,params0);
    someDataPred1 = PredictNRAffineMatches(someDataRef,params0);
    %plot(log10(someDataPred1),log10(someDataRef),'b','LineWidth',1);
    %params0
    g = params0.gainRef/params0.gain;
    l0 = -params0.offsetRef + params0.offset/g;
    fprintf(fid,'\tGain only model: gain = %0.2g, offset = %0.2g, log10 gain change = %0.2g, log10 effective offset = %0.2g, rmax = %0.5g, exp = %0.2g\n',...
        params0.gain,params0.offset,log10(g),log10(l0),params0.rmax,params0.exp);
    
    % Fit, gain and offset
    vlb = [x1(1) x1(2)/100 x1(3) -100*abs(x1(4)) x1(5)];
    vub = [x1(1) x1(2)*100 x1(3) 100*abs(x1(4)) x1(5)];
    x2 = fmincon(@InlineMinFunction,x1,[],[],[],[],vlb,vub,[],options);
    params0 = ListToParams(x2,params0);
    someDataPred2 = PredictNRAffineMatches(someDataRef,params0);
    g = params0.gainRef/params0.gain;
    l0 = -params0.offsetRef + params0.offset/g;
    fprintf(fid,'\tGain/Offset model: gain = %0.2g, offset = %0.2g, log10 gain change = %0.2g, log10 effective offset = %0.2g, rmax = %0.5g, exp = %0.2g\n',...
        params0.gain,params0.offset,log10(g),log10(l0),params0.rmax,params0.exp);
    paramsGainOffset = params0;
    %params0
    
    % Exp
    FITEXP = 1;
    if (FITEXP)
        vlb = [x2(1) x2(2)/100 x2(3) -100*abs(x2(4)) 0.5];
        vub = [x2(1) x2(2)*100 x2(3) 100*abs(x2(4)) 4];
        endPointWeight = 10;
        x3 = fmincon(@InlineMinFunction,x2,[],[],[],[],vlb,vub,[],options);
        endPointWeight = 0;
        x3 = fmincon(@InlineMinFunction,x3,[],[],[],[],vlb,vub,[],options);
        params0 = ListToParams(x3,params0);
        someDataPred3 = PredictNRAffineMatches(someDataRef,params0);
    else
        x3 = x2;
        someDataPred3 = PredictNRAffineMatches(someDataRef,params0);
    end
    fprintf(fid,'\tGain/Offset/Exp model: gain = %0.2g, offset = %0.2g, log10 gain change = %0.2g, log10 effective offset = %0.2g, rmax = %0.5g, exp = %0.2g\n',...
        params0.gain,params0.offset,log10(g),log10(l0),params0.rmax,params0.exp);
    
    % Let rMax vary too.  This doesn't add much if exponent varies..  Tp the fits, so I
    % uncluttered plots by removing.  Have not looked at whether varying
    % rMax can be substituted for varying the exponent.
    FITMAX = 0;
    if (FITMAX)
        vlb = [x3(1) x3(2)/100 0.5 -100*abs(x3(4)) x3(5)];
        vub = [x3(1) x3(2)*100 2 100*abs(x3(4)) x3(5)];
        x = fmincon(@InlineMinFunction,x3,[],[],[],[],vlb,vub,[],options);
        params0 = ListToParams(x,params0);
        someDataPred = PredictNRAffineMatches(someDataRef,params0);
        plot(log10(someDataPred3),log10(someDataRef),'k','LineWidth',1.5);
        %params0
    else
        x = x3;
        someDataPred = PredictNRAffineMatches(someDataRef,params0);
    end
    
    % Dump of interesting parameters
    g = params0.gainRef/params0.gain;
    l0 = -params0.offsetRef + params0.offset/g;
    fprintf(fid,'\tPredicted (actual) black point %0.2g (%0.2g); white point %0.2g (%0.2g)\n',someDataPred(1),someDataMatch(1),someDataPred(end),someDataMatch(end));
    fprintf(fid,'\tOne-in predicted black point %0.2g (%0.2g); white point %0.2g (%0.2g)\n',someDataPred(2),someDataMatch(2),someDataPred(end-1),someDataMatch(end-1));
    
    % Plot stuff of interest
    plot(log10(someDataPred),log10(someDataRef),'r','LineWidth',3);
    plot(log10(someDataPred2),log10(someDataRef),'g','LineWidth',1);
    xlim(xDataLim); ylim(yDataLim);

    % Add plot of response functions for ref and match
    % Subtract the old offset, and truncate below 0 to zero.
    % We allow an optional remapping of the response back to the
    % luminance/reflectance space of the reference matches.  This
    % mapping is static across contexts.  This turns out not to
    % terribly interesting.
    lumVals = logspace(-2,3,1000);   
    ySub = params0.gainRef*(lumVals-params0.offsetRef);
    ySub(ySub <= 0) = 0+eps;
    respRefSmooth = ComputeNakaRushton([params0.rmaxRef 1 params0.expRef],ySub);
    if (RESPONSE_REMAP)
        respRefSmooth = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respRefSmooth)/params0.gainRef+params0.offsetRef);
    end
    
    ySub = params0.gainRef*(someDataRef-params0.offsetRef);
    ySub(ySub <= 0) = 0+eps;
    respRef = ComputeNakaRushton([params0.rmaxRef 1 params0.expRef],ySub);
    if (RESPONSE_REMAP)
        respRef = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respRef)/params0.gainRef+params0.offsetRef);
    end
    
    ySub = params0.gain*(lumVals-params0.offset);
    ySub(ySub <= 0) = 0+eps;
    respMatchSmooth = ComputeNakaRushton([params0.rmax 1 params0.exp],ySub);
    if (RESPONSE_REMAP)
        respMatchSmooth = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respMatchSmooth)/params0.gainRef+params0.offsetRef);
    end
    
    ySub = params0.gain*(someDataMatch-params0.offset);
    ySub(ySub <= 0) = 0+eps;
    respMatch = ComputeNakaRushton([params0.rmax 1 params0.exp],ySub);
    if (RESPONSE_REMAP)
        respMatch = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respMatch)/params0.gainRef+params0.offsetRef);
    end
    
    ySub = paramsGainOffset.gain*(lumVals-paramsGainOffset.offset);
    ySub(ySub <= 0) = 0+eps;
    respGainOffsetSmooth = ComputeNakaRushton([paramsGainOffset.rmax 1 paramsGainOffset.exp],ySub);
    if (RESPONSE_REMAP)
        respGainOffsetSmooth = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respGainOffsetSmooth)/params0.gainRef+params0.offsetRef);
    end
    
    ySub = paramsRefNoFit.gainRef*(lumVals-paramsRefNoFit.offsetRef);
    ySub(ySub <= 0) = 0+eps;
    respRefNoFitSmooth = ComputeNakaRushton([paramsRefNoFit.rmaxRef 1 paramsRefNoFit.expRef],ySub);
    if (RESPONSE_REMAP)
        respRefNoFitSmooth = log10(InvertNakaRushton([params0.rmaxRef 1 params0.expRef],respRefNoFitSmooth)/params0.gainRef+params0.offsetRef);
    end
    
    subplot(1,2,2); hold on
    plot(log10(someDataRef),respRef,'ko','MarkerFaceColor','k','MarkerSize',6);
    plot(log10(lumVals),respRefSmooth,'k:','LineWidth',2);
    %plot(log10(lumVals),respRefNoFitSmooth,'b','LineWidth',1);
    
    plot(log10(someDataMatch),respMatch,'bo','MarkerFaceColor','b','MarkerSize',8);
    plot(log10(lumVals),respMatchSmooth,'r','LineWidth',2);
    plot(log10(lumVals),respGainOffsetSmooth,'g','LineWidth',1);
    
    xlim(xDataLim);
    if (RESPONSE_REMAP)
        ylim(yDataLim);
        ylabel('Remapped Response');
    else
        ylim([0 1.2]);
        ylabel('Response');
    end
    xlabel('Log10 luminance');
    
    % Save figure
    cd(figPrefix);
    savefig(['TestFit_' num2str(whichData) '.pdf'],dataFig,'pdf');
    cd('..');
    
    fprintf(fid,'\n');
    
    %% Fill output summary structure
    summaryStructs(whichData-1).whitePoint = someDataPred(end);
    summaryStructs(whichData-1).blackPoint = someDataPred(1);
    summaryStructs(whichData-1).range = someDataPred(end) - someDataPred(1);
    summaryStructs(whichData-1).exp = params0.exp;
    predictExpFromWB(whichData-1,1) = summaryStructs(whichData-1).whitePoint;
    predictExpFromWB(whichData-1,2) = log10(summaryStructs(whichData-1).range);
    expVals(whichData-1,1) = summaryStructs(whichData-1).exp;
    
    %% Range versus exp figure
    figure(rangeFig)
    subplot(1,2,1); hold on
    plot(summaryStructs(whichData-1).range,summaryStructs(whichData-1).exp,'ro','MarkerFaceColor','r','MarkerSize',8);
    xlabel('Range'); ylabel('Exponent');
    xlim([0 300]); ylim([0 4]);
    subplot(1,2,2); hold on
    plot(summaryStructs(whichData-1).whitePoint,summaryStructs(whichData-1).exp,'ro','MarkerFaceColor','r','MarkerSize',8);
    xlabel('White Point'); ylabel('Exponent');
    xlim([0 300]); ylim([0 4]);
end
fclose(fid);

%% Try to predict exponents
expRegCoefs = predictExpFromWB\expVals;
predictedExpVals = predictExpFromWB*expRegCoefs;
expPredFig = figure; clf; hold on
plot(expVals,predictedExpVals,'ro','MarkerSize',8,'MarkerFaceColor','r');
plot([0 4],[0 4],'k');
xlim([0 4]); ylim([0 4]);
xlabel('Exponent'); ylabel('Predicted Exponent');
axis('square');

%% Write out summary structs
cd(figPrefix);
WriteStructsToText('SummaryData.txt',summaryStructs);
cd('..');

%% Save plot of exponent versus range
cd(figPrefix);
savefig(['ExpVersusRange.pdf'],rangeFig,'pdf');
cd('..');
    
%% INLINE FUNCTION TO BE USED FOR CTF MINIMIZATION.
% Inline functions have the feature that any variable they use that is
% not defined in the function has its value inherited
% from the workspace of wherever they were invoked.
%
% Variables set here are also in the base workspace, and can change the values of
% variables with the same name there.  This can produce all sorts of problems,
% so be careful.
    function f = InlineMinFunction(x)
        paramsInline = ListToParams(x,params0);
        yPred = PredictNRAffineMatches(useDataRef,paramsInline);
        yPred(yPred <= 0) = 0 + eps;
        yDiff = log10(useDataMatch)-log10(yPred);
        f = sum(yDiff.^2) + endPointWeight*yDiff(1).^2 + endPointWeight*yDiff(end).^2;
    end

%% INLINE FUNCTION TO BE USED FOR REF MINIMIZATION.
% Inline functions have the feature that any variable they use that is
% not defined in the function has its value inherited
% from the workspace of wherever they were invoked.
%
% Variables set here are also in the base workspace, and can change the values of
% variables with the same name there.  This can produce all sorts of problems,
% so be careful.
    function f = InlineMinFunctionRef(x)
        paramsInline = ListToParamsRef(x,params0);
        
        % Subtract the old offset, and truncate below 0 to zero
        ySub = paramsInline.gainRef*(useDataRef-paramsInline.offsetRef);
        ySub(ySub <= 0) = 0+eps;
        respRef = ComputeNakaRushton([paramsInline.rmaxRef 1 paramsInline.expRef],ySub);
        yDiff = targetRespRef-respRef;
        f = sum(abs(yDiff));
        %f = sum(yDiff.^2);
    end
    function [g,geq] = InlineConFunctionRef(x)
        paramsInline = ListToParamsRef(x,params0);
        
        % Subtract the old offset, and truncate below 0 to zero
        ySub = paramsInline.gainRef*(useDataRef-paramsInline.offsetRef);
        ySub(ySub <= 0) = 0+eps;
        respRef = ComputeNakaRushton([paramsInline.rmaxRef 1 paramsInline.expRef],ySub);
        yDiff = targetRespRef-respRef;
        g = max(abs(yDiff))-conTolRef;
        geq = 0;
    end
end

%% Param translation
function params = ListToParams(x,params0)

params = params0;
params.gainRef = x(1);
params.gain = x(2);
params.rmax = x(3);
params.offset = x(4);
params.exp = x(5);

end

function x = ParamsToList(params)

x = [params.gainRef params.gain params.rmax params.offset params.exp];

end

function params = ListToParamsRef(x,params0)

params = params0;
params.gainRef = x(1);
params.rmaxRef = x(2);
params.offsetRef = x(3);
params.expRef = x(4);

end

function x = ParamsToListRef(params)

x = [params.gainRef params.rmaxRef params.offsetRef params.expRef];

end
