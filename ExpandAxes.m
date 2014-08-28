function ExpandAxes (fig)
	ax = findall(fig, 'type', 'axes');
	if ~isempty(ax)
		if length(ax) > 1
			RedistributeSubplots (fig);
		else
			tightPosition = get(ax, 'OuterPosition');
			tightInset = get(ax, 'TightInset');
			if isobject(fig)
				% New graphics system in R2014b
				tightInset = tightInset + [.01 .01 .01 .01];
			end
			tightPosition(:,1:2) = tightPosition(:,1:2) + tightInset(:,1:2);
			tightPosition(:,3:4) = tightPosition(:,3:4) - tightInset(:,1:2) - tightInset(:,3:4);
			
			set (ax, 'Position', tightPosition)
			set (ax, 'ActivePositionProperty', 'OuterPosition')
		end
	end
end
