%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: Batch_01_computeAudioTempo
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description:
%   Compute average tempo in BPM from tempo histograms and saves it in a 
%   CSV file.
%
% Note:
%   There are two versions of the stimuli of the EEG experiment (v1 and v2),
%   see versionID variable.
%
% Reference:
%   [SPG16] Sebastian Stober; Thomas Prätzlich & Meinard Müller.
%   Brain Beats: Tempo Extraction from EEG Data.
%   International Society for Music Information Retrieval
%   Conference (ISMIR), 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Stimuli IDs
mat_sIDs = [ ...
    01 02 03 04 ...
    11 12 13 14 ...
    21 22 23 24 ...
    ];
S=length( mat_sIDs );
cell_versions = {
%     'v1' % uncomment if you work with particpants < 09
    'v2'
    };

file_pattern = 'temphist-audio_S%02d-%s-twin8';

sID = [];
cell_tempo = cell(S,1);
for v = 1:length( cell_versions )
    versionID = cell_versions{v};
    
    for s = 1:S
        sID = mat_sIDs(s);
        filename = sprintf( file_pattern, sID, versionID);
        
        d=load( ['results/' filename] );
        BPM      = d.BPM;
        temphist = dean_tempogram;
        
        [m,idx] = max( temphist );
        
        cell_tempo{s} = BPM(idx);
    end
    
    t1=table( mat_sIDs' );
    t1.Properties.VariableNames = {'sID'};
    
    
    t2=cell2table( cell_tempo);
    t2.Properties.VariableNames = {'BPM'};
    
    table_tempo = [t1 t2];
    
    filename = sprintf( 'results/table_tempo-%s_tempogram.csv', versionID );
    writetable( table_tempo, filename);
    
end