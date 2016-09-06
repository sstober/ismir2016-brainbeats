%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: Batch_00_tempoHistograms
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description: 
%   Computes and saves audio and EEG tempo histograms.
%   This script needs to run before evoking the evaluation scripts
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
bpm_GT = readtable('data/bpm_annotation.txt');

bool_visualize = false; % if true, visualize tempograms and results overview
dataIdx = 2;
data = {
%     'raw', 'raw/cond1/';          % raw EEG data, uncomment for processing raw data
    'sce', 'sce-filtered/cond1/'; % SCE filtered EEG data
    };
filename_prefix  = data{dataIdx,1};

mat_numPeaks = [1 2 3];
% mat_numPeaks = 1;

% resultsDir = 'results_audiotempo/';
resultsDir = 'results/';

% stimulus IDs
mat_sIDs = [ ...
    01 02 03 04 ...
    11 12 13 14 ...
    21 22 23 24 ...
    ];

stimNum = size( mat_sIDs, 2);

% trial IDs
mat_tIDs = [01 02 03 04 05];
trialNum = size( mat_tIDs, 2);
trialIdx   = 1:trialNum;

%% parameters
tempo_win = 8;
smooth_len = .5; % window for local average in novelty curve

% participant ids
mat_pIDs = [ 09 11 12 13 14 ];

% mat_pIDs = [ 01 09];
% mat_pIDs = [ 01 04 06 07 09 11 12 13 14 ];
% mat_pIDs = [ 09 11 12 13 14 ];




% channelNum = 64;
% channelIdx = [1:channelNum];
% trialIdx   = [5];

% uncomment for processing raw data
% channelIdx = [11 32 46 47 48];
% channelIdx = [12,32,47,48,49];
% channelIdx = [24 21 20 3 52 12 60 57 47 55];

% error results
mat_beatError = zeros( stimNum, trialNum );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% configuration: directories, filenames ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_root = 'data/';
data_set  = data{dataIdx,2};
% data_set  = '';
dirData = [ data_root data_set ];

for numPeaks = mat_numPeaks
    for pIdx = 1:length( mat_pIDs )
        close all;
        pID = num2str( mat_pIDs(pIdx), '%02d');
        % loop over stimuli
        for sIdx = 1:length( mat_sIDs )
            sID = num2str( mat_sIDs(sIdx), '%02d');
            % there are two versions of stimuli:
            % v1: has been used for participants <8
            % v2: participants > 8
            versionID = 'v1';
            if str2num( pID ) > 8
                versionID = 'v2';
            end
            
            dirAudio = [data_root versionID '/'];
            filenameWav = [ sID '.wav'];
            filenameAnn = [ sID '.txt'];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% load wav file, automatically converted to Fs = 22050 and mono
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [audio,sideinfo] = wav_to_audio('', dirAudio ,filenameWav);
            Fs = sideinfo.wav.fs;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% compute novelty curve (audio)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            parameterNovelty = [];
            [noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% tempogram_fourier (audio)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            parameterTempogram = [];
            parameterTempogram.featureRate = featureRate;
            parameterTempogram.tempoWindow = tempo_win;         % window length in sec
            parameterTempogram.BPM = 30:1:240;          % tempo values
            
            [tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
            tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);
            
            tempogram_audio = tempogram_fourier;
            
            %  compute mean tempogram  (audio)
            mean_tempogram = mean(abs(tempogram_fourier),2);
            filename_results = [ resultsDir 'temphist-audio_S' sID '-' versionID '-twin' num2str(tempo_win)];
            save( filename_results ,'mean_tempogram','smooth_len', 'tempo_win','BPM');

            [ tempo_max_audio,  tempo_audioIdx ] = max( mean_tempogram(:) );
            
            % loop over trials
            for tIdx =  mat_tIDs
                trialIdx = tIdx;
                
                % filename for specific stimulus and participant
                filenamePart = [ sID '_P' pID 'at' ];
                
                %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % load annotations
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                annoData = csvread( [dirAudio filenameAnn] );
                
                %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % load EEG data
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                dataEEG = load( [dirData filenamePart]);
                
                %         dataEEG = load( [dirData 'cond2/' filenamePart]);
                dataEEG = double(dataEEG.data);
                
                featureRateEEG = 512;
                if dataIdx == 2 % SCE filtered data (already aggregated over channels)
                    tmpTensor = sum( dataEEG(trialIdx,:),1);
                    channelEEG = squeeze( sum( tmpTensor, 1 ));
                    parameterSmooth = [];
                    parameterSmooth.smooth_len = smooth_len;
                    [ noveltyCurveEEG, local_average ] = novelty_smoothedSubtraction_EEG( channelEEG,parameterSmooth );
                else % RAW data, sum over channels specified in channelIdx
                    tmpTensor = sum( dataEEG(trialIdx,channelIdx,:),2);
                    channelEEG = squeeze( sum( tmpTensor, 1 ))';
                    
                    parameterSmooth = [];
                    parameterSmooth.smooth_len = smooth_len;
                    [ noveltyCurveEEG, local_average ] = novelty_smoothedSubtraction_EEG( channelEEG,parameterSmooth );
                end
                
                
                %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % tempogram_fourier EEG
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                featureRate = featureRateEEG;
                noveltyCurve = noveltyCurveEEG;
                
                parameterTempogram = [];
                parameterTempogram.featureRate = featureRate;
                parameterTempogram.tempoWindow = tempo_win;         % window length in sec
                parameterTempogram.BPM = 30:1:240;          % tempo values
                
                [tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
                tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);
                
                filename_results = [ resultsDir filename_prefix '_tempogram_S' sID '-P' pID '-trial' num2str(trialIdx) '-twin' num2str(tempo_win) ];
                save( filename_results ,'tempogram_fourier','smooth_len', 'tempo_win','BPM');
                
                % mean tempo histogram
                mean_tempogram = mean(abs(tempogram_fourier),2);
                
                filename_results = [ resultsDir filename_prefix '_temphist_S' sID '-P' pID '-trial' num2str(trialIdx) '-twin' num2str(tempo_win) ];
                save( filename_results ,'mean_tempogram','smooth_len', 'tempo_win','BPM');
                
                if bool_visualize
                    % mean tempo histogram
                    figure;
                    %         mean_tempogram = mean(abs(tempogram_fourier),2);
                    hold on;
                    bar(BPM, mean_tempogram,'k')
                    idx = find( bpm_GT.sID == str2num(sID) );
                    stem( bpm_GT.BPM(idx), 1, 'r','marker','none' );
                    box on;
                    ylim([0 0.31])
                end
                %%
                [ mat_peakVal, mat_peakIdx ] = pickPeaks( mean_tempogram, numPeaks, 10 );
                
                mat_beatError( sIdx, tIdx ) = min( abs( BPM( tempo_audioIdx ) - BPM( mat_peakIdx ) ) );
            end
        end
        
        %% Save BPM error, smoothing length, and tempo window
        filename_results = [ resultsDir filename_prefix '_' 'P' pID '-twin' num2str(tempo_win) '-max' num2str( numPeaks ) ];
        save( filename_results ,'mat_beatError','smooth_len', 'tempo_win');
        
        %% Plot Matrix with Absolute BPM Deviations
        if bool_visualize
            figure;
            
            imagesc( abs(mat_beatError) );
            colormap( 1-gray)
            c=colorbar;
            ylabel(c,'Absolute Beat Deviation')
            ylabel('Stimulus')
            xlabel('Trial')
            
            set( gca,'XTick', 1:trialNum)
            set( gca,'YTick', 1:stimNum )
            set( gca,'YTickLabel', num2cell( mat_sIDs ));
            
            set( gca,'clim',[0 20])
            
            pos = get(gcf,'PaperPosition');
            set(gcf,'PaperPosition',[pos(1) pos(2) pos(3)/2 pos(4)/2])
            
            
            % The following code is from http://stackoverflow.com/questions/3942892/how-do-i-visualize-a-matrix-with-colors-and-values-displayed
            % to show the absolute numbers in the matrix plot
            textStrings = num2str(round(mat_beatError(:)),'%02d');  %# Create strings from the matrix values
            textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
            [x,y] = meshgrid(1:size(mat_beatError,2),1:size(mat_beatError,1));   %# Create x and y coordinates for the strings
            hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
            midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
            textColors = repmat(mat_beatError(:) > midValue,1,3);  %# Choose white or black for the
            %#   text color of the strings so
            %#   they can be easily seen over
            %#   the background color
            set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
            
            
            print('-dpng',filename_results)
        end
        
    end
end