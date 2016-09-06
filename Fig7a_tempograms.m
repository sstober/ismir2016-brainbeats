%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: Fig7a_tempograms
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description: 
%   Code for tempograms in Figure 7
%    
% Reference: 
%   [SPG16] Sebastian Stober; Thomas Prätzlich & Meinard Müller.
%   Brain Beats: Tempo Extraction from EEG Data.
%   International Society for Music Information Retrieval 
%   Conference (ISMIR), 2016
%
% License:
%     This script is derived from parts of the 'Tempogram Toolbox'.
% 
%     This script is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 2 of the License, or
%     (at your option) any later version.
% 
%     This script is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with 'Tempogram Toolbox'. If not, see
%     <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('MATLAB-Tempogram-Toolbox_1.0');
addpath('matlab_helpers');
clear
% close all
vis_audio = 0;
vis_EEG = 1;


% When localization is set to US, matlab uses inches as default units,
% centimeters otherwise
set(0,'DefaultFigurePaperUnits','centimeters')

% ground truth bpm data
bpm_GT = readtable('data/bpm_annotation.txt');
%%
% minBPM = 80;
minBPM = 80;
maxBPM = 240;

dataIdx = 2;
data = {
    'raw', 'raw/cond1/';
    'sce', 'sce-filtered/cond1/';
    };

data_root = 'data/';
data_set  = data{dataIdx,2};
% data_set  = '';
dirData = [ data_root data_set ];

% %%
printPaperPosition_WAV = [1   10   18  4]; %[left, bottom, width, height]
% printPaperPosition_Tempo = [1   10   18  8];
printPaperPosition_Tempo = [1   10   10  6];
printPaperPosition_Hist = [1   10   8  8];

%% parameters
tempoWindow = 8;
smooth_len = .5; % window for local average in novelty curve


%----------------------------
% Figure 7 tempogram row 1
pID = '09'; % participant
sIDset = {'14'};
trialIdx   = 2;
%----------------------------


%----------------------------
% Figure 7 tempogram row 2
% pID = '11'; % participant
% sIDset = {'04'};
% trialIdx   = 1;
%----------------------------

%----------------------------
% Figure 7 tempogram row 3
% pID = '12'; % participant
% sIDset = {'24'};
% trialIdx   = 3;
%----------------------------

% sIDset = {'14'}; % stimulus
% pID = '09'; % participant
% trialNum = 1;
% channelNum = 64;
% trialIdx   = [1:trialNum];
% % trialIdx   = [5];
% channelIdx = [11 32 46 47 48];



% sIDset = {'14'};
% channelNum = 64;
%trialIdx   = [1:5];
%channelIdx = [1:channelNum];
% trialIdx   =2;


% sIDset = {'01';'02';'03';'04';'11';'12';'13';'14';'21';'22';'23';'24'};
% channelIdx = [12,32,47,48,49];
% trialIdx   = 2;
% sIDset = {'14'};

sIDsetNum = size(sIDset,1);


for sIDcounter =1:sIDsetNum
    sID = sIDset{sIDcounter};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% configuration: directories, filenames ...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     dirData = 'data/';
    
    
    % there are two versions of stimuli:
    % v1: has been used for participants <8
    % v2: participants > 8
    audioVersion = 'v1/';
    if str2num( pID ) > 8
        audioVersion = 'v2/';
    end
    
    dirAudio = [data_root audioVersion];
    filenameWav = [ sID '.wav'];
    filenameAnn = [ data_root 'beats/cond1/' sID '_P' pID '.txt'];
    
    
    % filenamePart = '14_P01at';
    %filenamePart = '14_P09at';
    
    % filename for specific stimulus and participant
    filenamePart = [ sID '_P' pID 'at' ];
    FigFilenamePrefix = [   data{dataIdx,1} '_' sID '_P' pID '_' num2str(trialIdx) '_'];
    FigDir = 'figure/';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% load annotations
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    annoData = csvread( [filenameAnn] );
    
    
    if vis_EEG
        %% load EEG data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        dataEEG = load( [dirData filenamePart]);
        dataEEG = double(dataEEG.data);
        if dataIdx == 2
            tmpTensor = sum( dataEEG(trialIdx,:),1);
            channelEEG = squeeze( sum( tmpTensor, 1 ));
        else
            tmpTensor = sum( dataEEG(trialIdx,channelIdx,:),2);
            channelEEG = squeeze( sum( tmpTensor, 1 ))';
        end
        
        featureRateEEG = 512;
        
        parameterSmooth = [];
        parameterSmooth.smooth_len = smooth_len;
        [ noveltyCurveEEG, local_average ] = novelty_smoothedSubtraction_EEG( channelEEG,parameterSmooth );

        
        
        %% tempogram_fourier
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        featureRate = featureRateEEG;
        noveltyCurve = noveltyCurveEEG;
        
        parameterTempogram = [];
        parameterTempogram.featureRate = featureRate;
        parameterTempogram.tempoWindow = tempoWindow;         % window length in sec
        parameterTempogram.BPM = minBPM:1:maxBPM;          % tempo values
        
        [tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
        tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);
        
        visualize_tempogram(tempogram_fourier,T,BPM)
        printFile = 'Figure_EEG_Tempogram';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_Tempo);
        shrinkColorbar;
        print('-dpng',strcat(printFile),'-r600');
        
        
        stepsize = ceil(featureRate./5);
        win_len = round(tempoWindow.* featureRate);
        win_len = win_len + mod(win_len,2) - 1;
        parameter.tempoRate = featureRate ./ stepsize;
        
        % mean tempo histogram
        figure;
        mean_tempogram = mean(abs(tempogram_fourier),2);
        hold on;
        bar(BPM, mean_tempogram,'k')
        idx = find( bpm_GT.sID == str2num(sID) );
        stem( bpm_GT.BPM(idx), 1, 'r','marker','none' );
        box on;
        xlim([minBPM maxBPM]);
        ylim([0 0.31])
        
        printFile = 'Figure_EEG_Tempogram_Hist';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_Hist);
        print('-dpng',strcat(printFile),'-r600');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLP curve
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        parameterPLP = [];
        parameterPLP.featureRate = featureRate;
        parameterPLP.tempoWindow = parameterTempogram.tempoWindow;
        
        [PLP,featureRate] = tempogram_to_PLPcurve(tempogram_fourier, T, BPM, parameterPLP);
        PLP = PLP(1:length(noveltyCurve));  % PLP curve will be longer (zero padding)
        
        parameterVis = [];
        parameterVis.featureRate = featureRate;
        parameterVis.plotAnn = annoData;
        
        visualize_noveltyCurve(PLP,parameterVis)
        title('PLP curve')
        set(gcf,'Position',[ 7           6        1589         346]);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    if vis_audio
        %% load wav file, automatically converted to Fs = 22050 and mono
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [audio,sideinfo] = wav_to_audio('',[ dirAudio] ,filenameWav);
        Fs = sideinfo.wav.fs;
        
        figure;
        h = plot((0:length(audio)-1)/Fs,audio,'b');
        xlim([0 length(audio)/Fs]);
        ylim([-0.8 0.8])
        set(h,'LineWidth',1)
        printFile = 'Figure_WAV';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_WAV);
        print('-dpng',strcat(printFile),'-r600');
        
        
        hold on;
        stem(annoData,  1 * ones(1,length(annoData)),'r','marker','none')
        stem(annoData,  -1 * ones(1,length(annoData)),'r','marker','none')
        printFile = 'Figure_WAV_Ann';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_WAV);
        print('-dpng',strcat(printFile),'-r600');
        
        %% compute novelty curve
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        parameterNovelty = [];
        [noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);
        
        parameterVis = [];
        parameterVis.featureRate = featureRate;
        %parameterVis.plotAnn = annoData;
        visualize_noveltyCurve(noveltyCurve,parameterVis)
        %title('Novelty curve')
        printFile = 'Figure_WAV_Novelty';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_WAV);
        print('-dpng',strcat(printFile),'-r600');
        
        %% tempogram_fourier
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        parameterTempogram = [];
        parameterTempogram.featureRate = featureRate;
        parameterTempogram.tempoWindow = tempoWindow;         % window length in sec
        parameterTempogram.BPM = minBPM:1:maxBPM;          % tempo values
        
        [tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
        tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);
        
        visualize_tempogram(tempogram_fourier,T,BPM)
        
        
        printFile = 'Figure_WAV_Tempogram';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_Tempo);
        
        print('-dpng',strcat(printFile),'-r600');
        
        
        %% mean tempo histogram (audio)
        figure;
        mean_tempogram = mean(abs(tempogram_fourier),2);
        hold on;
        bar(BPM, mean_tempogram,'k')
        idx = find( bpm_GT.sID == str2num(sID) );
        stem( bpm_GT.BPM(idx), 1, 'r','marker','none' );
        box on;
        %         bar(BPM, mean_tempogram,'k')
        xlim([minBPM maxBPM]);
        ylim([0 0.31])
        
        pause(1)
        printFile = 'Figure_WAV_Tempogram_Hist';
        printFile = strcat(FigDir,FigFilenamePrefix,printFile);
        set(gcf,'PaperPosition',printPaperPosition_Hist);
        print('-dpng',strcat(printFile),'-r600');
        
        %% PLP curve
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        parameterPLP = [];
        parameterPLP.featureRate = featureRate;
        parameterPLP.tempoWindow = parameterTempogram.tempoWindow;
        
        [PLP,featureRate] = tempogram_to_PLPcurve(tempogram_fourier, T, BPM, parameterPLP);
        PLP = PLP(1:length(noveltyCurve));  % PLP curve will be longer (zero padding)
        
        parameterVis = [];
        parameterVis.featureRate = featureRate;
        parameterVis.plotAnn = annoData;
        
        visualize_noveltyCurve(PLP,parameterVis)
        title('PLP curve')
    end
end

