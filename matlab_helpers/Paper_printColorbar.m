
printPaperPosition = [0 0  6   6];
fig1=figure;
pos = get(gca,'Position');
left=100; bottom=100 ; width=20 ; height=500;
% pos=[left bottom width height];
axis off

c=colorbar;

intervals = [ 0 3; 3 5; 5 7; 8 8.5];

cLabelMin = min( floor( intervals(:) ));
cLabelMax = max( floor( intervals(:) ));
cLabels = cellfun(@num2str,num2cell(cLabelMin:cLabelMax),'UniformOutput',0);
cLabels{end} = ['>' num2str(cLabelMax-1)];


parameterCBar = [];
parameterCBar.YTick = 0:10;
parameterCBar.YTickLabel = cLabels;
parameterCBar.colormapFct = @gray;

[ c ] = segmentColorbar_intoIntervals( c, intervals, parameterCBar );


% set(fig1,'Units','points');
% set(c,'Position',pos);
% set(fig1,'OuterPosition',pos) 


set(fig1,'PaperPosition',printPaperPosition)
print('-dpng','colorbarTest','-r600');

