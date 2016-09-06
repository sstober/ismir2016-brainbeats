function [ c_handle ] = segmentColorbar_intoIntervals( c_handle, intervals, parameter )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: segmentColorbar_intoIntervals
% Date of Revision: 2016-02
% Programmer: Thomas Praetzlich
%
% Description:
%    Segment a colorbar into intervals.
% Input:
% Output:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    parameter = [];
end
if isempty( c_handle )
    c_handle = colorbar;
end
if ~isfield( parameter, 'colormapFct' )
    parameter.colormapFct = @gray; 
end
if ~isfield( parameter, 'YTick' )
    parameter.YTick = [ min(intervals(:)) max(intervals(:)) ]; 
end
if ~isfield( parameter, 'CLim' )
    parameter.CLim = [ min(intervals(:)) max(intervals(:)) ]; 
end
if ~isfield( parameter, 'YTickLabel' )
    parameter.YTickLabel = cellfun(...
        @num2str,...
        num2cell(parameter.YTick(1):parameter.YTick(2)),...
        'UniformOutput',0);
end

step = 1; % TODO: if non integer numbers define interval, step fraction has to be determined.
num_segments = size( intervals, 1 );
tmpC = 1-parameter.colormapFct(num_segments);

% generate colormap that repeats each color according to the number of
% values in an interval
myColormap = [];
for s = 1:num_segments
    numVals = length( intervals(s,1):step:intervals(s,2) );
    myColormap = [ myColormap; ...
        repmat(tmpC(s,:),numVals,1); ];
end

colormap(myColormap);
set(c_handle,'YTick', parameter.YTick)
set(c_handle,'YTickLabel',parameter.YTickLabel)
set(gca,'clim',parameter.CLim)

end

