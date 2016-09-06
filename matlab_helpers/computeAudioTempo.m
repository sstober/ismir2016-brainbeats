%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute average tempo in BPM from tempo histograms
% 
% Note: 
% There are two versions of the stimuli of the EEG experiment (v1 and v2),
% see versionID variable.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stimuli IDs
mat_sIDs = [ ...
    01 02 03 04 ...
    11 12 13 14 ...
    21 22 23 24 ...
    ];
S=length( mat_sIDs );
% versionID = 'v1';
versionID = 'v2';
file_pattern = 'temphist-audio_S%02d-%s-twin8';

sID = [];
cell_tempo = cell(S,1);
for s = 1:S
    sID = mat_sIDs(s);
    filename = sprintf( file_pattern, sID, versionID);
    
    d=load( ['results/' filename] );
    BPM      = d.BPM;
    temphist = d.mean_tempogram;
    
    [m,idx] = max( temphist );
    
    cell_tempo{s} = BPM(idx);
end

t1=table( mat_sIDs' );
t1.Properties.VariableNames = {'sID'};


t2=cell2table( cell_tempo);
t2.Properties.VariableNames = {'BPM'};

table_tempo = [t1 t2];

filename = sprintf( 'table_tempo-%s_tempogram.csv', versionID );
writetable( table_tempo, filename);