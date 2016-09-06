function [ h_figure, h_axis ] = visualize_singleTrials( mat_results, parameter )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualize_singleTrials
% Date of Revision: 2016-02
% Programmer: Thomas Praetzlich
%
% Description:
%
% Input:
% Output:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    parameter = [];
end
if ~isfield( parameter, 'colormapFct' )
    parameter.colormapFct = @gray;
end
if ~isfield( parameter, 'XTick' )
    parameter.XTick = 1:size( mat_results, 2 );
end
if ~isfield( parameter, 'XTickLabel' )
    parameter.XTickLabel = 1:size( mat_results, 2 );
end
if ~isfield( parameter, 'YTick' )
    parameter.YTick = 1:size( mat_results, 1 );
end
if ~isfield( parameter, 'YTickLabel' )
    parameter.YTickLabel = 1:size( mat_results, 1 );
end
if ~isfield( parameter, 'intervals' )
    parameter.intervals = [];
end
if ~isfield( parameter, 'drawSeparator' )
    parameter.drawSeparator = false;
end
if ~isfield( parameter, 'YTickLabel' )
    parameter.YTickLabel = cellfun(...
        @num2str,...
        num2cell(parameter.YTick(1):parameter.YTick(2)),...
        'UniformOutput',0);
end

h_image = imagesc( mat_results );
pos_old = get(gca,'Position');
c=colorbar;
% intervals = [ 0 1;2 3; 4 5; 5 7; 8 9; 10 10.5];
intervals = parameter.intervals;
% intervals = [ 0 4;5 9;10 10.5];

if ~isempty( intervals )
    cLabelMin = min( floor( intervals(:) ));
    cLabelMax = max( floor( intervals(:) ));
    % cLabels = cellfun(@num2str,num2cell(0:10),'UniformOutput',0);
    cLabels = cellfun(@num2str,num2cell(cLabelMin:cLabelMax),'UniformOutput',0);
    cLabels{end} = ['>' num2str(cLabelMax)];
    % set(c,'YTickLabel',cLabels)
    
    
    parameterCBar = [];
    parameterCBar.YTick = 0:ceil( cLabelMax );
    parameterCBar.YTickLabel = cLabels;
    parameterCBar.colormapFct = @gray;
    
    [ c ] = segmentColorbar_intoIntervals( c, intervals, parameterCBar );
    
end
[nY,nX,~]=size(mat_results);

nSegX=9;
% nSegY=12;


% myXTick=3:5:45;
myYTickLabel= 1:nSegX;
set(gca,'Xtick',parameter.XTick)
set(gca,'XTickLabel',myYTickLabel)
set(gca, 'TickLength',[0 0])


sIDset = {'01';'02';'03';'04';'11';'12';'13';'14';'21';'22';'23';'24'};
% mat_pIDs = [ 01 04 06 07 09 11 12 13 14 ];
set(gca,'XTickLabel', parameter.XTickLabel )

set(gca,'YTick', 1:12 )
set(gca,'YTickLabel', sIDset)


% xlabel('Participant ID','Color','k')
% ylabel('Stimulus ID','Color','k')
% hold on

box on;
ax1 = gca;
ax1_pos = ax1.Position; % position of first axes

if parameter.drawSeparator
    ax2 = axes('Position',ax1_pos,...
        'XAxisLocation','top',...
        'YAxisLocation','left',...
        'Color','none');
    set(gca, 'TickLength',[0 0])
    set(ax2,'xlim',get(ax1,'xlim'),'ylim',get(ax1,'ylim'))
    set(ax2,'xtick',0.5:5:45,'xticklabel',[],...
        'xgrid','on','xcolor','w',...
        'ytick',0.5:1:12.5,'ytickLabel',[],...
        'ygrid','off','ycolor','w',...
        'gridLineStyle','--','linewidth',1,...
        'gridAlpha',1)
    
    ax3 = axes('Position',ax1_pos,...
        'XAxisLocation','top',...
        'YAxisLocation','left',...
        'Color','none');
    set(ax3,'xtick',[]);set(gca,'ytick',[]);
end
% axis xy
% 'ytick',linspace(0.5,nY,nSegY+0.5),'ytickLabel',[],...
grid off;
box on;

axes_h = findall(gcf,'type','axes');
linkprop(axes_h,'position');
box on

h_figure = gcf;
h_axis = ax1;
end

