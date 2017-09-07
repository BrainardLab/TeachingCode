function TestNRAPredictMatches
% TestNRAPredictMatches
%
% Work out what the little model does for various choices of input
%
% 12/4/10 dhb  Wrote it.
% 4/20/11 dhb  Lot's of little changes.  Switch polarity of data plots

%% Clear
clear; close all;

% Define relevant directories. 
currentDir = pwd; 
dataDir = '/Users/Shared/Matlab/Experiments/HDRExperiments/HDRAna'; 
whichDataSet = 2; 
%% Choose model parameters and generate predictions, plot.
% Let's one explore what the model can do.
%DO_PRELIM_STUFF = 0;
% if (DO_PRELIM_STUFF)
%     yRef = logspace(-2,4);
%     
%     %% Set up parameters
%     params0.rmaxRef = 1.0;
%     params0.gainRef = 10e-4;
%     params0.offsetRef = 0;
%     params0.expRef = 2.5;
%     params0.rmax = 1.01;
%     params0.gain =  0.5*10e-4;
%     params0.offset = 1;
%     params0.exp = 1;
%     
%     %% Plot effect of mucking with exponent
%     figure; clf; hold on
%     exponents = [1.5 2 2.5];
%     for i = 1:length(exponents)
%         params0.exp = exponents(i);
%         yMatch{i} = NRAPredictMatches(yRef,params0);
%         
%         % Plot
%         plot(log10(yMatch{i}),log10(yRef),'k','LineWidth',3);
%         xlim([-3 5]); ylim([-3 5]);
%         xlabel('Log10 Target Lum');
%         ylabel('Log10 Standard Lum/Refl');
%     end
% end
paletteGlossy = [-2.0458e+00  -1.8447e+00  -1.6840e+00  -1.4881e+00  -1.3251e+00  -1.1838e+00  -1.0424e+00  -9.2046e-01  -8.1417e-01  -7.1175e-01 ...
    -6.2160e-01  -5.3180e-01  -4.5087e-01  -3.7192e-01  -2.9654e-01  -2.2746e-01  -1.6488e-01  -1.0768e-01  -4.3064e-02];

paletteMatte = [ NaN       NaN       NaN   -1.4660   -1.3279   -1.1379   -1.0155   -0.8726   -0.7791   -0.6807   -0.6038 ...
    -0.5046   -0.4332   -0.3622   -0.3050   -0.2280   -0.1671   -0.0941   -0.0472];
paletteGlossyTruncated = [NaN NaN NaN paletteGlossy(:,4:end)];

%% Fit some matching data
SARAH_TEST_DATA = 0;
if (SARAH_TEST_DATA)
  
else
    switch whichDataSet
        case 1
            conditionList = {'FullGlossyfull','FullGlossytruncated', 'FullMattetruncated', 'WhiteGlossyfull','WhiteGlossytruncated', 'WhiteMattetruncated'};
            subjectList = {'bam', 'cly', 'flv', 'lta' ,'ncd', 'rpd', 'stg', 'tfm'};
          keepSomeData = [
                [ -1.3802   -1.2294   -0.9707   -0.7100   -0.3612    0.0249    0.3078    0.5715    0.7699    0.9778    1.0846    1.3089    1.4555    1.5644    1.7196    1.9207    2.0673    2.2239    2.3914];
                
                [   NaN       NaN       NaN   -0.9522   -0.6050   -0.2339    0.1047    0.4402    0.6977    0.8384    1.0023    1.2422    1.4114    1.5759    1.7508    1.9397    2.0528    2.2656    2.4112];
                
                [ NaN       NaN       NaN   -1.0312   -0.7059   -0.2358    0.1020    0.4629    0.6309    0.8030    1.0495    1.1958    1.3473    1.5350    1.6646    1.8909    2.0447    2.2378 2.3792];
                
                [ NaN   -0.0746    0.0318    0.2519    0.6330    0.9303    1.1223    1.3450    1.5182    1.7405    1.8143    2.0090    1.9072    2.2261       NaN    2.4317       NaN       NaN NaN];
                
                [ NaN       NaN       NaN   -0.0043    0.4266    0.6850    0.9769    1.2355    1.4810    1.6573    1.7507    1.9130    2.0836    2.1939       NaN    2.4042       NaN       NaN NaN];
                
                [ NaN       NaN       NaN    0.0356    0.3936    0.7326    0.9986    1.2143    1.4117    1.5808    1.7714    1.9066    2.0828    2.1358    2.3293    2.3833       NaN       NaN NaN];]; 
        case 2
            conditionList = {'FullGlossyfull2','FullMattetruncated2', 'Full30Glossyfull2', 'Full30Mattetruncated2', 'White30Glossyfull','White30Mattetruncated', 'Gray30Glossyfull', 'Gray30Mattetruncated'};
            subjectList = {'bam', 'cly', 'ncd', 'stg', 'tfm'};
            
          keepSomeData = [
                [   -1.0849   -0.9622   -0.8648   -0.6281   -0.3869   -0.1036    0.2128    0.4567    0.7647    0.9488    1.1614 ...
                1.3723    1.5101    1.6622    1.7990    1.9214    2.0359    2.2311    2.3199];
                
                [   NaN       NaN       NaN   -0.8392   -0.5873   -0.1825    0.1171    0.4655    0.7031    0.9464    1.1034 ...
                1.3530    1.4774    1.6270    1.8231    1.9047    2.1262    2.2451    2.2713]
                
                [     NaN       NaN       NaN       NaN       NaN    1.2849    1.2088    1.2595    1.3693    1.4580    1.5826 ...
                1.7126    1.8139    1.9713    2.1010    2.1720    2.3164    2.4515    2.5170];
                
                [    NaN       NaN       NaN       NaN       NaN       NaN    1.1963    1.2787    1.3236    1.4529    1.5473 ...
                1.6579    1.8419    1.8985    2.0625    2.1901    2.3280    2.4015    2.5215];
                
                [   NaN       NaN       NaN       NaN       NaN    1.2475    1.2973    1.3907    1.6027    1.7238    1.8637...
                1.9849    2.0992    2.2393    2.3454    2.4286    2.5200    2.5425    2.6196];
                
                [NaN       NaN       NaN       NaN       NaN    1.2689    1.2883    1.4364    1.5560    1.7329    1.8336...
                1.9731    2.1075    2.2431    2.3248    2.4025    2.5065    2.5691    2.6030];
                
                [  NaN       NaN       NaN   -0.0572   -0.0016    0.0921    0.2724    0.4301    0.5819    0.7071    0.7965 ...
                0.9089    1.0300    1.0749    1.1734    1.2381    1.2656       NaN       NaN];
                
                [NaN       NaN       NaN       NaN   -0.0920    0.0354    0.2398    0.4029    0.5708    0.6956    0.7910...
                0.9222    1.0426    1.0873    1.1855    1.2379       NaN       NaN       NaN];]; 
        case 3
            subjectList={'ajh', 'arp', 'kjn', 'orp' ,'rvn'};
           
            conditionList = {'FullGlossyfull3', 'FullGlossyfull4','Full30Glossyfull3','Full30Glossyfull4'...
                , 'Full1000Glossyfull3', 'FullGray30Glossyfull', 'FullGray1000Glossyfull', ...
                'FullMeanPlusGlossyfull', 'Full30MeanPlusGlossyfull', 'FullGray30MeanPlusGlossyfull', 'FullMeanPlusGlossyfull2', 'FullMeanMinusGlossyfull2'};
            keepSomeData = [[-1.2469   -1.0194   -0.6968   -0.3888   -0.1960    0.1387    0.3627    0.6095    0.8034    0.8159 ...
                0.9833    1.1952    1.3942    1.5388    1.5710    1.7905    2.0848    2.0719    2.3168]; % full3
            [ -1.4012   -0.9285   -0.7862   -0.4952   -0.2476    0.0172    0.2259    0.4565    0.5586    0.7049 ...
                0.8431    1.0677    1.1933    1.3972    1.6246    1.7266    1.8868    2.1460    2.2618]; % full4
                
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
    end
    
    
    for i = 1:length(conditionList)
        for j=1:length(subjectList)
            luminanceMatchesPerChip{i,j} = load(fullfile(dataDir,'data',conditionList{i},subjectList{j},[conditionList{i} '-' subjectList{j} '-TestAverages.txt']));
            luminanceMatchesPerChip{i,j} = luminanceMatchesPerChip{i,j}(:, 2:end);
           % averageLumMatchesPerSubject{j}(:,i) = nanmean(luminanceMatchesPerChip{i,j},2); 
            averageLumMatchesPerSubject{i}(:,j) = nanmean(luminanceMatchesPerChip{i,j},2);
        end
    end
   
    averageLumMatchesPerSubjectAll{i} = averageLumMatchesPerSubject{i};
    %% See how many matches per subject are made. 
    % If less than 3 subjects assigned anything to this chip, drop them. 
    for g = 1: length(averageLumMatchesPerSubject)
        nSubjectMatches{g} = sum(isnan(averageLumMatchesPerSubject{g}),2); 
    end
    
    for g = 1: length(nSubjectMatches)
        for r = 1:length(nSubjectMatches{g})
            if (nSubjectMatches{g}(r) > 2)
                averageLumMatchesPerSubject{g}(r,:) = nan(1, size(averageLumMatchesPerSubject{g},2));
            end
        end
    end
    cd(currentDir); 
    xDataLim = [-2 3];
    yDataLim = [-3 0];
    
    fid = fopen(['ANA_TEST_DATA/ParamDump_All' num2str(whichDataSet) '.txt'],'w');
    figPrefix = 'ANA_TEST_DATA/';
    RESPONSE_REMAP = 0;
end



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

%% Now do the fitting wrt to the reference paramters
% rangeFig = figure;
rangeFig = figure; 
dataFig = figure;
 position = get(gcf,'Position');
 position(3) = 1000; position(4) = 400;
 set(gcf,'Position',position);

allData = cell(1,length(conditionList)); 
for i = 1:length(conditionList)
    temptemp = [];
    for j = 1:length(subjectList)
        temptemp = [temptemp; [averageLumMatchesPerSubject{i}(:,j)']];
    end
    %allDataMean(i,:) = nanmean(temptemp, 1);
    acrossSubjectLumAverages{i} = NaN(size(paletteGlossy',1),1);
    for g = 1:size(paletteGlossy',1)
        okindex = ~isnan(averageLumMatchesPerSubject{i}(g,:)');
        tt=mean(averageLumMatchesPerSubject{i}(g,okindex))';
        acrossSubjectLumAverages{i}(g,1)=tt;
    end
    temptemp = [temptemp; acrossSubjectLumAverages{i}(:)'] ; 
    allData{i} = temptemp; 
    clear temptemp
end
clear okindex; 
%% for debugging purposes.
for i = 1:length(conditionList)
check = keepSomeData(i,:) - acrossSubjectLumAverages{i}(:)'; 
end
%%
someData = []; 
for i = 1:length(conditionList)
    someData = [someData; acrossSubjectLumAverages{i}(:)'];
end

check = keepSomeData - someData
for whichData = 1:size(someData,1)
    
    switch (whichDataSet)
        case 1
            if whichData == 1 || whichData == 4
                someDataRef = 10.^[paletteGlossy(1,:)];
            elseif whichData == 2 || whichData == 5
                someDataRef = 10.^[paletteMatte(1,:)];
            elseif whichData == 3 || whichData == 6
                someDataRef = 10.^[paletteMatte(1,:)];
            end
        case 2
            if whichData == 1 || whichData == 3 || whichData == 5 || whichData == 7
                someDataRef = 10.^[paletteGlossy(1,:)];
            elseif whichData == 2 || whichData == 4 || whichData == 6 || whichData == 8
                someDataRef = 10.^[paletteMatte(1,:)];
                
            end
        case 3
            someDataRef = 10.^[paletteGlossy(1,:)];
            
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
    
    if whichData == 1
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
        %savefig('ResponseRemapping.pdf',remapFig,'pdf');
        %save('ResponseRemappingData','respRefForRemap','respRefRemapped');
        savefig(['ResponseRemapping' num2str(whichDataSet) '.pdf'],remapFig,'pdf');
        save(['ResponseRemappingData' num2str(whichDataSet)],'respRefForRemap','respRefRemapped');
        cd ..
    end
    
    
    
    someDataMatch = 10.^[someData(whichData,:)]
    
    
    
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
    someDataPred0 = NRAPredictMatches(someDataRef,params0);
    %plot(log10(someDataRef),log10(someDataPred0),'y','LineWidth',1);
    %params0
    fprintf(fid,['Dataset ' conditionList{whichData} '\n']);
    fprintf(fid,'\tReference params: gain = %0.2g, offset = %0.2g, rmax = %0.5g, exp = %0.2g\n',params0.gainRef,params0.offsetRef,params0.rmaxRef,params0.expRef);
    
    % Fit, first just gain
    x0 = ParamsToList(params0);
    vlb = [x0(1) x0(2)/100 x0(3:end)];
    vub = [x0(1) x0(2)*100 x0(3:end)];
    x1 = fmincon(@InlineMinFunction,x0,[],[],[],[],vlb,vub,[],options);
    params0 = ListToParams(x1,params0);
    someDataPred1 = NRAPredictMatches(someDataRef,params0);
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
    someDataPred2 = NRAPredictMatches(someDataRef,params0);
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
        someDataPred3 = NRAPredictMatches(someDataRef,params0);
    else
        x3 = x2;
        someDataPred3 = NRAPredictMatches(someDataRef,params0);
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
        someDataPred = NRAPredictMatches(someDataRef,params0);
        plot(log10(someDataPred3),log10(someDataRef),'k','LineWidth',1.5);
        %params0
    else
        x = x3;
        someDataPred = NRAPredictMatches(someDataRef,params0);
    end
    
    % Dump of interesting parameters
    g = params0.gainRef/params0.gain;
    l0 = -params0.offsetRef + params0.offset/g;
    fprintf(fid,'\tPredicted (actual) black point %0.2g (%0.2g); white point %0.2g (%0.2g)\n',someDataPred(1),someDataMatch(1),someDataPred(end),log10(someDataMatch(end)));
    fprintf(fid,'\tOne-in predicted black point %0.2g (%0.2g); white point %0.2g (%0.2g)\n',someDataPred(2),someDataMatch(2),someDataPred(end-1),log10(someDataMatch(end-1)));
    
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
    savefig(['TestFit_' num2str(whichDataSet) ' ' conditionList{whichData} '.pdf'],dataFig,'pdf');
    cd('..');
    
    fprintf(fid,'\n');
    
    %% Fill output summary structure
    if (SARAH_TEST_DATA)
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
    else
        summaryStructs(whichData).whitePoint = someDataPred(end);
        summaryStructs(whichData).blackPoint = someDataPred(1);
        summaryStructs(whichData).range = someDataPred(end) - someDataPred(1);
        summaryStructs(whichData).exp = params0.exp;
        predictExpFromWB(whichData,1) = summaryStructs(whichData).whitePoint;
        predictExpFromWB(whichData,2) = log10(summaryStructs(whichData).range);
        expVals(whichData,1) = summaryStructs(whichData).exp;
        %% Range versus exp figure
        figure(rangeFig)
        subplot(1,2,1); hold on
        plot(summaryStructs(whichData).range,summaryStructs(whichData).exp,'ro','MarkerFaceColor','r','MarkerSize',8);
        xlabel('Range'); ylabel('Exponent');
        xlim([0 300]); ylim([0 4]);
        subplot(1,2,2); hold on
        plot(summaryStructs(whichData).whitePoint,summaryStructs(whichData).exp,'ro','MarkerFaceColor','r','MarkerSize',8);
        xlabel('White Point'); ylabel('Exponent');
        xlim([0 300]); ylim([0 4]);
    end
    
end
fclose(fid);

%% Try to predict exponents
% expRegCoefs = predictExpFromWB\expVals;
% predictedExpVals = predictExpFromWB*expRegCoefs;
% expPredFig = figure; clf; hold on
% plot(expVals,predictedExpVals,'ro','MarkerSize',8,'MarkerFaceColor','r');
% plot([0 4],[0 4],'k');
% xlim([0 4]); ylim([0 4]);
% xlabel('Exponent'); ylabel('Predicted Exponent');
% axis('square');

%% Write out summary structs
cd(figPrefix);
if (SARAH_TEST_DATA)
    WriteStructsToText('SummaryData.txt',summaryStructs);
else
    WriteStructsToText(['SummaryData', num2str(whichDataSet), '.txt'],summaryStructs);
end
cd('..');

%% Save plot of exponent versus range
cd(figPrefix);
if (SARAH_TEST_DATA)
    savefig(['ExpVersusRange.pdf'],rangeFig,'pdf');
else
    savefig(['ExpVersusRange', num2str(whichDataSet),'.pdf'],rangeFig,'pdf');
end
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
        yPred = NRAPredictMatches(useDataRef,paramsInline);
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
