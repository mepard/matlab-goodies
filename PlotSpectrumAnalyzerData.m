function figs = PlotSpectrumAnalyzerData (paths, options, centerFrequency, bandwidth)
	if nargin < 2
		options = {};
	end
	if nargin < 3
		centerFrequency = [];
	end
	if nargin < 4
		bandwidth = [];
	end
	
	if isempty(centerFrequency) ~= isempty(bandwidth)
		error ('horizon:impulse:invalidArgs', 'You must specify neither or both the center freqency and bandwidth.')
	end
	
	useFullPathInTitle = any(strcmpi(options, 'fullpath'));
	printTotalPower = any(strcmpi(options, 'totalPower'));
	together = any(strcmpi(options, 'together'));

	plotProperties = DefaultPlotProperties(options);

	paths = ExpandWildcards (paths);

	if together
		figs = CreateFigure ('Spectrum Analyzer', plotProperties);
		
		hold on
		set (gca, plotProperties.axesProperties{:})

		legends = cell(size(paths));
	else
		figs = nan(1,length(paths));
	end
	
	lineColors = 'bgrcmky';
	
	for p = 1:length(paths)	
		[frequencies, dBmPerHz] = ImportSpectrumAnalyzerData (paths{p});
		
		plotTitle = paths{p};
		if ~useFullPathInTitle
			[~, plotTitle] = fileparts (plotTitle);
		end
		
		totalPowerDbm = TotalPowerInChannel (frequencies, dBmPerHz, centerFrequency, bandwidth);
		
		if together
			plot (frequencies/1e6, dBmPerHz, lineColors(p));

			if printTotalPower
				legends{p} = sprintf('%s, %g dBm total', plotTitle, totalPowerDbm);
			else
				legends{p} = sprintf('%s', plotTitle);
			end
		else
			figs(p) = CreateFigure (plotTitle, plotProperties);
			hold on
			set (gca, plotProperties.axesProperties{:})

			plot (frequencies/1e6, dBmPerHz);

			if printTotalPower
				note = sprintf('%g dBm total', totalPowerDbm);
				if ~isempty(centerFrequency)
					note = {note, sprintf('%g MHz at %g MHz', bandwidth/1e6, centerFrequency/1e6)};
				end
				text ('Units', 'Normalized', 'position', [.5, 0], 'string', note, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom')
			end
		end
		
		if ~together || p == length(paths)
			if ~isempty(centerFrequency)
				frequencyRange = centerFrequency + [-1 1] * bandwidth/2;
				plot (frequencyRange(1)/1e6 + [0 0], ylim, 'b--')
				plot (frequencyRange(2)/1e6 + [0 0], ylim, 'b--')
				legends{p+1} = sprintf('%g MHz at %g MHz', bandwidth/1e6, centerFrequency/1e6);
			end
			
			xlabel ('Frequency (MHz)', plotProperties.labelProperties{:})
			ylabel ('Spectrum Analyzer (dBm/Hz)', plotProperties.labelProperties{:}) 
	
			if together
				legend ('location', 'south', legends)
			end
			title (get(gcf, 'name'), plotProperties.titleProperties{:})
	
			box on
			grid on, grid minor
			zoom on
			
			ExpandAxes (gca)
		end
	end
