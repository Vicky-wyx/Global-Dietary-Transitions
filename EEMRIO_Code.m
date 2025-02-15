%% Baseline
clc;
clear;
load C_IO.mat % load GTAP MRIO
load C_GHG_new2.mat % load GHG emissions
Z0=IO(1:10400,1:10400); % intermediate input matrix
V0=sum(IO(10401:10405,1:10400),1);% vector of value added
X0=sum(IO(1:10400,:),2)'; % vector of total output
f0=reshape(GHGtot,1,65*160)./X0;  % sectoral emission intensity in 2017 
f0(isnan(f0))=0;
A0=Z0./X0; % coefficient matrix of intermediate inputs
K=V0./X0; % intensity vector of value added 
II=eye(10400,10400);
L0=inv(II-A0); % Leontief inverse matrix
Y0=IO(1:10400,10401:end); % total final demand in 2017
for i=1:160
    yh(:,i)=Y0(:,(2+i*3-3));% household final demand in 2017
end

yhf=zeros(10400,160); % household final demand for food in 2017
for i=1:160
   for j=[1,2,3,4,5,6,9,10,11,14,19:20]
    yhf(j+i*65-65,:)=yh(j+i*65-65,:);
   end
end
Etot0=f0'.*(L0*yhf); % current diet-related emissions
EGDP0=K'.*(L0*yhf); % current diet-related GDP
%% Scenario analysis
yhfitem=readmatrix('Final_GTAP_Result.xlsx','Sheet','GTAP result','Range','G4:FJ56323'); % household final demand for food by item in 2017
S1=readmatrix('Nutrition group(11)-percentage-Eatlancet.xlsx','Sheet','Scenario-Eat(item) (2)','Range','E3:FH354'); % percentage changes in diet by item under EAT-Lancet scenario;
S2=readmatrix('Nutrition group(11)-percentage - HDB.xlsx','Sheet','Scenario-HDB(item) (2)','Range','E3:FH354'); % percentage changes in diet by item under HDB scenario;
S3=readmatrix('Nutrition group(11)-percentage - G7.xlsx','Sheet','Scenario-G7(item)（2）','Range','E3:FH354'); % percentage changes in diet by item under G7-style scenario;
S4=readmatrix('Nutrition group(11)-percentage - Nation.xlsx','Sheet','Scenario-National(item) (2)','Range','E3:FH354'); % percentage changes in diet by item under Region-specific frontiers scenario;
P(:,:,1)=repmat(S1,160,1);% percentage changes in diet under EAT-Lancet scenario(by item)
P(:,:,2)=repmat(S2,160,1);% under HDB scenario;
P(:,:,3)=repmat(S3,160,1);% under G7-style scenario;
P(:,:,4)=repmat(S4,160,1);% under Region-specific frontiers scenario;
P(isnan(P))=0;

for i=1:4
  yhfitem_S(:,:,i)=yhfitem.*P(:,:,i); % changes in diet under 4 different scenarios(by item)
end
yhf_S=zeros(10400,160,4); % changes in diet under 4 different scenarios(by sector)
for j=1:160
    yhf_S((1+65*j-65),:,:)=yhfitem_S(1+352*j-352,:,:);
    yhf_S((2+65*j-65),:,:)=yhfitem_S(2+352*j-352,:,:);
    yhf_S((3+65*j-65),:,:)=sum(yhfitem_S((3+352*j-352):(15+352*j-352),:,:),1);
    yhf_S((4+65*j-65),:,:)=sum(yhfitem_S((16+352*j-352):(109+352*j-352),:,:),1);
    yhf_S((5+65*j-65),:,:)=sum(yhfitem_S((110+352*j-352):(118+352*j-352),:,:),1);
    yhf_S((6+65*j-65),:,:)=sum(yhfitem_S((119+352*j-352):(120+352*j-352),:,:),1);
    yhf_S((9+65*j-65),:,:)=yhf((9+65*j-65),:).*mean(P(136:152,:,:),1,"omitnan");
    yhf_S((10+65*j-65),:,:)=sum(yhfitem_S((121+352*j-352):(124+352*j-352),:,:),1);
    yhf_S((11+65*j-65),:,:)=sum(yhfitem_S((125+352*j-352):(129+352*j-352),:,:),1);
    yhf_S((14+65*j-65),:,:)=sum(yhfitem_S((130+352*j-352):(135+352*j-352),:,:),1);
    yhf_S((19+65*j-65),:,:)=sum(yhfitem_S((136+352*j-352):(152+352*j-352),:,:),1);
    yhf_S((20+65*j-65),:,:)=sum(yhfitem_S((153+352*j-352):(175+352*j-352),:,:),1);
    yhf_S((21+65*j-65),:,:)=sum(yhfitem_S((176+352*j-352):(213+352*j-352),:,:),1);
    yhf_S((22+65*j-65),:,:)=sum(yhfitem_S((214+352*j-352):(247+352*j-352),:,:),1);
    yhf_S((23+65*j-65),:,:)=sum(yhfitem_S((248+352*j-352):(251+352*j-352),:,:),1);
    yhf_S((24+65*j-65),:,:)=sum(yhfitem_S((252+352*j-352):(256+352*j-352),:,:),1);
    yhf_S((25+65*j-65),:,:)=sum(yhfitem_S((257+352*j-352):(341+352*j-352),:,:),1);
    yhf_S((26+65*j-65),:,:)=sum(yhfitem_S((342+352*j-352):(352+352*j-352),:,:),1);
end

dEtot_S=zeros(10400,160,4); % changes in diet-related emissions under 4 different scenarios
 for i=1:4
    dEtot_S(:,:,i)=f0'.*(L0*yhf_S(:,:,i));
 end
Etot_S=dEtot_S+Etot0; % total diet-related emissions under 4 different scenarios

dEGDP_S=zeros(10400,160,4); % changes in diet-related GDP under 4 different scenarios
 for i=1:4
    dEGDP_S(:,:,i)=K'.*(L0*yhf_S(:,:,i));
 end
EGDP_S=dEGDP_S+EGDP0; % total diet-related GDP under 4 different scenarios
 
%% Sensitivity test for sustainable agricultural practices 
F0re=reshape(readmatrix('improved intensity.xlsx','Sheet','Sheet1','Range','B4:FE68'),1,10400);% tested emission intensity

dEtot_S2=zeros(10400,160,4); % changes in diet-related emissions under 4 different scenarios
 for i=1:4
    dEtot_S2(:,:,i)=F0re'.*(L0*yhf_S(:,:,i));
 end
Etot_S2=dEtot_S2+Etot0; % total diet-related emissions under 4 different scenarios
