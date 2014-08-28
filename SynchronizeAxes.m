function SynchronizeAxes (fig)
	allAxes = findall(fig, 'type',' axes');
	
	xlimit = [+inf -inf];
	ylimit = [+inf -inf];
	for ax = allAxes'
		limit = get (ax, 'XLim');
		xlimit(1) = min(xlimit(1), limit(1));
		xlimit(2) = max(xlimit(2), limit(2));

		limit = get (ax, 'YLim');
		ylimit(1) = min(ylimit(1), limit(1));
		ylimit(2) = max(ylimit(2), limit(2));
	end
	
	for ax = allAxes'
		xlim(ax, xlimit)
		ylim(ax, ylimit)
	end
	
	linkaxes (allAxes, 'xy')
end

