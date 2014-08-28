function SimpleMovie (yMatrix, name, options)
	if nargin < 2
		name = '';
	end
	if nargin < 3
		options = {};
	end
	
	MovieMaker (name, size(yMatrix,2), @SetupMovie, @DrawFrame, [], options)
	
	function movieState = SetupMovie(movieState)		
		plotProperties = DefaultPlotProperties();
		
		movieState.line = plot (yMatrix(:,1), plotProperties.Line(1));
		
		ylim ([-1 1] * max(abs(yMatrix(:))))
		
		title (get(gcf, 'name'))
		
		box on
		grid on
	end
	
	function movieState = DrawFrame (movieState, currentFrame)
		set (movieState.line, 'YData', yMatrix(:,currentFrame))
	end
	
end
