function TestPredictNRAffineMatchesContol
% TestPredictNRAffineMatchesControl
%
% Fit the model through the control conditions. 
%
% 05/20/11 ar   Adapded it in order to Model bunch of old controls previously done by Sarah. 

%% Clear
clear; close all;

% Define relevant directories. 
currentDir = pwd; 
dataDir = '/Users/Shared/Matlab/Experiments/HDRExperiments/HDRAna'; 
whichDataSet = 1; 
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


%% Palette Values from Sarah's old experiments. 
paletteGlossy = [ -2.1460   -1.8211   -1.7097   -1.5066   -1.3266   -1.1874   -1.0410   -0.9402   -0.8007   -0.7012   -0.6070 ...
    -0.5109   -0.4395   -0.3639   -0.3139   -0.2053   -0.1452   -0.0880 -0.0307];

paletteMatte = [  NaN       NaN       NaN   -1.3619   -1.3298   -1.1938   -0.9993   -0.9174   -0.8027   -0.7206   -0.6117 ...
    -0.5474   -0.4374   -0.3707   -0.2806   -0.2226   -0.1525   -0.1009  -0.0419 ];

%% Fit some matching data
SARAH_TEST_DATA = 0;
if (SARAH_TEST_DATA)
  
else
    switch whichDataSet
        case 1
            conditionList = {'SIonGlossy','SIoffGlossy', 'SIoldMatte', 'fMonGlossy','fMoffGlossy', 'fMoldMatte',};
           % subjectList = {'bam', 'cly', 'flv', 'lta' ,'ncd', 'rpd', 'stg', 'tfm'};
       someData =    [[-1.1820   -0.7709   -0.5714   -0.2102   -0.0518    0.1396    0.3406    0.4518    0.6188    0.8408    0.9734    1.1930    1.2922    1.4202    1.5267    1.6482    1.7918    2.0094 2.2232 ]; 
 [  -1.2288   -0.7391   -0.3809   -0.2950   -0.1586    0.1467    0.2993    0.4713    0.6734    0.7679    0.9406    1.0131    1.2507    1.3145    1.4443    1.6137    1.7227    2.0653  2.1752];  
  [     NaN       NaN       NaN   -0.5785   -0.2625   -0.0359    0.2090    0.4355    0.5728    0.7679    0.9699    1.1320    1.2803    1.4505    1.6429    1.7727    1.8928    2.0566  2.1480]; 
   [-1.1133   -0.7398   -0.4359   -0.1763    0.0267    0.3351    0.5433    0.7359    0.8915    1.0952    1.2348    1.3061    1.4766    1.6375    1.7163    1.9082    1.9294    2.1959  2.1790];    
   [-1.2353   -0.4408   -0.3123   -0.1259    0.1121    0.2837    0.4506    0.7405    0.9927    0.9704    1.2497    1.4010    1.4841    1.6258    1.6844    1.7980    2.0851    2.1959  2.2573];  
    [   NaN       NaN       NaN   -0.6949   -0.2629    0.0446    0.3898    0.5828    0.8021    1.0371    1.0989    1.3152    1.4972    1.6377    1.7715    1.9127    2.0254    2.1249  2.2717]; ]  
       
       
        
       
    end
    
    cd(currentDir); 
    xDataLim = [-2 3];
    yDataLim = [-3 0];
    
    fid = fopen(['ANA_TEST_DATA/ParamDump_Control' num2str(whichDataSet) '.txt'],'w');
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
 

% allData = cell(1,length(conditionList)); 
% for i = 1:length(conditionList)
%     temptemp = [];
%     for j = 1:length(subjectList)
%         temptemp = [temptemp; [averageLumMatchesPerSubject{i}(:,j)']];
%     end
%     %allDataMean(i,:) = nanmean(temptemp, 1);
%     acrossSubjectLumAverages{i} = NaN(size(paletteGlossy',1),1);
%     for g = 1:size(paletteGlossy',1)
%         okindex = ~isnan(averageLumMatchesPerSubject{i}(g,:)');
%         tt=mean(averageLumMatchesPerSubject{i}(g,okindex))';
%         acrossSubjectLumAverages{i}(g,1)=tt;
%     end
%     temptemp = [temptemp; acrossSubjectLumAverages{i}(:)'] ; 
%     allData{i} = temptemp; 
%     clear temptemp
% end
% clear okindex; 
% %% for debugging purposes.
% for i = 1:length(conditionList)
% check = keepSomeData(i,:) - acrossSubjectLumAverages{i}(:)'; 
% end
% %%
% someData = []; 
% for i = 1:length(conditionList)
%     someData = [someData; acrossSubjectLumAverages{i}(:)'];
% end
for whichData = 1:size(someData,1)
    
    switch (whichDataSet)
        case 1
            if whichData == 1 || whichData == 2 || whichData == 4 || whichData == 5
                someDataRef = 10.^[paletteGlossy(1,:)];
            elseif whichData == 3 || whichData == 6
                someDataRef = 10.^[paletteMatte(1,:)];
            end
       
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
        savefig(['ResponseRemappingControl' num2str(whichDataSet) '.pdf'],remapFig,'pdf');
        save(['ResponseRemappingDataControl' num2str(whichDataSet)],'respRefForRemap','respRefRemapped');
        cd ..
    end
    
    
    
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
    savefig(['TestFit_Control' num2str(whichDataSet) ' ' conditionList{whichData} '.pdf'],dataFig,'pdf');
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
if (SARAH_TEST_DATA)
    WriteStructsToText('SummaryDataControl.txt',summaryStructs);
else
    WriteStructsToText(['SummaryDataControl', num2str(whichDataSet), '.txt'],summaryStructs);
end
cd('..');

%% Save plot of exponent versus range
cd(figPrefix);
if (SARAH_TEST_DATA)
    savefig(['ExpVersusRangeControl.pdf'],rangeFig,'pdf');
else
    savefig(['ExpVersusRangeControl', num2str(whichDataSet),'.pdf'],rangeFig,'pdf');
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
