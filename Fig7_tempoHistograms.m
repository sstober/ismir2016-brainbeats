%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: Fig7
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description: 
%   Plot tempo histograms for Figure 7b-d
%
% Reference: 
%   [SPG16] Sebastian Stober; Thomas Prätzlich & Meinard Müller.
%   Brain Beats: Tempo Extraction from EEG Data.
%   International Society for Music Information Retrieval 
%   Conference (ISMIR), 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% filename = 'raw-agg_temphist_twin8';
filename = 'sce-agg_temphist_twin8';


minBPM = 80;
maxBPM = 240;


data_suffix = '';

% printPaperPosition = [0.6350    6.3500   10.1600    7.6200];
printPaperPosition = [0 0   6   6];

% printPaperPosition = [0.6350    6.3500   10.1600    7.6200];

dir_figures = ['figure' data_suffix '/'];
dir_results = ['results' data_suffix '/'];

% audioTempo = readtable('results/table_tempo_tempogram.csv');
% audioTempoV1 = readtable('data/bpm_annotation.txt');
% audioTempoV1 = readtable('results/table_tempo-v1_tempogram.csv');
audioTempoV2 = readtable('results/table_tempo-v2_tempogram.csv');

bpm_GT = audioTempoV2;
% audioTempo = audioTempoV1;
d=load( [ dir_results filename ] );
cell_temphist = d.cell_temphist;
BPM           = d.BPM;


% mat_pIDs = [ 01 04 06 07 09 11 12 13 14 ];
mat_pIDs = [ 09 11 12 13 14 ];



mat_sIDs = [ ...
    01 02 03 04 ...
    11 12 13 14 ...
    21 22 23 24 ...
    ];


P = length(mat_pIDs);
S = length(mat_sIDs);
T = 5;
mapS = containers.Map(mat_sIDs,1:S);
mapP = containers.Map(mat_pIDs,1:P);

mat_temphist = zeros(S, P, T, 211);
for s = 1:S
    for p = 1:P
        for t = 1:T
           mat_temphist(s,p,t,:) = cell_temphist{p,s}(t,:)';
        end 
    end 
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select data to plot here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First row
% %----------------------------
% sID = 14;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  mapP(09);
% t = 2; % trial idx
% %----------------------------

% %----------------------------
% sID = 14;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  mapP(09);
% t = 1:T; % trial idx
% %----------------------------

%----------------------------
% sID = 14;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p = 1:P; % participant idx
% t = 1:T; % trial idx
%----------------------------

% Second row
% %----------------------------
% sID = 04;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  mapP(11);
% t = 1; % trial idx
% %----------------------------
% 
% %----------------------------
% sID = 04;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  mapP(11);
% t = 1:5; % trial idx
% %----------------------------
% 
% 
% %----------------------------
% sID = 04;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  1:P;
% t = 1:5; % trial idx
% %----------------------------
% 
% 
% % Third row
% %----------------------------
sID = 24;      % stimulus ID 
s = mapS(sID); % stimulus idx
p =  mapP(12);
t = 3; % trial idx
% %----------------------------
% 
% %----------------------------
% sID = 24;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  mapP(12);
% t = 1:5; % trial idx
% %----------------------------
% 
% 
% %----------------------------
% sID = 24;      % stimulus ID 
% s = mapS(sID); % stimulus idx
% p =  1:P;
% t = 1:5; % trial idx
% %----------------------------

mat_histograms = reshape(permute(mat_temphist(s,p,t,:),[4 1 2 3]),211,numel(s)*numel(p)*numel(t))';
mean_tempogram= mean(mat_histograms,1);


%%
figure;
hold on;
idx = find( bpm_GT.sID == sID );
stem( bpm_GT.BPM(idx), 1, 'r','marker','none', 'LineWidth', 2 );

for k = 1:size( mat_histograms, 1 )
    bar(BPM,mat_histograms(k,:),1,'facecolor',[.6 .6 .6],'facealpha',.2,'edgecolor','none')
    
end
bar(BPM,mean_tempogram,1,'facecolor',[0 0 0 ],'facealpha',1,'edgecolor','none')
% plot( BPM, mean_tempogram, 'k' )
axis tight;
box on;
ylim([0 0.31])
ylim([0 0.2])
xlim([minBPM maxBPM])
printPaperPosition_Hist = [0 0   6   6];

FigDir = 'figure/';
FigFilenamePrefix = 'SCE_';
printFilePattern = 'Figure_EEG_temphist_S-%s_P-%s_T-%s';
printFile = sprintf(printFilePattern,num2str(mat_sIDs(s),'%02d'),num2str(mat_pIDs(p),'%02d'),num2str(t,'%02d'));
printFile = strcat(FigDir,FigFilenamePrefix,printFile);
set(gcf,'PaperPosition',printPaperPosition_Hist);
print('-dpng',strcat(printFile),'-r600');