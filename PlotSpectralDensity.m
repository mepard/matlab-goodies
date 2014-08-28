function fig = PlotSpectralDensity (samples, samplesPerSecond, bandwidth, options, name)
	if nargin < 3
		bandwidth = [];
	end
	if nargin < 4
		options = {};
	end
	if nargin < 5 || isempty(name)
		name = 'PSD';
	end
	
	numFftBins = 8192;

	window = hamming(min(numFftBins, length(samples)));
	[powerPerHz, basebandFrequencies] = CumulativePeriodogram(samples, window, samplesPerSecond, true);
	
	% Flip so center frequency is in middle
	powerPerHz = fftshift(powerPerHz, 1);
	basebandFrequencies = basebandFrequencies - mean(basebandFrequencies);

	plotProperties = DefaultPlotProperties(options);
	
	fig = CreateFigure (name, plotProperties);
	
	hold on
	set (gca, plotProperties.axesProperties{:})

	annotations = {};
	
	powerPerHzInDb = 10*log10(powerPerHz);
	
	plot (basebandFrequencies/1e6, powerPerHzInDb)
	if ~isempty(bandwidth)
		frequencyRange = [-1 1] * bandwidth/2;
		binsToInclude = (basebandFrequencies >= frequencyRange(1)) ...
					  & (basebandFrequencies <= frequencyRange(2));
	
		hold on
		plot (basebandFrequencies(binsToInclude)/1e6, powerPerHzInDb(binsToInclude), 'r')

		inbandPowerDb = TotalPowerInChannel (basebandFrequencies, powerPerHzInDb, 0, bandwidth);
		annotations = [annotations, sprintf('  %g dB from PSD (%g linear)  ', inbandPowerDb, 10^(inbandPowerDb/10))];
	end
	
	totalPowerFromTimeDomain = FastVar(samples);

	annotations = [annotations, sprintf('  %g dB from time domain (%g linear)  ', 10*log10(totalPowerFromTimeDomain), totalPowerFromTimeDomain)];
	
	text('Units', 'normalized', 'Position', [.01, .98], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
		 'string', annotations, plotProperties.annotationProperties{:});
	
	xlabel ('Frequency (MHz)', plotProperties.labelProperties{:})
	ylabel ('Density (dB/Hz)', plotProperties.labelProperties{:})

	title (get(gcf, 'name'), plotProperties.titleProperties{:})

	box on
	grid on, grid minor
	zoom on
	
	ExpandAxes (gca)
end
