function TrimData (ax, axisSelect)
	if nargin < 1 || isempty(ax)
		ax = gca;
	end
	
	if nargin < 2 || isempty(axisSelect)
		axisSelect = 'x';
	end
	
	if strcmpi(axisSelect, 'x')
		dataProperty = 'XData';
		limitProperty = 'XLim';
	elseif strcmpi(axisSelect, 'y')
		dataProperty = 'YData';
		limitProperty = 'YLim';
	elseif strcmpi(axisSelect, 'z')
		dataProperty = 'ZData';
		limitProperty = 'ZLim';
	else
		error ('horizon:impulse:input', 'axisSelect should be one of ''x'' or ''y''')
	end

	range = get (ax, [axisSelect, 'lim']);

	for ln = findobj(ax,'Type','line').'
		data = get(ln, [axisSelect, 'data']);
		pointsToKeep = data >= range(1) & data <= range(2);
		clear data
		
		x = get(ln, 'XData');
		y = get(ln, 'YData');
		z = get(ln, 'ZData');
		
		x = x(pointsToKeep);
		y = y(pointsToKeep);
		if isempty(z)
			set (ln, 'XData', x, 'YData', y);
		else
			z = z(pointsToKeep);
			set (ln, 'XData', x, 'YData', y, 'ZData', z);
		end
	end
end
