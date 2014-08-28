function fig = RedistributeSubplots (fig)
	testMode = nargin < 1 || isempty(fig);
	if testMode
		fig = CreateTestFigure(2,5);
	end
	
	if testMode
%		ShowPositions (fig)
	end
	
	DistributeSubplots (fig)
	
	if testMode
%		ShowPositions (fig)
%		set(fig, 'ResizeFcn', @ResizeFcn);
	end
end

function DistributeSubplots (fig)
	subplots = findall(fig, 'type', 'axes');

	figPosition = get (fig, 'PaperPosition'); % Assumes figure was setup by CreatFigure
	aspectRatios = [figPosition(3)/figPosition(4) 1];
	
	positions = cell2mat(get(subplots, 'Position'));
	
	% Make sure we can identify subplot rows and columns
	%
	columnPositions = unique(positions(:,1));
	rowPositions = unique(positions(:,2));
	numColumns = length(columnPositions);
	numRows = length(rowPositions);
	assert(numRows*numColumns == length(subplots))
	
	% Calculate tightInsets for the perimiter plots
	%
	perimeterInsets = max(cell2mat(get(subplots, 'TightInset')));

	for hv = 1:2
		% Note:	"width" refers to height or width depending on the value of hv
		%		"column" refers to row or column depending on the value of hv
		%		"left" and "right" are "bottom" or "top" when hv is 2
		%
		oldPositions = positions(:,hv);
		columnPositions = unique(oldPositions);
		numSubplots = length(columnPositions);
		numGaps = numSubplots - 1;
		
		leftMargin = perimeterInsets(hv);
		rightMargin = perimeterInsets(hv+2);
		
		spaceBetweenMargins = 1 - leftMargin - rightMargin;

		newGapBetweenColumns = .03/aspectRatios(hv);
		assert(newGapBetweenColumns >= 0)

		newColumnWidth = (spaceBetweenMargins - newGapBetweenColumns*numGaps)/numSubplots;
		
		positions(:,hv+2) = newColumnWidth;
		
		% Now shift the positions to set the proper gaps.
		%
		newColumnPositions = nan(size(columnPositions));
		newColumnPositions(1) = leftMargin;
		for p = 2:length(columnPositions)
			newColumnPositions(p) = newColumnPositions(p-1) + newColumnWidth + newGapBetweenColumns;
		end

		newPositions = nan(size(oldPositions));
		for p = 1:length(columnPositions)
			plotsInThisColumn = oldPositions == columnPositions(p);
			newPositions(plotsInThisColumn) = newColumnPositions(p);
		end
		assert(~any(isnan(newPositions)))	% Got them all?
		assert(all(newPositions >= 0))
		assert(all(newPositions <= 1))
		
		positions(:,hv) = newPositions;
	end
	
	for s = 1:length(subplots)
		set (subplots(s), 'Position', positions(s,:))
	end
	
	newPositions = cell2mat(get(subplots, 'Position'));
	if any(newPositions(:) ~= positions(:))
		warning ('horizon:impulse:positioningFailed', 'New positions do not match requested')
		newPositions - positions
	end
end

function ResizeFcn (varargin)
	DistributeSubplots (gcbo)
	ShowPositions (gcbo)
end

function fig = CreateTestFigure (numRows, numColumns)
	fig = CreateFigure('Test Figure');
	
	labelProperties = {'FontName', 'Helvetica', 'FontSize', 10};
	titleProperties = {'FontName', 'Helvetica', 'FontSize', 10};
	axesProperties = {'FontName', 'Helvetica', 'FontSize', 9};	% Control tick labels

	for p = 1:numRows*numColumns
		subplot (numRows,numColumns,p)
		set (gca, axesProperties{:})

		text (.5, .5, sprintf('%d', p))
		
		row = 1+floor((p-1)/numColumns);
		column = 1+rem((p-1),numColumns);
		
		if column == 1
			ylabel (sprintf('Row %d ggyyjj', row), labelProperties{:})
		end
		if row == 1
			title(sprintf('Column %d ggyyjj', column), titleProperties{:})
		end
		
		if row == numRows && (column == round(numColumns/2) || rem(numColumns,2) == 0)
			xlabel ('X Label ggyyjj', labelProperties{:})
		end
		if column == numColumns && (row == round(numRows/2) || rem(numRows,2) == 0)
			ylabel ('Y Label ggyyjj', labelProperties{:})
		end
	
		if row < numRows
			set (gca, 'XTickLabel', [])
		end
	
		if column == numColumns
			set (gca, 'YAxisLocation', 'right')
		else
			set (gca, 'YTickLabel', [])
		end
		
		box on
	end
end

