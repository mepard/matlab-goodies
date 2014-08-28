function totalPowerDbm = TotalPowerInChannel (frequencies, dBmPerHzBins, centerFrequency, bandwidth, options, plotName)
	if nargin < 3
		centerFrequency = [];
	end
	if nargin < 4
		bandwidth = [];
	end
	if nargin < 5
		options = {};
	end
	if nargin < 6 || isempty(plotName)
		plotName = 'Power in channel';
	end
	
	if isempty(centerFrequency) ~= isempty(bandwidth)
		error ('horizon:impulse:invalidArgs', 'You must specify neither or both the center freqency and bandwidth.')
	end

	if ~isempty(centerFrequency)
		frequencyRange = centerFrequency + [-1 1] * bandwidth/2;
		binsToInclude = (frequencies >= frequencyRange(1)) ...
					  & (frequencies <= frequencyRange(2));
	else
		binsToInclude = true(size(frequencies));
	end

	mwPerHzBins = 10.^(dBmPerHzBins/10);
	hzPerBin = unique(diff(frequencies));
	assert(length(hzPerBin) == 1)

	totalPowerInMw = sum(mwPerHzBins(binsToInclude)) * hzPerBin;
	totalPowerDbm = 10*log10(totalPowerInMw);
	
	if any(strcmpi(options, 'plot'))
		plotProperties = DefaultPlotProperties(options);
		
		fig = CreateFigure (plotName, plotProperties);
		
		hold on
		set (gca, plotProperties.axesProperties{:})
	
		plot (frequencies/1e6, dBmPerHzBins)
		plot (frequencies(binsToInclude)/1e6, dBmPerHzBins(binsToInclude), 'r')
		
		text('Units', 'normalized', 'Position', [.01, .98], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
			 'string', sprintf('  %g dBm total  ', totalPowerDbm), plotProperties.annotationProperties{:});

		xlabel ('Frequency (MHz)', plotProperties.labelProperties{:})
		ylabel ('Density (dBm/Hz)', plotProperties.labelProperties{:})
		
		title (get(gcf, 'name'), plotProperties.titleProperties{:})
		
		box on
		grid on, grid minor
		zoom on
		
		ExpandAxes (gca)
	end
end
