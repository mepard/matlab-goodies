function AnnotateFigures (figures, annotationStrings, growBy)
	%@@@ Not working yet.
	if nargin < 3
		growBy = 0.2;		% Adjust to fit typical annotations.
	end
	
	for f = 1:length(figures)
		fig = figures(f);
		
		paperPosition = get (fig, 'PaperPosition');
		paperPosition(2) = paperPosition(2) - growBy*paperPosition(4);
		paperPosition(4) = paperPosition(4) + growBy*paperPosition(4);
		set (fig, 'PaperPosition', paperPosition);
		
		children = get(fig, 'children');
		positions = cell2mat(get(children, 'Position'));
		positions(2) = growBy + positions(2)/(1+growBy);
		positions(4) = positions(4) / (1+growBy);
		
		for s = 1:length(children)
			set (children(s), 'Position', positions(s,:))
		end
		
		annotation (fig, 'textbox', [0, 0, growBy, growBy], 'String', annotationStrings, ...
						'HorizontalAlignment', 'left', ...
						'VerticalAlignment', 'bottom');
	end
end
