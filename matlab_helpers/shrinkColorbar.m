c=findall(gcf,'type','colorbar');
ax = gca;
axpos = ax.Position;
cpos = c.Position;
cpos(3) = 0.5*cpos(3);
c.Position = cpos;
ax.Position = axpos;