%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: DEMO
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description: 
%   Runs the different scripts to produce results from paper.
%    
% Reference: 
%   [SPG16] Sebastian Stober; Thomas Prätzlich & Meinard Müller.
%   Brain Beats: Tempo Extraction from EEG Data.
%   International Society for Music Information Retrieval 
%   Conference (ISMIR), 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Evaluation
Batch_00_tempoHistograms;   % compute tempo histograms
Batch_01_computeAudioTempo; % compute tempo from audio tempo histograms
Batch_02_aggregateResults;  % Aggregate beat error results into tensor (P:participants x S:stimuli x T:trials)

%% Figure 1,2,3,5
% Note that the raw dataset is needed for reproducing these figures.
% We have used the code from our HAMR session for these figures which can
% be found in the file brainbeats.zip at
%   http://labrosa.ee.columbia.edu/hamr_ismir2015/proceedings/doku.php?id=brainbeats
% The relevant code is in Figure_Presentation 

%% Figure 6
Batch_03_Fusion_Fig6; % fusion results

%% Figure 7
Fig7a_tempograms          % audio, tempogram, novelty curve
Fig7_tempoHistograms      % tempo histograms