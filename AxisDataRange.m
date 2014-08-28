function range = AxisDataRange (ax, xy)
	% Like xlim, but with the data itself, not after MATLAB rounds to ticks.
	if strcmpi(xy, 'x')
		dataProperty = 'XData';
		limitProperty = 'XLim';
		includeProperty = 'XLimInclude';
	elseif strcmpi(xy, 'y')
		dataProperty = 'YData';
		limitProperty = 'YLim';
		includeProperty = 'YLimInclude';
	else
		error ('horizon:impulse:input', 'xy should be one of ''x'' or ''y''')
	end
	
	lines = findobj(ax,'Type','line');
	if isempty(lines)
		range = get (ax, limitProperty);
        if iscell(range)
            range = reshape([range{:}], [], 2);
            range = [min(range(:,1)), max(range(:,2))];
        end
	else
		range = [inf -inf];
		for ln = lines.'
			include = get(ln, includeProperty);
			if strcmpi(include, 'on')
				data = get(ln, dataProperty);
				range(1) = min([range(1) min(data)]);
				range(2) = max([range(2) max(data)]);
			end
		end
	end
end
