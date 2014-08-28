function fig = CreateFigure (name, plotProperties)
	if nargin < 2 || isempty(plotProperties)
		plotProperties = DefaultPlotProperties ();
	end
	paperType = 'usletter';

	figureProperties = {'name', name, 'PaperUnits', 'inches', 'PaperType', plotProperties.paperType, 'PaperOrientation', plotProperties.orientation};
	figureProperties = [figureProperties, plotProperties.otherPlotProperties];

	fig = CascadeFigure(figure(figureProperties{:}), plotProperties.figureSizeInInches);
	
	paperSize = get(fig, 'PaperSize');
	
	margins = (paperSize - plotProperties.figureSizeInInches)/2;
	assert(all(margins >= 0))
	paperPosition = [margins plotProperties.figureSizeInInches];
	
	set (fig, 'PaperPositionMode', 'manual', 'PaperPosition', paperPosition)
end
