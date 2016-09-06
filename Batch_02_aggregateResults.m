%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: Batch_02_aggregateResults
% Date of Revision: 2016-08
% Programmer: Thomas Praetzlich
% Resources: https://dx.doi.org/10.6084/m9.figshare.3398545
%
% Description: 
%   Aggregate tempo EEG histograms into a cell data structure.
%    
% Reference: 
%   [SPG16] Sebastian Stober; Thomas Prätzlich & Meinard Müller.
%   Brain Beats: Tempo Extraction from EEG Data.
%   International Society for Music Information Retrieval 
%   Conference (ISMIR), 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aggregate tempo EEG histograms into a single mat file...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% mat_pIDs = [ 01 04 06 07 09 11 12 13 14 ];
mat_pIDs = [ 09 11 12 13 14 ];
mat_sIDs = [ ...
    01 02 03 04 ...
    11 12 13 14 ...
    21 22 23 24 ...
    ];

P = length(mat_pIDs);
S = length(mat_sIDs);
cell_temphist = cell( P, S);
dir_results = 'results/';

% data      = 'raw';
data      = 'sce';
tempo_win = 8;


file_suffix  = ['twin' num2str(tempo_win)];

for p = 1:P
    pID = mat_pIDs(p);
    
    
    for s = 1:S
        mat_tempohist = [];
        sID = mat_sIDs(s);
        
        file_pattern = sprintf(...
            '%s_temphist_S%02d-P%02d-trial*-%sat',...
            data,sID,pID,file_suffix);
        %     file_pattern = [ data '_temphist' '_P' num2str(pID,'%02d') '' file_suffix 'at'];
        
        f=dir( [dir_results file_pattern] );
        filenames = sort({ f.name });
        
        for i = 1:length(filenames)
            d=load( [dir_results filenames{i}] );
            mat_tempohist = [ mat_tempohist; dean_tempogram' ];
        end
        cell_temphist{p,s} = mat_tempohist;
    end
end
smooth_len = d.smooth_len;
tempo_win  = d.tempo_win;
BPM        = d.BPM;
save([dir_results data '-agg_temphist_' file_suffix],'cell_temphist','filenames','tempo_win','BPM');

