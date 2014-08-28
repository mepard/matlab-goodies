function plotProperties = DefaultPlotProperties (options, numRows, numColumns)
	if nargin < 1
		options = {};
	end
	if nargin < 2 || isempty(numRows)
		numRows = 1;
	end
	if nargin < 3 || isempty(numColumns)
		numColumns = 1;
	end
	
	markers = {'.','o','x','v'};
	
	colors =  [		 0         0    1.0000		% Defaults used by MATLAB, ie. get(gca,'ColorOrder')
					 0    0.5000         0
				1.0000         0         0
					 0    0.7500    0.7500
				0.7500         0    0.7500
				0.7500    0.7500         0
				0.2500    0.2500    0.2500 ];

	styles = {'-','--',':','-.'};
	
	patent = any(strcmpi(options, 'patent'));
	fillPage = any(strcmpi(options, 'page'));
	landscape = any(strcmpi(options, 'landscape'));
	ieee = any(strcmpi(options, 'ieee'));
	slides = any(strcmpi(options, 'slides')) || (~landscape && ~ieee);
	
	plotProperties.numRows = numRows;
	plotProperties.numColumns = numColumns;
	plotProperties.labelProperties = {'FontName', 'Helvetica', 'FontSize', 10, 'FontWeight', 'Normal'};
	plotProperties.titleProperties = {'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'Normal'};
	plotProperties.axesProperties = {'FontName', 'Helvetica', 'FontSize', 9, 'FontWeight', 'Normal'};	% Controls tick labels, legends
	plotProperties.lineProperties = {'LineWidth', 3, 'MarkerSize', 12};
	plotProperties.Line = @Line;
	
	if patent
		plotProperties.lineProperties = {'LineWidth', 3, 'MarkerSize', 4};
		plotProperties.axesProperties = [plotProperties.axesProperties, 'ColorOrder', repmat(linspace(0,.8,2).',1,3)];
		plotProperties.axesProperties = [plotProperties.axesProperties, 'LineStyleOrder', '-|o-|*-|x-'];
	end
	
	% Coordinate annotationProperties Margin value with MakeAnnotation in PlotTimeDomain.m
	%
	plotProperties.annotationProperties = {'FontName', 'Helvetica', 'FontSize', 9, 'FontWeight', 'Normal', 'BackgroundColor', [1 1 1], 'EdgeColor', 'k', 'Margin', 0.6};
	
	plotProperties.paperType = 'usletter';
	if fillPage
		if landscape
			plotProperties.orientation = 'landscape';
			plotProperties.figureSizeInInches = [10.5 8];
		else
			plotProperties.orientation = 'portrait';
			plotProperties.figureSizeInInches = [8 10.5];
		end
	elseif landscape
		plotProperties.orientation = 'landscape';
		plotProperties.figureSizeInInches = [10 7.5];	% IEEE width. Two plots per page with enough room left for some text.
	else
		plotProperties.orientation = 'portrait';
		plotProperties.figureSizeInInches = [7+1/16 3.5];	% IEEE width. Two plots per page with enough room left for some text.
		if slides	% Overrides tall, short
			aspectRatio = 1024/768;
			plotProperties.figureSizeInInches(2) = plotProperties.figureSizeInInches(1)/aspectRatio;
		elseif any(strcmpi(options, 'constellations'))
			aspectRatio = 1/.65;		% Squares up the constellations
			plotProperties.figureSizeInInches(2) = plotProperties.figureSizeInInches(1)/aspectRatio;
		else
			if any(strcmpi(options, 'tall'))
				plotProperties.figureSizeInInches(2) = 2*plotProperties.figureSizeInInches(2);
			end
			if any(strcmpi(options, 'short'))
				plotProperties.figureSizeInInches(2) = (2/3)*plotProperties.figureSizeInInches(2);
			end
		end
	end
	
	otherPlotProperties = {};
	if any(strcmpi(options, 'hidden'))
		otherPlotProperties = [otherPlotProperties, 'Visible', 'off'];
	end
	plotProperties.otherPlotProperties = otherPlotProperties;


	function lineProperties = Line (n, options, numLines)
	
		persistent	numLinesCache;
		persistent	colorCache;
		
		if nargin < 1
			n = 1;
		end
		if nargin < 2
			options = {};
		end
		if nargin < 3
			numLines = [];
		end
		
		lineProperties = struct(plotProperties.lineProperties{:});
		
		if patent
			s = 1+rem(n-1,length(styles));
			if ~isempty(numLines)
				numGraysNeeded = ceil(numLines/length(styles));
				grays = linspace(0,.8,numGraysNeeded);
			else
				grays = linspace(0,.8,7);
			end
			g = 1+floor((n-1)/numel(grays));
			lineProperties.Color = repmat(grays(g),1,3);
		else
			if isempty(numLines)
				c = 1+rem(n-1,size(colors,1));
				s = 1+floor((n-1)/size(colors,1));
		
				lineProperties.Color = colors(c,:);
			else
				if any(strcmpi(options, 'lineStyles'))
					s = 1+rem(n-1,length(styles));
				else
					s = 1;
				end
				if numLines > size(colors,1)
					if isempty(numLinesCache) || numLinesCache ~= numLines
						numLinesCache = numLines;
						colorCache = distinguishable_colors (numLinesCache);
					end
					lineProperties.Color = colorCache(n,:);
				else
					lineProperties.Color = colors(n,:);
				end
			end
		end
		lineProperties.LineStyle = styles{s};
		if any(strcmpi(options,'thin'))
			lineProperties.LineWidth = 1;
		end
		
		[hasMarker, marker] = GetStringOption (options, 'marker', '');
		if hasMarker
			if isempty(marker)
				s = 1+rem(n-1,length(markers));
				marker = markers{s};
			end
			lineProperties.Marker = marker;

			if lineProperties.Marker == '.'
				% See MarkerSize note at http://www.mathworks.com/help/matlab/ref/line_props.html
				% Don't fully correct for 3x difference so other markers surround dot.
				lineProperties.MarkerSize = lineProperties.MarkerSize * 2;
			end
			if any(strcmpi(options,'thin'))
				lineProperties.MarkerSize = lineProperties.MarkerSize / 2;
			end
		end
	end
		
end
