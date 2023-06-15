%function AnalyseData_PH
clear variables

%% 1) Load participants
load AllSubjectsDatatest.mat
load WMC.mat

allSub=dir('ANA_*.zip');
young={'YA01';'YA02';'YA03';'YA04';'YA05';'YA06';'YA07';'YA08';'YA09';'YA10';'YA11';'YA12';'YA13';'YA14';...
    'YA15';'YA16';'YA17';'YA18';'YA19';'YA20';'YA21';'YA22';'YA23';'YA24';'YA25';'YA26';'YA27';'YA28'};
GR1=young;

old={'OA01';'OA02';'OA03';'OA04';'OA05';'OA06';'OA07';'OA08';'OA09';'OA10';'OA11';'OA12';'OA13';'OA15';...
    'OA16';'OA17';'OA18';'OA19';'OA20';'OA21'};
GR2=old;

G1 = [GR1{:}]; 
G2 = [GR2{:}];
yo=1;ol=1;

for k=1:length(allSub)
    if findstr(allSub(k).name(10:end-4),G1)
        GR1sub(yo)=allSub(k);
        yo=yo+1;
    elseif findstr(allSub(k).name(10:end-4),G2)
        GR2sub(ol)=allSub(k);
        ol=ol+1;
    end
end

group = 'c'; % Set group = 'y' for young people and group = 'o' if you want to look at the data from old people
% set to 'c' if you want to Compare the two groups.
if strcmp(group,'y')
    ANASub.S = GR1sub;
elseif strcmp(group,'o')
    ANASub.S = GR2sub;
elseif strcmp(group,'c')
    ANASub(1).S = GR1sub;
    ANASub(2).S = GR2sub;
end

Istart = 73; % find(Load==2|Load==4,1,'first');% trial number for start of perturbation
Icounter = 282; % trial number for start of counter-perturbation
Ispont = 306; % trial number for start of series of error-clamped trials
Iend = 369;

% Level of perturbation.
perturb(Istart:Icounter-1)=10;
perturb(Icounter:Ispont-1)=-10;
perturb(Ispont:Iend)= 0;

% TP TABLE
%                      | load | target 2    target 3    target 4    target5    target 6    target 7    target 8    target 9
% baseline             |  1   |    1            2           3           4          5           6         7           8
% perturbation         |  2   |    9            10          11          12         13          14        15          16 
% errorclamp block     |  3   |    17           18          19          20         21          22        23          24
% errorclamp learning  |  3   |    17                       19                     21                    23 
% counterperturbation  |  4   |    25           26          27          28         29          30        31          32
% catch                |  1   |    34                       35                     36                    37
% first perturbation   |  2   |                 38
% errorclamp baseline  |  3   |    40                       42                     44                    46

%% 2) Timecourse for individual subjects
G = struct('PertLate',cell(1,2),'ForceLate',cell(1,2),'CatchLate',cell(1,2),'Explicit',cell(1,2),'SpontLate',cell(1,2),'SpontLate2',cell(1,2));

for sk=1:length(ANASub)
    for k=1:length(ANASub(sk).S)
        ANAstruct=CSV2STRUCT(ANASub(sk).S(k).name);
%         load(ANASub(sk).S(k).name,'Load','tp') % presence or absence of perturbation, type of trials, reaction time 
        Load = ANAstruct.Load;
        tp = ANAstruct.tp;
        FieldTrials = find(Load~=3 & (tp<34 | tp>38)); % trials but not catch trials or error clamp trials
        CatchTrials = find(tp>33 & tp<38);
        ClampTrials = find(Load==3);
        
        %Pre-allocation
        if k==1
            G(sk).PertLate = nan(1,length(ANASub(sk).S));
            G(sk).CatchLate = nan(1,length(ANASub(sk).S));
            G(sk).ForceLate = nan(1,length(ANASub(sk).S));
            G(sk).ForceLate2 = nan(1,length(ANASub(sk).S));
            G(sk).SpontLate = nan(1,length(ANASub(sk).S));
            G(sk).SpontLate2 = nan(1,length(ANASub(sk).S));
            G(sk).AdaptIndexLate = nan(1,length(ANASub(sk).S));
            G(sk).AdaptIndexLate2 = nan(1,length(ANASub(sk).S));
            
            PertLate = nan(length(ANASub(sk).S),8);
            ForceLate = nan(length(ANASub(sk).S),4);
            ForceLate2 = nan(length(ANASub(sk).S),4);
            CatchLate = nan(length(ANASub(sk).S),4);
            SpontLate = nan(length(ANASub(sk).S),8);
            SpontLate2 = nan(length(ANASub(sk).S),4);
            AdaptIndexLate = nan(length(ANASub(sk).S),8);
            AdaptIndexLate2 = nan(length(ANASub(sk).S),4);
            Explicit = nan(length(ANASub(sk).S),4);
        end
        
        % Total adaptation = Error of cued trials at end of perturbation
        % phase last 80 trials, 8 per target
        % 0 = perfect adaptation
        IPerp2=find(tp==9,10,'last'); IPerp3=find(tp==10,10,'last');
        IPerp4=find(tp==11,10,'last'); IPerp5=find(tp==12,10,'last');
        IPerp6=find(tp==13,10,'last'); IPerp7=find(tp==14,10,'last');
        IPerp8=find(tp==15,10,'last'); IPerp9=find(tp==16,10,'last');
        
        PertLate(k,1) = mean(H(sk).PEAdj(k,IPerp2),"omitnan"); PertLate(k,2) = mean(H(sk).PEAdj(k,IPerp3),"omitnan");
        PertLate(k,3) = mean(H(sk).PEAdj(k,IPerp4),"omitnan"); PertLate(k,4) = mean(H(sk).PEAdj(k,IPerp5),"omitnan");
        PertLate(k,5) = mean(H(sk).PEAdj(k,IPerp6),"omitnan"); PertLate(k,6) = mean(H(sk).PEAdj(k,IPerp7),"omitnan");
        PertLate(k,7) = mean(H(sk).PEAdj(k,IPerp8),"omitnan"); PertLate(k,8) = mean(H(sk).PEAdj(k,IPerp9),"omitnan");
        
        % Total force = Exerted force at end of perturbation phase
        % more positive = more adaptation
        % non-adjusted force
        Iforce2=find(tp(1:Icounter)==17,3,'last'); Iforce4=find(tp(1:Icounter)==19,3,'last');
        Iforce6=find(tp(1:Icounter)==21,3,'last'); Iforce8=find(tp(1:Icounter)==23,3,'last');
        
        ForceLate(k,1)=mean(H(sk).EFTmax(k,Iforce2),"omitnan"); ForceLate(k,2)=mean(H(sk).EFTmax(k,Iforce4),"omitnan");
        ForceLate(k,3)=mean(H(sk).EFTmax(k,Iforce6),"omitnan"); ForceLate(k,4)=mean(H(sk).EFTmax(k,Iforce8),"omitnan");
        
        % adjusted force
        Iforce2=find(tp(1:Icounter)==17,3,'last'); Iforce4=find(tp(1:Icounter)==19,3,'last');
        Iforce6=find(tp(1:Icounter)==21,3,'last'); Iforce8=find(tp(1:Icounter)==23,3,'last');
        
        ForceLate2(k,1)=mean(H(sk).ForceAdj(k,Iforce2),"omitnan"); ForceLate2(k,2)=mean(H(sk).ForceAdj(k,Iforce4),"omitnan");
        ForceLate2(k,3)=mean(H(sk).ForceAdj(k,Iforce6),"omitnan"); ForceLate2(k,4)=mean(H(sk).ForceAdj(k,Iforce8),"omitnan");
        

        % Implicit adaptation = Error of catch trials at end of
        % perturbation phase last 12, 3 per trials where catch trials where
        % used.
        % more negative = more implicit
        Icatch2=find(tp==34,3,'last'); Icatch4=find(tp==35,3,'last');
        Icatch6=find(tp==36,3,'last'); Icatch8=find(tp==37,3,'last');
        
        CatchLate(k,1)=mean(H(sk).PEAdj(k,Icatch2),"omitnan"); CatchLate(k,2)=mean(H(sk).PEAdj(k,Icatch4),"omitnan");
        CatchLate(k,3)=mean(H(sk).PEAdj(k,Icatch6),"omitnan"); CatchLate(k,4)=mean(H(sk).PEAdj(k,Icatch8),"omitnan");
        
        % Explicit adaptation = (Error start perturbation - error end perturbation) - | error catch trials end of perturbation phase | 
        % more positive = more explicit
        Ifirst2 = find(tp==9,1);  Ifirst4 = find(tp==11,1);
        Ifirst6 = find(tp==13,1); Ifirst8 = find(tp==15,1);
        
        for i=1:length(Icatch2)
            Icued2(i) = find(tp(1:Icatch2(i))==9,1,'last');
            Icued4(i) = find(tp(1:Icatch4(i))==11,1,'last');
            Icued6(i) = find(tp(1:Icatch6(i))==13,1,'last');
            Icued8(i) = find(tp(1:Icatch8(i))==15,1,'last');
        end
        
        Explicit(k,1) = mean((H(sk).PEAdj(k,Ifirst2) - H(sk).PEAdj(k,Icued2)) - abs(H(sk).PEAdj(k,Icatch2)),"omitnan");
        Explicit(k,2) = mean((H(sk).PEAdj(k,Ifirst4) - H(sk).PEAdj(k,Icued4)) - abs(H(sk).PEAdj(k,Icatch4)),"omitnan");
        Explicit(k,3) = mean((H(sk).PEAdj(k,Ifirst6) - H(sk).PEAdj(k,Icued6)) - abs(H(sk).PEAdj(k,Icatch6)),"omitnan");
        Explicit(k,4) = mean((H(sk).PEAdj(k,Ifirst8) - H(sk).PEAdj(k,Icued8)) - abs(H(sk).PEAdj(k,Icatch8)),"omitnan");
        
        % Spontaneous recovery = Force at end of error-clamp phase last 40,
        % 5 per targetit
        it=6;
        Iclamp2=find(tp==17,it,'last'); Iclamp3=find(tp==18,it,'last');
        Iclamp4=find(tp==19,it,'last'); Iclamp5=find(tp==20,it,'last');
        Iclamp6=find(tp==21,it,'last'); Iclamp7=find(tp==22,it,'last');
        Iclamp8=find(tp==23,it,'last'); Iclamp9=find(tp==24,it,'last');
        %%JJ changed this as only half of the targets are corrected for
        %%baseline. So, if spontaneous recovery is computed for all targets
        %%together, we need to do it based on non-baseline-corrected force
        SpontLate(k,1)=mean(H(sk).EFTmax(k,Iclamp2),"omitnan"); SpontLate(k,2)=mean(H(sk).EFTmax(k,Iclamp3),"omitnan");
        SpontLate(k,3)=mean(H(sk).EFTmax(k,Iclamp4),"omitnan"); SpontLate(k,4)=mean(H(sk).EFTmax(k,Iclamp5),"omitnan");
        SpontLate(k,5)=mean(H(sk).EFTmax(k,Iclamp6),"omitnan"); SpontLate(k,6)=mean(H(sk).EFTmax(k,Iclamp7),"omitnan");
        SpontLate(k,7)=mean(H(sk).EFTmax(k,Iclamp8),"omitnan"); SpontLate(k,8)=mean(H(sk).EFTmax(k,Iclamp9),"omitnan");
        
        % Spontaneous recovery = Force at end of error-clamp phase last 24,
        % 3 per target
        %%JJ : only 17, 19, 21 and 23 are baseline corrected. What if we
        %%do the analyses only based on those?
        SpontLate2(k,1)=mean(H(sk).ForceAdj(k,Iclamp2),"omitnan");
        SpontLate2(k,2)=mean(H(sk).ForceAdj(k,Iclamp4),"omitnan");
        SpontLate2(k,3)=mean(H(sk).ForceAdj(k,Iclamp6),"omitnan");
        SpontLate2(k,4)=mean(H(sk).ForceAdj(k,Iclamp8),"omitnan");

        %% changed by JJ on 09/06/2023
        AdaptIndexLate(k,1)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp2))),"omitnan"); AdaptIndexLate(k,2)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp3))),"omitnan");
        AdaptIndexLate(k,3)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp4))),"omitnan"); AdaptIndexLate(k,4)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp5))),"omitnan");
        AdaptIndexLate(k,5)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp6))),"omitnan"); AdaptIndexLate(k,6)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp7))),"omitnan");
        AdaptIndexLate(k,7)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp8))),"omitnan"); AdaptIndexLate(k,8)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp9))),"omitnan");
        %% for baseline corrected targets
        AdaptIndexLate2(k,1)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp2))),"omitnan"); 
        AdaptIndexLate2(k,2)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp4))),"omitnan"); 
        AdaptIndexLate2(k,3)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp6))),"omitnan"); 
        AdaptIndexLate2(k,4)=mean(H(sk).AdapIndex(k,find(ismember(ClampTrials,Iclamp8))),"omitnan");

    end
    G(sk).PertLate = mean(PertLate,2,"omitnan");
    G(sk).ForceLate = mean(ForceLate,2,"omitnan");
    G(sk).ForceLate2 = mean(ForceLate2,2,"omitnan");
    G(sk).CatchLate = mean(CatchLate,2,"omitnan");
    G(sk).Explicit = mean(Explicit,2,"omitnan");
    G(sk).SpontLate = mean(SpontLate,2,"omitnan");
    G(sk).SpontLate2 = mean(SpontLate2,2,"omitnan");
    G(sk).AdaptIndexLate = mean(AdaptIndexLate,2,"omitnan");
    G(sk).AdaptIndexLate2 = mean(AdaptIndexLate2,2,"omitnan");
end

%% 3 PLOTS  + Statistics
Colors = [[86,180,233] ; [230,159,0]]./255;
markers = ['v','o','d','^','x','s'];

Group(1:length(ANASub(1).S))={'Y'};
Group(length(ANASub(1).S)+1:length(ANASub(1).S)+length(ANASub(2).S))={'O'};
groupLabels = [cellfun(@(x) strcmp(x,'Y'),Group)]*1;
groupLabels(~groupLabels)=2;
groupLabels2 = groupLabels(3:end);%% missing working memory capacity data from two young participants

%% Figure 1: methods. Not done in Matlab

%% Figure 2
% PLOT 1: TIMECOURSE OF PERPENDICULAR ERROR FOR THE POPULATION
figure
hold on
for sk=1:length(ANASub)
    AverageError = mean(H(sk).PEField,"omitnan");
    plot(FieldTrials,AverageError,'Color',Colors(sk,:))
    AverageCatch = mean(H(sk).PECatch,"omitnan");
    plot(CatchTrials,AverageCatch,'o','MarkerFaceColor',Colors(sk,:),'MarkerEdgeColor','none')
end
xlabel('Trial number','FontSize',11)
xlim([0 369])
xticks([0 73 282 306 369])
ylabel('Lateral deviation (mm)','FontSize',11)
legend({'Young cued','Young uncued','Older cued','Older uncued'},'Location','Best')
legend('boxoff')
box off
title("Fig.1A: TIMECOURSE OF PERPENDICULAR ERROR FOR THE POPULATION")

% PLOT 2a: ERROR BARS TOTAL ADAPTATION (Perpendicular error)
figure
hold on
BarPlotJJ(G(1).PertLate(:),G(2).PertLate(:),"Fig.1B: ERROR BARS TOTAL ADAPTATION (Perpendicular error)",'','Lateral deviation (mm)',[-5,10])

% PLOT 2b: ERROR BARS HAND VELOCITY (end of learning period)
figure
BarPlotJJ(H(1).VeloLearning(:),H(2).VeloLearning(:),"Fig.1C: ERROR BARS HAND VELOCITY (end of learning period, field trials)",...
    "",'Hand velocity (m/s)',[0,0.9])

% PLOT 3 panel C: TIMECOURSE OF EXERTED FORCE DURING LEARNING FOR THE POPULATION
figure
hold on
for sk=1:length(ANASub)
    AverageForce = mean(H(sk).EFClamp(:,1:28),"omitnan");
    plot(ClampTrials(1:28),AverageForce,'o','MarkerFaceColor',Colors(sk,:),'MarkerEdgeColor','none')      
end
xlabel('Trial number')
ylabel('Exerted force (N)')
xlim([0 369])
xticks([0 73 282 306 369])
legend({'Young','Older'},'Location','Best')
legend('boxoff')
box off
title("Fig.1C: TIMECOURSE OF EXERTED FORCE DURING LEARNING FOR THE POPULATION")

% PLOT 4a: ERROR BARS TOTAL ADAPTATION (Exerted force)
figure
subplot(1,2,1)
hold on
BarPlotJJ(G(1).ForceLate(:),G(2).ForceLate(:),"Fig.1D: ERROR BARS TOTAL ADAPTATION (Exerted force)",...
    "non-adjusted",'Exerted force (N)',[-5,10])
subplot(1,2,2)
hold on
BarPlotJJ(G(1).ForceLate2(:),G(2).ForceLate2(:),"Fig.1D: ERROR BARS TOTAL ADAPTATION (Exerted force)",...
    "adjusted",'Exerted force (N)',[-5,10])

% PLOT 4b: ERROR BARS HAND VELOCITY (end of learning period)
figure
BarPlotJJ(H(1).VeloClampLearning(:),H(2).VeloClampLearning(:),"Fig.1C: ERROR BARS HAND VELOCITY (end of learning period, clamp trials)",...
    "",'Hand velocity (m/s)',[0,0.9])


%% figure 3
% PLOT 6: ERROR BARS IMPLICIT ADAPTATION (Catch trials)
figure
BarPlotJJ(G(1).CatchLate(:),G(2).CatchLate(:),"Fig.3: ERROR BARS IMPLICIT ADAPTATION (Catch trials)",...
    "",'Lateral deviation (mm)',[-22,7])

% PLOT 7: ERROR BARS HAND VELOCITY (catch trials)
figure
BarPlotJJ(H(1).VeloCatch(:),H(2).VeloCatch(:),"PLOT 7: ERROR BARS HAND VELOCITY (catch trials)",...
    "",'Hand velocity (m/s)',[0 0.9])

%% figure 4
SpontRec(1:length(ANASub(1).S)) = G(1).SpontLate(:); 
SpontRec(length(ANASub(1).S)+1:length(ANASub(1).S)+length(ANASub(2).S)) = G(2).SpontLate(:);
order(1:28,1)={'young'}; order(29:48,1)={'older'};
SpontRec2(1:length(ANASub(1).S)) = G(1).SpontLate2(:); 
SpontRec2(length(ANASub(1).S)+1:length(ANASub(1).S)+length(ANASub(2).S)) = G(2).SpontLate2(:);

% PLOT 8: TIMECOURSE OF EXERTED FORCE DURING ERROR CLAMP PHASE
figure
hold on
for sk=1:length(ANASub)
    AverageForce = mean(H(sk).EFClamp(:,29:end),"omitnan");
    plot(ClampTrials(29:end),AverageForce,'o','MarkerFaceColor',Colors(sk,:),'MarkerEdgeColor','none')      
end
xlabel('Trial number')
ylabel('Exerted force (N)')
xlim([280 380])
xticks([282 306 369])
legend({'Young','Older'},'Location','Best')
legend('boxoff')
box off
title("PLOT 3: TIMECOURSE OF EXERTED FORCE DURING ERROR CLAMP PHASE")

% PLOT 9: ERRORBARS SPONTANEOUS RECOVERY
figure
subplot(1,2,1)
BarPlotJJ(G(1).SpontLate(:),G(2).SpontLate(:),"Fig.4: ERRORBARS SPONTANEOUS RECOVERY",...
    "non-adjusted",'Exerted force (N)',[-2,6])
subplot(1,2,2)
BarPlotJJ(G(1).SpontLate2(:),G(2).SpontLate2(:),"Fig.4: ERRORBARS SPONTANEOUS RECOVERY",...
    "adjusted",'Exerted force (N)',[-2,6])
% PLOT 10: ERROR BARS HAND VELOCITY (error clamp phase)
figure
BarPlotJJ(H(1).VeloSpont(:),H(2).VeloSpont(:),"PLOT 10: ERROR BARS HAND VELOCITY (error clamp phase)",...
    "",'Hand velocity (m/s)',[0 0.9])
%% figure 5
% see japstat code

%% figure 6
% PLOT 11: CORRELATION IMPLICIT ADAPTATION - SPONTANEOUS RECOVERY
figure
subplot(1,2,1)
hold on
for sk=1:length(ANASub)
    plot(G(sk).CatchLate(:)*-1,G(sk).SpontLate(:),'o','MarkerFaceColor',Colors(sk,:),'MarkerEdgeColor','none')
end
xlabel('Implicit adaptation (mm)')
ylabel('Spontaneous recovery (N)')

Implicit(1:length(ANASub(1).S)) = G(1).CatchLate(:); 
Implicit(length(ANASub(1).S)+1:length(ANASub(1).S)+length(ANASub(2).S)) = G(2).CatchLate(:);

brob=robustfit(Implicit*-1,SpontRec);
plot(Implicit*-1,brob(1)+brob(2)*(Implicit*-1),'k')
legend('Young','Older','Location','Best')
legend('boxoff')
title("PLOT 12: CORRELATION IMPLICIT ADAPTATION - SPONTANEOUS RECOVERY")
subtitle("non-adjusted")

subplot(1,2,2)
hold on
for sk=1:length(ANASub)
    plot(G(sk).CatchLate(:)*-1,G(sk).SpontLate2(:),'o','MarkerFaceColor',Colors(sk,:),'MarkerEdgeColor','none')
end
xlabel('Implicit adaptation (mm)')
ylabel('Spontaneous recovery (N)')

Implicit(1:length(ANASub(1).S)) = G(1).CatchLate(:); 
Implicit(length(ANASub(1).S)+1:length(ANASub(1).S)+length(ANASub(2).S)) = G(2).CatchLate(:);

brob=robustfit(Implicit*-1,SpontRec2);
plot(Implicit*-1,brob(1)+brob(2)*(Implicit*-1),'k')
legend('Young','Older','Location','Best')
legend('boxoff')
title("PLOT 12: CORRELATION IMPLICIT ADAPTATION - SPONTANEOUS RECOVERY")
subtitle("adjusted")

% remove particpants without working memory capacity score
Kparticipants = setdiff(1:length(Implicit),[3 19]);
ImplicitCorr = Implicit(Kparticipants);

%% figure 7
% PLOT 12: ERRORBARS EXPLICIT ADAPTATION (Cued - catch trials)
figure
BarPlotJJ(G(1).Explicit(:),G(2).Explicit(:),"Fig.7: ERRORBARS EXPLICIT ADAPTATION (Cued - catch trials)",...
    "",'Lateral deviation (mm)',[-22,10])

% PLOT 13: Correlation explicit adaptation - Working memory capacity K
%%JJ
Explicit = [G(1).Explicit;G(2).Explicit];
Expl = -Explicit(Kparticipants);
X = [ones(length(Expl),1) Expl];
b = X\(K);
y=b(1)+(Expl)*b(2);
brob2=robustfit(Expl,K);

figure
plot(Expl(1:26),K(1:26),'o','MarkerFaceColor',Colors(1,:),'MarkerEdgeColor','none')
hold on
plot(Expl(27:end),K(27:end),'o','MarkerFaceColor',Colors(2,:),'MarkerEdgeColor','none')
plot((Expl),y,'k')
plot(Expl,brob2(1)+brob2(2)*Expl,'--k')
xlabel('Explicit adaptation (mm)')
ylabel('Working memory capacity score')
box off
legend('Young','Older')
box off
title(" PLOT 13: Correlation explicit learning - Working memory capacity K")

% PLOT 14: comparing working memory capacity: young vs. old
figure
BarPlotJJ(K(groupLabels2==1),K(groupLabels2==2),"PLOT 14: ERRORBARS working memory capacity",...
    "",'working memory capacity',[-0.5,6.5])

% PLOT 15: Correlation spontaneous recovery - Working memory capacity K
%%JJ
SpontRecCorr = SpontRec(Kparticipants)';
brob2=robustfit(K, SpontRecCorr);
Km = [min(K),max(K)];
figure
plot(K(1:26),SpontRecCorr(1:26),'o','MarkerFaceColor',Colors(1,:),'MarkerEdgeColor','none')
hold on
plot(K(27:end),SpontRecCorr(27:end),'o','MarkerFaceColor',Colors(2,:),'MarkerEdgeColor','none')
plot(Km,brob2(1)+brob2(2)*Km,'k')
ylabel('Spontaneous recovery (N)')
xlabel('Working memory capacity score')
box off
legend('Young','Older')
box off
title(" PLOT 15: Correlation explicit learning - Working memory capacity K")


% % PLOT 16: Adaptation index clamp trials
figure
hold on
for sk=1:length(ANASub)
    AverageIndex = median(H(sk).AdapIndex,"omitnan");
    SEMIndex = std(H(sk).AdapIndex,"omitnan")/sqrt(length(H(sk).AdapIndex));
    boundedline(ClampTrials,AverageIndex,SEMIndex,'cmap',Colors(sk,:))      
end
xlabel('Trial number')
ylabel('Adaptation Index')
xticks([0 Istart Icounter Ispont Iend])
ylim([-0.1 1])
legend('Young SEM','Young','Older SEM','Older')
title("PLOT 14: Adaptation index clamp trials")
subtitle('non-adjusted')

% PLOT 17: ERRORBARS ADAPINDEX SPONTANEOUS RECOVERY
figure
subplot(1,2,1)
BarPlotJJ(G(1).AdaptIndexLate(:),G(2).AdaptIndexLate(:),"PLOT 16: ERRORBARS ADAPINDEX SPONTANEOUS RECOVERY",...
    "non-adjusted",'Adaptation index',[-1,1])
subplot(1,2,2)
BarPlotJJ(G(1).AdaptIndexLate2(:),G(2).AdaptIndexLate2(:),"PLOT 16: ERRORBARS ADAPINDEX SPONTANEOUS RECOVERY",...
    "adjusted",'Adaptation index',[-1,1])

%% STATISTICS

% % TOTAL ADAPTATION young vs. old %perp displacement
% % ANCOVA: table with 1st column VeloLearning, 2nd PertLate, 3rd age-group --> aoctool
[h1,atab1,ctab1,stats1] = aoctool([H(1).VeloLearning';H(2).VeloLearning'],[G(1).PertLate;G(2).PertLate],Group,0.05,'','','','off','parallel lines');
% F(1,45)=0.0161, p=0.899

% % TOTAL ADAPTATION young vs. old %force applied
% % ANCOVA: table with 1st column VeloLearning, 2nd ForceLate, 3rd age-group --> aoctool
[h1_f,atab1_f,ctab1_f,stats1_f] = aoctool([H(1).VeloClampLearning';H(2).VeloClampLearning'],[G(1).ForceLate;G(2).ForceLate],Group,0.05,'','','','off','parallel lines');
% F(1,45)=1.84, p=0.18

% % ANCOVA: table with 1st column VeloLearning, 2nd ForceLate2, 3rd age-group --> aoctool
[h1_f2,atab1_f2,ctab1_f2,stats1_f2] = aoctool([H(1).VeloClampLearning';H(2).VeloClampLearning'],[G(1).ForceLate2;G(2).ForceLate2],Group,0.05,'','','','off','parallel lines');
% F(1,45)=1.64, p=0.21

% IMPLICIT ADAPTATION young vs. old
% % ANCOVA: table with 1st column VeloCatch, 2nd CatchLate, 3rd age-group --> aoctool
[h2,atab2,ctab2,stats2] =  aoctool([H(1).VeloCatch';H(2).VeloCatch'],[G(1).CatchLate;G(2).CatchLate],Group,0.05,'','','','off','parallel lines');
% F(1,45)=2.18, p=0.146

% SPONTANEOUS RECOVERY young vs. old - covariate: handvelocity
% % ANCOVA: table with 1st column VeloSpont, 2nd SpontLate, 3rd age-group --> aoctool
[h3,atab3,ctab3,stats3] = aoctool([H(1).VeloSpont';H(2).VeloSpont'],[G(1).SpontLate;G(2).SpontLate],Group,0.05,'','','','off','parallel lines');
% F(1,45)=0.138, p=0.71

% SPONTANEOUS RECOVERY2 young vs. old - covariate: handvelocity - only four
% targets
% % ANCOVA: table with 1st column VeloSpont, 2nd SpontLate, 3rd age-group --> aoctool
[h32,atab32,ctab32,stats32] = aoctool([H(1).VeloSpont';H(2).VeloSpont'],[G(1).SpontLate2;G(2).SpontLate2],Group,0.05,'','','','off','parallel lines');
% F(1,45)=0.0038, p=0.96


% SPONTANEOUS RECOVERY young vs. old - covariate: implicit adaptation
% % ANCOVA: table with 1st column Implicit, 2nd SpontLate, 3rd age-group --> aoctool
[h3isp,atab3isp,ctab3isp,stats3isp] = aoctool([G(1).CatchLate;G(2).CatchLate],[G(1).SpontLate;G(2).SpontLate],Group,0.05,'','','','off','parallel lines');
% F(1,45)=1.317, p=0.2571

% SPONTANEOUS RECOVERY2 young vs. old - covariate: implicit adaptation - only four
% targets
% % ANCOVA: table with 1st column VeloSpont, 2nd SpontLate, 3rd age-group --> aoctool
[h32isp,atab32isp,ctab32isp,stats32isp] = aoctool([G(1).CatchLate;G(2).CatchLate],[G(1).SpontLate2;G(2).SpontLate2],Group,0.05,'','','','off','parallel lines');
% F(1,45)=0.678, p=0.41

% CORRELATION IMPLICIT ADAPTATION - SPONTANEOUS RECOVERY
[Ris,Pis] = corrcoef(Implicit*-1,SpontRec); % r=-0.501, p = 0.0002465
bgc = [Implicit'*-1,SpontRec',groupLabels'];
writematrix(bgc,'implicit_spontrec_groups_NoTitle.txt')
% use R program to perform multilevel correlations
% Parameter1 | Parameter2 |     r |             CI | t(46) |         p
% --------------------------------------------------------------------
% Implicit   |   SpontRec | -0.50 | [-0.69, -0.25] | -3.94 | < .001***

% CORRELATION EXPLICIT ADAPTATION - WORKING MEMORY
[rex, pex] = corr(Expl,K,'type','Spearman'); % r=0.1603, p=0.2873
bgc = [Expl,K,groupLabels2'];
writematrix(bgc,'explicit_WM-K_groups.txt')
% use R program to perform multilevel correlations:
% Parameter1 | Parameter2 |    r |            CI | t(44) |     p
% --------------------------------------------------------------
% Explicit   |        WMK | 0.12 | [-0.17, 0.40] |  0.81 | 0.421

% CORRELATION Spontaneous recovery - WORKING MEMORY
[rimpK, pimpK] = corr(ImplicitCorr',K,'type','Spearman'); % r=0.1603, p=0.2873
bgc = [ImplicitCorr',K,groupLabels2'];
writematrix(bgc,'implicit_WM-K_groups.txt')
% use R program to perform multilevel correlations:
% Parameter1 | Parameter2 |     r |            CI | t(44) |     p
% ---------------------------------------------------------------
% Implicit   |        WMK | -0.05 | [-0.34, 0.24] | -0.36 | 0.717