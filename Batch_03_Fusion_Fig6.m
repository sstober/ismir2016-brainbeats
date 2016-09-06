%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: Experiment_Fusion_Fig6
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description: 
%   Compute results for different fusion strategies (no fusion, averaging
%   over trials of a given participant, averaging over all trials of a
%   given stimulus).
%   See Figure 6 in [SPG16].
%   
% Reference: 
%   [SPG16] Sebastian Stober; Thomas Prätzlich & Meinard Müller.
%   Brain Beats: Tempo Extraction from EEG Data.
%   International Society for Music Information Retrieval 
%   Conference (ISMIR), 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('matlab_helpers');
close all
clear;

% filename = 'raw-agg_temphist_twin8';
filename = 'sce-agg_temphist_twin8';
numPeaks = 1;  % use best match from top 1 tempo estimate
% numPeaks = 2;  % use best match from top 2 tempo estimates
% numPeaks = 3;  % use best match from top 3 tempo estimates

% intervals for bining values in colormap
intervals =  [ 0 3; 3 5; 5 7; 8 8.5];

mat_tresh = [ 0 3 5 7];
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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% no fusion 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat_beatError_single      = zeros(S,P,T);
mat_beatError_meanTrial   = zeros(S,P);
mat_beatError_meanStim    = zeros(S,1);

mat_errorRate = zeros( length(mat_tresh), 3);
for p = 1:P
    pID = mat_pIDs(p);
    if pID > 8 % all participants after P09 had a modified stimulus
        audioTempo = audioTempoV2;
    else
        audioTempo = audioTempoV1;
    end
    for s = 1:S
        sID = mat_sIDs(s);
        for t = 1:T
            mean_tempogram = cell_temphist{p,s}(t,:);
            [ mat_peakVal, mat_peakIdx ] = pickPeaks( mean_tempogram, numPeaks, 10 );
            
            curAudioTempo = audioTempo.BPM(audioTempo.sID == sID);
            mat_beatError_single( s, p, t ) = min( abs( curAudioTempo - BPM( mat_peakIdx ) ) );
        end
    end
end

mat_errorRate(:,1) = compute_bpmErrorRate( mat_beatError_single, mat_tresh);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fusion: average over participant's trials  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for p = 1:P
    pID = mat_pIDs(p);
    if pID > 8 % all participants after P09 had a modified stimulus
        audioTempo = audioTempoV2;
    else
        audioTempo = audioTempoV1;
    end    
    for s = 1:S
        sID = mat_sIDs(s);
        mean_tempogram = mean( cell_temphist{p,s} );
        [ mat_peakVal, mat_peakIdx ] = pickPeaks( mean_tempogram, numPeaks, 10 );
        
        curAudioTempo = audioTempo.BPM(audioTempo.sID == sID);
        mat_beatError_meanTrial( s, p ) = min( abs( curAudioTempo - BPM( mat_peakIdx ) ) );
    end
end

mat_errorRate(:,2) = compute_bpmErrorRate( mat_beatError_meanTrial, mat_tresh);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fusion: average over all trials for a stimulus  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
audioTempo = audioTempoV2;
for s = 1:S
    sID = mat_sIDs(s);
    mean_tempogram = mean( cell2mat(cell_temphist(:,s)) );
    [ mat_peakVal, mat_peakIdx ] = pickPeaks( mean_tempogram, numPeaks, 10 );
    
    curAudioTempo = audioTempo.BPM(audioTempo.sID == sID);
    mat_beatError_meanStim( s ) = min( abs( curAudioTempo - BPM( mat_peakIdx ) ) );
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results table (LaTeX)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat_errorRate(:,3) = compute_bpmErrorRate( mat_beatError_meanStim, mat_tresh);
for t = 1:length(mat_tresh)
   fprintf('$%d$ & ',mat_tresh(t))
   fprintf('$%02.2f$ & $%02.2f$ & $%02.2f$ \\\\ \n',100*mat_errorRate(t,:))
   
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization single trials -> Figure 6a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigureFilename = [ 'Fusion_SingleTrials_' filename 'max' num2str(numPeaks)];
mat_results_meanStim = reshape( permute(mat_beatError_single,[1 3 2]),12,[]);
figure;
% imagesc(); % this is only to get the axis position of an imagesc without colorbar ...
pos_old = get(gca,'position');
paramVis = [];
% paramVis.intervals     = [ 0 0;1 3; 3 5; 5 7; 8 8.5];
paramVis.intervals     = intervals;
paramVis.drawSeparator = true;
paramVis.XTick      = 3:5:P*T;
paramVis.XTickLabel = cellfun( @(x) num2str( x,'%02d' ), num2cell( mat_pIDs) , 'UniformOutput', 0);
paramVis.YTick      = 1:S;
paramVis.YTickLabel = cellfun( @(x) num2str( x,'%02d' ), num2cell( mat_sIDs) , 'UniformOutput', 0);
[ h_figure, h_axis ] = visualize_singleTrials( mat_results_meanStim, paramVis );
pos = get(gcf,'PaperPosition');
set(gcf,'PaperPosition',printPaperPosition)
c= findall(gcf,'type','colorbar');


% export without colorbar
%------------------------
delete(c)
axes_h = findall(gcf,'type','axes');
linkprop(axes_h,'position');
set(h_axis,'Position',pos_old)
set(gcf,'PaperPosition',printPaperPosition)
box on;
print('-dpng', [dir_figures FigureFilename '_noCBar'],'-r600')
print('-dpdf', [dir_figures FigureFilename '_noCBar'])
% export with numbers ...
%------------------------
% plotNumberInMatrix( mat_results )
% box on;
% 
% print('-dpng', [dir_figures FigureFilename '_withNumbers'])


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization participant (averaged trials) -> Figure 6b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigureFilename = [ 'Fusion_ParticipantTrials_' filename 'max' num2str(numPeaks)];
mat_results_meanStim = mat_beatError_meanTrial;
figure;
% imagesc(); % this is only to get the axis position of an imagesc without colorbar ...
pos_old = get(gca,'position');
paramVis = [];
% paramVis.intervals     = [ 0 0;1 3; 3 5; 5 7; 8 8.5];
paramVis.intervals     = intervals;
paramVis.drawSeparator = false;
paramVis.XTick      = 1:P;
paramVis.XTickLabel = cellfun( @(x) num2str( x,'%02d' ), num2cell( mat_pIDs) , 'UniformOutput', 0);
paramVis.YTick      = 1:S;
paramVis.YTickLabel = cellfun( @(x) num2str( x,'%02d' ), num2cell( mat_sIDs) , 'UniformOutput', 0);
[ h_figure, h_axis ] = visualize_singleTrials( mat_results_meanStim, paramVis );
pos = get(gcf,'PaperPosition');
set(gcf,'PaperPosition',printPaperPosition)
c = findall(gcf,'type','colorbar');

% export without colorbar
%------------------------
delete(c)
axes_h = findall(gcf,'type','axes');
linkprop(axes_h,'position');
set(h_axis,'Position',pos_old)
set(gcf,'PaperPosition',printPaperPosition)
box on;
print('-dpng', [dir_figures FigureFilename '_noCBar'],'-r600')
print('-dpdf', [dir_figures FigureFilename '_noCBar'])

% export with numbers ...
%------------------------
% plotNumberInMatrix( mat_results )
% box on;
% 
% print('-dpng', [dir_figures FigureFilename '_withNumbers'])


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization participant (averaged trials) -> Figure 6a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigureFilename = [ 'Fusion_StimulusTrials_' filename 'max' num2str(numPeaks)];
myPrintPaperPosition = printPaperPosition;
myPrintPaperPosition(3) = myPrintPaperPosition(3)/2;
mat_results_meanStim = mat_beatError_meanStim;
figure;
% imagesc(); % this is only to get the axis position of an imagesc without colorbar ...
pos_old = get(gca,'position');
paramVis = [];
% paramVis.intervals     = [ 0 0;1 3; 3 5; 5 7; 8 8.5];
paramVis.intervals     = intervals;
paramVis.drawSeparator = false;
paramVis.XTick      = [];
paramVis.XTickLabel = cellfun( @(x) num2str( x,'%02d' ), num2cell( mat_pIDs) , 'UniformOutput', 0);
paramVis.YTick      = 1:S;
paramVis.YTickLabel = cellfun( @(x) num2str( x,'%02d' ), num2cell( mat_sIDs) , 'UniformOutput', 0);
[ h_figure, h_axis ] = visualize_singleTrials( mat_results_meanStim, paramVis );
pos = get(gcf,'PaperPosition');
set(gcf,'PaperPosition',myPrintPaperPosition)
c = findall(gcf,'type','colorbar');

% export without colorbar
%--------------------------------------------------------------------------
delete(c)
axes_h = findall(gcf,'type','axes');
linkprop(axes_h,'position');
% set(h_axis,'Position',pos_old)
set(gcf,'PaperPosition',myPrintPaperPosition)
box on;
print('-dpng', [dir_figures FigureFilename '_noCBar'],'-r600')
% print('-dpdf', [dir_figures FigureFilename '_noCBar'])

% export with numbers ...
%--------------------------------------------------------------------------
plotNumberInMatrix(mat_results_meanStim)
print('-dpng', [dir_figures FigureFilename '_withNumbers'],'-r600')
% print('-dpdf', [dir_figures FigureFilename '_withNumbers'])