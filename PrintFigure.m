function PrintFigure (figures, figureSizeInInches, paperType, orientation)
	if nargin < 1 || isempty(figures)
		figures = get(0,'children');
		if ~isempty(figures)
			if isobject(figures(1))
				figureNums = get(figures, 'Number');
				figureNums = [figureNums{:}];
			else
				figureNums = figures;
			end
			[~, byFigureNum] = sort(figureNums);
			figures = figures(byFigureNum);
		end
	end
	figures = figures(:)';
	for fig = figures
		if nargin > 1
			if nargin > 2 && ~isempty(paperType)
				set (fig, 'PaperType', paperType)
			end
			if nargin > 3 && ~isempty(orientation)
				set (fig, 'PaperOrientation', orientation)
			end
			set (fig, 'PaperUnits', 'inches')
			
			if isempty(figureSizeInInches)
				paperPosition = get (fig, 'PaperPosition');
				figureSizeInInches = paperPosition(3:4);
			end
			
			paperSize = get(fig, 'PaperSize');
			margins = (paperSize - figureSizeInInches)/2;
			assert(all(margins >= 0))
			paperPosition = [margins figureSizeInInches];
			
			set (fig, 'PaperPositionMode', 'manual', 'PaperPosition', paperPosition)
		end
		
		figure(fig)
		if ispc
			print
		else
			print ('-dpsc2')
		end
	end
end
