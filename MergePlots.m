function fig = MergePlots (figs, names, colors, options)
	if nargin < 2 || isempty(names)
		names = arrayfun(@(f) sprintf('Figure %d', f), figs, 'UniformOutput', false);
	end
	if nargin < 3
		colors = {};
	end
	if nargin < 4
		options = {};
	end
	
	useColors = ~isempty(colors);
	suppressOldLegends = any(strcmpi(options, 'suppressOldLegends'));
	rename = any(strcmpi(options, 'rename'));
	
	lineStyles = {'-', '--', '-.', ':'};		% Assume figs(1) uses '-'. @@@ Avoid existing styles, colors.
	
	fig = copyobj(figs(1),0);		% Screws up legends in very strange ways.
	figure(fig)
	
	axes0 = findall(figs(1), 'type', 'axes');
	axes1 = findall(fig, 'type', 'axes');
	assert(all(strcmp(get(axes0,'tag'), get(axes1,'tag'))))
	
	UpdateDisplayNames (axes0, axes1, names{1}, suppressOldLegends)
	
%	fprintf (1, 'Figure 1:\n')
%	ShowDisplayNames(axes0, 1)

%	fprintf (1, 'New figure (before):\n')
%	ShowDisplayNames(axes1, 1)
	
	hasLegend = false(size(axes1));
	isLegend = false(size(axes1));
	assert(sum(isLegend) <= 1)		% Simplifies legend reconstruction.
	
	for a = 1:length(axes0)
		ax0 = axes0(a);
		axLegend = legend(ax0);
		if ~isempty(axLegend) && axLegend ~= ax0
			hasLegend(a) = true;
			isLegend(axes0 == axLegend) = true;
		end
	end

	legendLocation = [];
	legendOrientation = [];
	for a = 1:length(axes0)
		ax0 = axes0(a);
		assert(isLegend(a) == strcmpi(get(ax0, 'tag'), 'legend'))
		if isLegend(a)
			legendLocation = get(ax0, 'Location');
			legendOrientation = get(ax0, 'Orientation');
		end
	end

	for f = 2:length(figs)
		axesN = findall(figs(f), 'type', 'axes');
		assert(all(size(axesN) == size(axes1)))
		
%	fprintf (1, 'Figure %d:\n', f)
%	ShowDisplayNames(axesN, 1)
		for a = 1:length(axes1)
			ax1 = axes1(a);
			axN = axesN(a);
			childrenN = get(axN, 'Children');
			assert(all(size(childrenN) == size(get(axes0(a), 'Children'))))
			
			if ~isLegend(a)
				xlim1 = get(ax1, 'XLim');
				ylim1 = get(ax1, 'YLim');
				xlimN = get(axN, 'XLim');
				ylimN = get(axN, 'YLim');
				
				set(ax1, 'XLim', [min(xlim1(1), xlimN(1)) max(xlim1(2), xlimN(2))])
				set(ax1, 'YLim', [min(ylim1(1), ylimN(1)) max(ylim1(2), ylimN(2))])
				
				newChildren = copyobj(childrenN, ax1);
				
				if useColors
					UpdateColors(newChildren, colors{f})
				else
					UpdateStyles(newChildren, lineStyles{f})
				end
				if hasLegend(a)
					UpdateDisplayNames(childrenN, newChildren, names{f}, suppressOldLegends)
				end
			end
		end
	end
	
	% Recreate the legend
	%
	if any(isLegend)
		for a = 1:length(axes1)
			if isLegend(a)
				delete(axes1(a))		% The copied legend is the wrong size and doesn't have the merged lines.
			elseif hasLegend(a)
				legend (axes1(a), 'Location', legendLocation, 'Orientation', legendOrientation)
			end
		end
	end
	
	if rename
		newName = names{1};
		for f = 2:length(names)
			newName = sprintf ('%s vs %s', newName, names{f})
		end
		set (fig, 'name', newName)
	end
%	fprintf (1, 'New figure (after):\n')
%	ShowDisplayNames(get(fig, 'Children'), 1)
end

function UpdateStyles (children, lineStyle)
	for child = children(:)'
		set(child, 'LineStyle', lineStyle)
		UpdateStyles(get(child, 'Children'), lineStyle)
	end
end

function UpdateColors (children, color)
	for child = children(:)'
		set(child, 'Color', color)
		UpdateColors(get(child, 'Children'), color)
	end
end

function UpdateDisplayNames (sourceChildren, destinationChildren, prefix, suppressOldLegends)
	assert(length(sourceChildren) == length(destinationChildren))
	if ~isempty(sourceChildren)
		assert(all(strcmpi(get(sourceChildren,'Type'), get(destinationChildren,'Type'))))
		for c = 1:length(sourceChildren)
			sourceChild = sourceChildren(c);
			destinationChild = destinationChildren(c);
			if ~strcmpi(get(sourceChild, 'Type'), 'axes')
				sourceAnnotation = get(sourceChild,'Annotation');
				destinationAnnotation = get(destinationChild,'Annotation');
				sourceLegendEntry = get(sourceAnnotation','LegendInformation');
				destinationLegendEntry = get(destinationAnnotation','LegendInformation');
				
				set(destinationLegendEntry, 'IconDisplayStyle', get(sourceLegendEntry, 'IconDisplayStyle'))

				displayName = get(sourceChild, 'DisplayName');
				if ~isempty(displayName)
					if suppressOldLegends
						displayName = prefix;
					else
						displayName = sprintf('%s: %s', prefix, displayName);
					end
					set(destinationChild, 'DisplayName', displayName)
				end
			end
			UpdateDisplayNames(get(sourceChild, 'Children'), get(destinationChild, 'Children'), prefix, suppressOldLegends)
		end
	end
end

function ShowDisplayNames (objects, indent)
	for obj = objects(:)'
		if strcmpi(get(obj, 'Type'), 'axes')
			fprintf (1, '%sAxes: %f\n', repmat(' ', 1, indent*4), obj)
		else
			hAnnotation = get(obj,'Annotation');
			hLegendEntry = get(hAnnotation','LegendInformation');

			fprintf (1, '%s%s %f: (%s)%s\n', repmat(' ', 1, indent*4), get(obj, 'Type'), obj, get(hLegendEntry,'IconDisplayStyle'), get(obj, 'DisplayName'))
		end
		get(obj)	%@@@
		ShowDisplayNames (get(obj, 'Children'), indent+1);
	end
end

