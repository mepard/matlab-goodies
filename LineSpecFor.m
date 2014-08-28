function lineSpec = LineSpecFor (index, options)
	if nargin < 2
		options = {};
	end
	
	colors = 'brcmkg';
	lines = {'-', ':', '--', '-.'};
	markers = {'.', '+', 'o', 'x', 's', 'd', '*', 'p', 'h'};
	
	if length(index) > 1
		lineSpec = cell(size(index));
		for i = index
			lineSpec{i} = LineSpecFor(i, options);
		end
	else
		color = colors(mod(index-1, length(colors)) + 1);
		lineStyle = lines{mod(index-1, length(lines)) + 1};
		markerStyle = markers{mod(index-1, length(markers)) + 1};
		if any(strcmpi(options, 'properties'))
			lineSpec = {'Color', color, 'LineStyle', lineStyle, 'Marker', markerStyle};
		else
			lineSpec = [color, markerStyle, lineStyle];
		end
	end

end
