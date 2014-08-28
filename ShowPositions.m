function ShowPositions (fig)
	% Good for debugging positioning and sizing issues
	%
	lineStyle = '-';
	
	subplots = findall(fig, 'type', 'axes');
	positions = cell2mat(get(subplots, 'Position'));
	outerPositions = cell2mat(get(subplots, 'OuterPosition'));
	tightPositions = TightPosition(subplots);
	
	annotations = get (fig, 'UserData');
	for a = 1:length(annotations)
		delete(annotations(a))
	end
	annotations = [];
	for s = 1:length(subplots)
		rect = annotation ('rectangle', LimitRect(positions(s,:)), 'EdgeColor', 'b', 'LineStyle', lineStyle);
		annotations = [annotations, rect];
		rect = annotation ('rectangle', LimitRect(outerPositions(s,:)), 'EdgeColor', 'g', 'LineStyle', lineStyle);
		annotations = [annotations, rect];
		rect = annotation ('rectangle', LimitRect(tightPositions(s,:)), 'EdgeColor', 'r', 'LineStyle', lineStyle);
		annotations = [annotations, rect];
	end
	set (fig, 'UserData', annotations)
end

function tightPositions = TightPosition (subplots)
	tightPositions = cell2mat(get(subplots, 'Position'));
	tightInsets = cell2mat(get(subplots, 'TightInset'));
	tightPositions(:,1:2) = tightPositions(:,1:2) - tightInsets(:,1:2);
	tightPositions(:,3:4) = tightPositions(:,3:4) + tightInsets(:,1:2) + tightInsets(:,3:4);
end

function rect = LimitRect (rect)
	for hv = 1:2
		if rect(hv) < 0
			rect(hv+2) = rect(hv+2) + rect(hv);
			rect(hv) = 0;
		end
		if rect(hv+2) > 1
			rect(hv+2) = 1;
		end
	end
end

