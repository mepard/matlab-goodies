function ZoomAxes (ax, fraction, whichAxis)
	if isempty(ax)
		ax = gca;
	end
	if nargin < 3
		whichAxis = 'x';
	end
	
	if strcmpi(whichAxis, 'x')
		otherAxis = 'y';
	else
		otherAxis = 'x';
	end
	
	axisRange = AxisDataRange (ax, whichAxis);
	axisRange = axisRange + [1 -1]*diff(axisRange)*(1-fraction)/2;
	axisRange = axisRange + [-.01 +.01]*diff(axisRange);	% Add a touch of margin
	set (ax, [whichAxis, 'lim'], axisRange);
	
	lines = findobj(ax,'Type','line');
	if isempty(lines)
		otherRange = AxisDataRange (ax, otherAxis);
		otherRange = otherRange + [1 -1]*diff(otherRange)*(1-fraction)/2;
	else
		% Find the range of the other axis data for the values of which axis within the new limit.
		%
		includeProperty = [otherAxis, 'LimInclude'];
		otherRange = [inf -inf];
		for ln = lines.'
			include = get(ln, includeProperty);
			if strcmpi(include, 'on')
				axisData = get(ln, [whichAxis, 'Data']);
				otherData = get (ln, [otherAxis, 'Data']);
				
				otherData = otherData(axisData >= axisRange(1) & axisData <= axisRange(2));
				
				otherRange(1) = min([otherRange(1) min(otherData)]);
				otherRange(2) = max([otherRange(2) max(otherData)]);
			end
		end
	end
	otherRange = otherRange + [-.01 +.01]*diff(otherRange);	% Add a touch of margin
	set (ax, [otherAxis, 'lim'], otherRange);
end
