%function Correct for systematic target errors
clear variables

%% 1) Load participants
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

allSub=dir('TRA_*.zip');
yo=1; ol=1;

for k=1:length(allSub)
    if findstr(allSub(k).name(10:end-4),G1)
        GR3sub(yo)=allSub(k);
        yo=yo+1;
    elseif findstr(allSub(k).name(10:end-4),G2)
        GR4sub(ol)=allSub(k);
        ol=ol+1;
    else
        disp('warning')
    end
end

group = 'c'; % Set group = 'y' for young people and group = 'o' if you want to look at the data from old people
% set to 'c' if you want to Compare the two groups.
if strcmp(group,'y')
    ANASub.S = GR1sub;
    TRASub.S = GR3sub;
elseif strcmp(group,'o')
    ANASub.S = GR2sub;
    TRASub.S = GR4sub;
elseif strcmp(group,'c')
    ANASub(1).S = GR1sub;
    ANASub(2).S = GR2sub;
    TRASub(1).S = GR3sub;
    TRASub(2).S = GR4sub;
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
H = struct('IFmax',cell(1,2),'Tmax',cell(1,2),'PETmax',cell(1,2),'EFTmax',cell(1,2),'VeloTmax',cell(1,2),'AdapIndex',cell(1,2),'ParaFirst',cell(1,2),...
    'PerpFirst',cell(1,2),'ParaLate',cell(1,2),'PerpLate',cell(1,2),'ParaCount',cell(1,2),'PerpCount',cell(1,2),'VeloLearning',cell(1,2),'VeloClampLearning',cell(1,2),'VeloCatch',cell(1,2),...
    'VeloSpont',cell(1,2),'PEsec',cell(1,2),'EFsec',cell(1,2),'PEAdj',cell(1,2),'PEField',cell(1,2),'PECatch',cell(1,2),'ForceAdj',cell(1,2),'EFClamp',cell(1,2));

SEe = nan(48,7);
SEf = nan(48,3); %SEf = nan(48,7);
%SEc = nan(48,7);
ANAfields = {'Load','tp','Latency'};
TRAfields = {'HandX','HandY','HandPerp','HandPara','HandParaVel','FS_ForcePerp','VectVel'};
for sk=1:length(ANASub)
    for k=1:length(ANASub(sk).S)
%         struct2var
        ANAstruct = CSV2STRUCT(ANASub(sk).S(k).name);
        for af=1:length(ANAfields)
            ANA.(ANAfields{af})=ANAstruct.(ANAfields{af});
        end
        % Get the field names
        fieldNames = fieldnames(ANA);

        % Convert structure fields to variables
        for i = 1:numel(fieldNames)
            fieldName = fieldNames{i};
            assignin('base', fieldName, ANA.(fieldName));
        end

        TRAstruct = CSV2STRUCT(TRASub(sk).S(k).name);
        for tf=1:length(TRAfields)
            if strcmp(TRAfields{tf}(1:3),'FS_')
                fieldName2 = [TRAfields{tf}(4:end)];
            else
                fieldName2 = TRAfields{tf};
            end
            TRA.(TRAfields{tf})=TRAstruct.(fieldName2);
        end
        % Get the field names
        fieldNames = fieldnames(TRA);

        % Convert structure fields to variables
        for i = 1:numel(fieldNames)
            fieldName = fieldNames{i};
            assignin('base', fieldName, TRA.(fieldName));
        end

        FieldTrials = find(Load~=3 & (tp<34 | tp>38)); % trials but not catch trials or error clamp trials
        CatchTrials = find(tp>33 & tp<38);
        ClampTrials = find(Load==3);
        HandPerp = HandPerp*1000; HandPara = HandPara*1000; % convert from m to mm
        %Pre-allocation
        if k==1
            H(sk).IFmax = nan(length(ANASub(sk).S),length(tp));
            H(sk).Tmax = nan(length(ANASub(sk).S),length(tp));
            H(sk).PETmax = nan(length(ANASub(sk).S),length(tp));
            H(sk).EFTmax = nan(length(ANASub(sk).S),length(tp));
            H(sk).VeloTmax = nan(length(ANASub(sk).S),length(tp));
            H(sk).AdapIndex = nan(length(ANASub(sk).S),length(ClampTrials));
            H(sk).ParaFirst = nan(100,length(ANASub(sk).S));
            H(sk).PerpFirst = nan(100,length(ANASub(sk).S));
            H(sk).ParaLate = nan(100,length(ANASub(sk).S));
            H(sk).PerpLate = nan(100,length(ANASub(sk).S));
            H(sk).ParaCount = nan(100,length(ANASub(sk).S));
            H(sk).PerpCount = nan(100,length(ANASub(sk).S));
            H(sk).PEsec = nan(length(ANASub(sk).S),length(tp));
            H(sk).EFsec = nan(length(ANASub(sk).S),length(tp));
            H(sk).PEAdj = nan(length(ANASub(sk).S),length(tp));
            H(sk).PEField = nan(length(ANASub(sk).S),length(FieldTrials));
            H(sk).PECatch = nan(length(ANASub(sk).S),length(CatchTrials));
            H(sk).ForceAdj = nan(length(ANASub(sk).S),length(tp));
            H(sk).EFClamp = nan(length(ANASub(sk).S),length(ClampTrials));
        end
        
        IdealForce=HandParaVel*12; % Ideal force = Parallel velocity (m/s) * viscosity of force field (12 N/m/s)
        IdealForce(:,1:Istart-1)=0;
        
        % Cut raw data
        DISTRUN=(sqrt(HandX.^2 + HandY.^2)); % distance covered from starting point to target
        ReachTarget=NaN(size(Latency));
        Reach1cm=NaN(size(Latency));
        PE=NaN(size(HandX));
        IF=NaN(size(HandX));
        EF=NaN(size(HandX));       
        Velo=NaN(size(HandX));
        ParaDisp=NaN(100,Iend);
        PerpDisp=NaN(100,Iend);
                
        for i= 1:length(Latency)
            if isnan(DISTRUN(1:100,i)) % NaNs
                continue
            elseif DISTRUN(:,i)<0.1 % less than 10cm distance covered
                continue
            elseif Latency(i)==-99 % wrong trial
                continue
            else
                ReachTarget(i)=find(DISTRUN(:,i)>0.1,1);
            end
            Diff=ReachTarget(i)-Latency(i)+1;
            if Diff<0
                continue
            else
                PE(1:Diff,i)=HandPerp(Latency(i):ReachTarget(i),i);
                IF(1:Diff,i)=IdealForce(Latency(i):ReachTarget(i),i);
                EF(1:Diff,i)=FS_ForcePerp(Latency(i):ReachTarget(i),i)*-1; % switch signs of EF to see things from the +ve side
                Velo(1:Diff,i)=VectVel(Latency(i):ReachTarget(i),i);
                vq=Diff;
                if vq<100 % to get a vector with length 100
                    vq=100;
                end
                ParaDisp(:,i)=interp1(HandPara(Latency(i):ReachTarget(i),i),1:(vq/100):vq);
                PerpDisp(:,i)=interp1(HandPerp(Latency(i):ReachTarget(i),i),1:(vq/100):vq);
                EFscaled(:,i)=interp1(EF(:,i),1:(vq/100):vq);
                IFscaled(:,i)=interp1(IF(:,i),1:(vq/100):vq);
            end
        end
        
        %% Calculate time point of maximal ideal force
        [H(sk).IFmax(k,:),H(sk).Tmax(k,:)]=max(IF); % maximal ideal force and its timing
        for i=1:length(H(sk).Tmax)
            H(sk).PETmax(k,i)=PE(H(sk).Tmax(k,i),i); % perpendicular error at time of maximal ideal force
            H(sk).EFTmax(k,i)=EF(H(sk).Tmax(k,i),i); % exerted force at time of maximal ideal force
            H(sk).VeloTmax(k,i)=Velo(H(sk).Tmax(k,i),i); % hand velocity at time of maximal ideal force
        end
        
        % Adaptation index - slope of regression of exerted force and ideal force per trial
        for i = 1:length(EFscaled)
            a = EFscaled(:,i);
            A = IFscaled(:,i);
            X = [ones(length(A),1) A];
            b(:,i) = X\a;
            %y = b(1)+A*b(2);
        end
        H(sk).AdapIndex(k,:) = b(2,ClampTrials);
            
        %% Calculate average hand trajectories to target
        % First perturbation trial - parallel and perpendicular pathways
        H(sk).ParaFirst(:,k) = ParaDisp(:,Istart);
        H(sk).PerpFirst(:,k) = PerpDisp(:,Istart);
        
        % Total adaptation - Parallel and perpendicular displacement
        IPerp2=find(tp==9,10,'last'); IPerp3=find(tp==10,10,'last');
        IPerp4=find(tp==11,10,'last'); IPerp5=find(tp==12,10,'last');
        IPerp6=find(tp==13,10,'last'); IPerp7=find(tp==14,10,'last');
        IPerp8=find(tp==15,10,'last'); IPerp9=find(tp==16,10,'last');
        
        ParaLate(:,1) = nanmean(ParaDisp(:,IPerp2),2); ParaLate(:,2) = nanmean(ParaDisp(:,IPerp3),2);
        ParaLate(:,3) = nanmean(ParaDisp(:,IPerp4),2); ParaLate(:,4) = nanmean(ParaDisp(:,IPerp5),2);
        ParaLate(:,5) = nanmean(ParaDisp(:,IPerp6),2); ParaLate(:,6) = nanmean(ParaDisp(:,IPerp7),2);
        ParaLate(:,7) = nanmean(ParaDisp(:,IPerp8),2); ParaLate(:,8) = nanmean(ParaDisp(:,IPerp9),2);
        H(sk).ParaLate(:,k)=nanmean(ParaLate,2);
        
        PerpLate(:,1) = nanmean(PerpDisp(:,IPerp2),2); PerpLate(:,2) = nanmean(PerpDisp(:,IPerp3),2);
        PerpLate(:,3) = nanmean(PerpDisp(:,IPerp4),2); PerpLate(:,4) = nanmean(PerpDisp(:,IPerp5),2);
        PerpLate(:,5) = nanmean(PerpDisp(:,IPerp6),2); PerpLate(:,6) = nanmean(PerpDisp(:,IPerp7),2);
        PerpLate(:,7) = nanmean(PerpDisp(:,IPerp8),2); PerpLate(:,8) = nanmean(PerpDisp(:,IPerp9),2);
        H(sk).PerpLate(:,k)=nanmean(PerpLate,2);
        
        % Counter perturbation - Parallel displacement
        ICount=find(tp>24 & tp<33,8,'last');
        H(sk).ParaCount(:,k)=nanmean(ParaDisp(:,ICount),2);
        H(sk).PerpCount(:,k)=nanmean(PerpDisp(:,ICount),2);
        
        Iforce2=find(tp(1:Icounter)==17,3,'last'); Iforce4=find(tp(1:Icounter)==19,3,'last');
        Iforce6=find(tp(1:Icounter)==21,3,'last'); Iforce8=find(tp(1:Icounter)==23,3,'last');
        Iforce = [Iforce2, Iforce4, Iforce6, Iforce8];
        %% Calculate average handvelocity
        H(sk).VeloLearning(k) = nanmean(H(sk).VeloTmax(k,FieldTrials(153:232))); % last 10 reaches to all targets
        H(sk).VeloClampLearning(k) = nanmean(H(sk).VeloTmax(k,Iforce)); % last xx clamp trials 
        H(sk).VeloCatch(k) = nanmean(H(sk).VeloTmax(k,CatchTrials(end-11:end))); % last 12 catch trials
        H(sk).VeloSpont(k) = nanmean(H(sk).VeloTmax(k,end-23:end));              % last 24 error clamp trials
    
        
        %% Correct field and catch trials for individual baseline systematic deviation errors (PE)
        It2b=find(tp==1,3,'last'); It4b=find(tp==3,3,'last');
        It6b=find(tp==5,3,'last'); It8b=find(tp==7,3,'last');
        It3b=find(tp==2,3,'last'); It5b=find(tp==4,3,'last');
        It7b=find(tp==6,3,'last'); It9b=find(tp==8,3,'last');
      
        It2fc=ismember(tp,[9 25 34]); It3fc=ismember(tp,[10 26]);
        It4fc=ismember(tp,[11 27 35]); It5fc=ismember(tp,[12 28]);
        It6fc=ismember(tp,[13 29 36]); It7fc=ismember(tp,[14 30]);
        It8fc=ismember(tp,[15 31 37]); It9fc=ismember(tp,[16 32]);
        
        H(sk).PEAdj(k,:) = H(sk).PETmax(k,:);
        H(sk).PEAdj(k,It2fc) = H(sk).PETmax(k,It2fc) - nanmean(H(sk).PETmax(k,It2b));
        H(sk).PEAdj(k,It3fc) = H(sk).PETmax(k,It3fc) - nanmean(H(sk).PETmax(k,It3b));
        H(sk).PEAdj(k,It4fc) = H(sk).PETmax(k,It4fc) - nanmean(H(sk).PETmax(k,It4b));
        H(sk).PEAdj(k,It5fc) = H(sk).PETmax(k,It5fc) - nanmean(H(sk).PETmax(k,It5b));
        H(sk).PEAdj(k,It6fc) = H(sk).PETmax(k,It6fc) - nanmean(H(sk).PETmax(k,It6b));
        H(sk).PEAdj(k,It7fc) = H(sk).PETmax(k,It7fc) - nanmean(H(sk).PETmax(k,It7b));
        H(sk).PEAdj(k,It8fc) = H(sk).PETmax(k,It8fc) - nanmean(H(sk).PETmax(k,It8b));
        H(sk).PEAdj(k,It9fc) = H(sk).PETmax(k,It9fc) - nanmean(H(sk).PETmax(k,It9b));
        
        H(sk).PEField(k,:) = H(sk).PEAdj(k,FieldTrials);
        H(sk).PECatch(k,:) = H(sk).PEAdj(k,CatchTrials);
                
        % Baseline averages to correct clamp trials for systematic exerted forces (EF)
        It2b=find(tp==40);
        It4b=find(tp==42);
        It6b=find(tp==44);
        It8b=find(tp==46);
      
        It2c=find(tp==17);
        It4c=find(tp==19);
        It6c=find(tp==21);
        It8c=find(tp==23);
               
        H(sk).ForceAdj(k,:) = H(sk).EFTmax(k,:);
        %%JJ: important, baseline only for 4 of the 8 targets.
        H(sk).ForceAdj(k,It2c) = H(sk).EFTmax(k,It2c) - nanmean(H(sk).EFTmax(k,It2b));
        H(sk).ForceAdj(k,It4c) = H(sk).EFTmax(k,It4c) - nanmean(H(sk).EFTmax(k,It4b));
        H(sk).ForceAdj(k,It6c) = H(sk).EFTmax(k,It6c) - nanmean(H(sk).EFTmax(k,It6b));
        H(sk).ForceAdj(k,It8c) = H(sk).EFTmax(k,It8c) - nanmean(H(sk).EFTmax(k,It8b));
        H(sk).EFClamp(k,:) = H(sk).ForceAdj(k,ClampTrials);
    end
end

save ('AllSubjectsDatatest.mat','H') %