function figureNum = CascadeFigure (figureHandleOrNum, figureSizeInInches)
	if isobject(figureHandleOrNum)		% New graphics system in R2014b and later.
		figureHandle = figureHandleOrNum;
		figureNum = get(figureHandleOrNum, 'Number');
	else
		figureHandle = figureHandleOrNum;
		figureNum = figureHandleOrNum;
	end
	
	screenSizeInPixels = get(0,'ScreenSize');

	if nargin < 2 || isempty(figureSizeInInches)
		aspectRatio = screenSizeInPixels(3)/screenSizeInPixels(4);
		height = min(3*screenSizeInPixels(4)/4, 900);
		width = round(height*aspectRatio);
	else
		pixelsPerInch = get(0, 'ScreenPixelsPerInch');
		
		height = figureSizeInInches(2) * pixelsPerInch;
		width = figureSizeInInches(1) * pixelsPerInch;
	end
	
	left = 10 + (figureNum-1)*20;
	topOffset = 100 + (figureNum-1)*25;
	
	top = screenSizeInPixels(1) + screenSizeInPixels(4) - topOffset;
	bottom = top - height;
	
	set(figureHandle, 'Position', [left, bottom, width, height])
end
