function Veg_O_Movie (name, samples, samplesPerSecond, strideInSeconds, functions, windowsInSeconds, legends, xyAxisLabels, saveInDir, options)
% Slice samples into blocks, at strideInSeconds per block.
% For each slice, call the specified functions with the samples for the specified windows sizes
% surrounding the center of the slice and plots the results.


	if nargin < 7
		legends = [];
	end
	if nargin < 8
		xyAxisLabels = [];
	end
	if nargin < 9
		saveInDir = [];
	end
	if nargin < 10
		options = {};
	end
	
	if numel(samplesPerSecond) ~= 1
		error ('horizon:Vegomatic:input', 'Exactly one sample rate required')
	end
    if numel(strideInSeconds) ~= 1
        error ('horizon:Vegomatic:input', 'Exactly one stride required')
    end
    if numel(functions) == 1
        if ~iscell(functions)
            functions = {functions};
        end
        functions = repmat(functions, size(windowsInSeconds));
    end
	if numel(windowsInSeconds) == 1
		windowsInSeconds = repmat(windowsInSeconds, size(functions));
	end
	if numel(windowsInSeconds) ~= numel(functions)
		error ('horizon:Vegomatic:input', 'One function per window required')
	end
	
	if isempty(name)
		name = sprintf('%g samples per second', samplesPerSecond);
	end
	
	logScale = any(strcmpi(options, 'log'));
	plotSamples = any(strcmpi(options, 'samples'));
	showKurtosis = any(strcmpi(options, 'kurtosis'));
	
	[~, widestWindow] = max(windowsInSeconds);
	strideInSamples = strideInSeconds * samplesPerSecond;
	windowsInSamples = windowsInSeconds * samplesPerSecond; 
	windowOffsets = windowsInSamples/2;

	sampleTimes = (1:length(samples))/samplesPerSecond;

	numFunctions = length(functions);
	numBlocks = floor(length(samples) / strideInSamples);
	centerTimes = (1:numBlocks)*strideInSeconds - strideInSeconds/2;
	blockCenters = round(centerTimes*samplesPerSecond);
	
	plotProperties = DefaultPlotProperties(options);
	
	MovieMaker (name, numBlocks, @SetupMovie, @DrawFrame, saveInDir, options)
	
	function movieState = SetupMovie(movieState)
		movieState.framesPerSecond = 5;
			
		if plotSamples
			movieState.sampleAxes = subplot(2,1,2, plotProperties.axesProperties{:});
			hold on
			
			frameRange = GetFrame (1);
			movieState.sampleLine = plot (sampleTimes(frameRange)*1e3, samples(frameRange));

			xlim (sampleTimes(frameRange([1 end]))*1e3)
			ylim ([min(samples) max(samples)])

			xlabel ('Time (ms)', plotProperties.labelProperties{:})
			ylabel ('Amplitude', plotProperties.labelProperties{:})
			title (sprintf ('%.3g ms window', windowsInSeconds(widestWindow)*1e3), plotProperties.titleProperties{:})
			
			box on
			grid on

			movieState.functionAxes = subplot(2,1,1, plotProperties.axesProperties{:});
		else
			movieState.functionAxes = subplot(1,1,1, plotProperties.axesProperties{:});
		end
		
        hold on
		movieState.lines = nan(numFunctions, 1);
		for f = 1:numFunctions
			[x, y] = ComputeFunction (1, f);
			movieState.lines(f) = plot (x, y, plotProperties.Line(f, {'thin'}, numFunctions));
		end
		
		% Compute X and Y limits.
		%
		x_limit = [inf -inf];
		y_limit = [inf -inf];
		for blockNum = 1:length(blockCenters)
			for f = 1:length(functions)
				[x, y] = ComputeFunction (blockNum, f);
				x_limit(1) = min([x_limit(1), x(:)']);
				x_limit(2) = max([x_limit(2), x(:)']);
				y_limit(1) = min([y_limit(1), y(:)']);
				y_limit(2) = max([y_limit(2), y(:)']);
			end
		end
	
		if logScale
			set (gca, 'yscale', 'log')
		end
		
		xlim (x_limit)
		ylim (y_limit)
		
		if ~isempty(xyAxisLabels)
			xlabel (xyAxisLabels{1}, plotProperties.labelProperties{:})
			ylabel (xyAxisLabels{2}, plotProperties.labelProperties{:})
		end
		if isempty(legends)
			legends = cell(size(windowsInSeconds));
			for f = 1:numel(windowsInSeconds)
				legends{f} = sprintf('%.3g ms window', windowsInSeconds(f)*1e3);
			end
		else
			for f = 1:numel(windowsInSeconds)
				legends{f} = sprintf('%s (%.3g ms window)', legends{f}, windowsInSeconds(f)*1e3);
			end
		end
		legend(legends, 'location', 'northwest')
		
		box on
		grid on
	end
	
	function movieState = DrawFrame (movieState, currentFrame)
		for f = 1:length(functions)
			[x, y] = ComputeFunction (currentFrame, f);
			set (movieState.lines(f), 'XData', x, 'YData', y)
		end

		frameRange = GetFrame (currentFrame);
		if showKurtosis
			title (movieState.functionAxes, sprintf ('Kurtosis %.3g dBG', kurtosis_dBG(samples(frameRange))), plotProperties.titleProperties{:})
		else
			title (movieState.functionAxes, sprintf ('%.4g ms', centerTimes(currentFrame)*1e3), plotProperties.titleProperties{:})
		end

		if plotSamples
			set (movieState.sampleLine, 'XData', sampleTimes(frameRange)*1e3, 'YData', samples(frameRange))
			set (movieState.sampleAxes, 'XLim', sampleTimes(frameRange([1 end]))*1e3)
		end
	end

	function frameRange = GetFrame (blockNum)
		center = blockCenters(blockNum);
		windowStart = max([1, round(center - windowOffsets(widestWindow))]);
		windowEnd = min([round(center + windowOffsets(widestWindow)), length(samples)]);
		frameRange = [windowStart:windowEnd];
	end
	
	function [x, y] = ComputeFunction (blockNum, funNum)
		center = blockCenters(blockNum);
		fn = functions{funNum};
		windowStart = max([1, round(center - windowOffsets(funNum))]);
		windowEnd = min([round(center + windowOffsets(funNum)), length(samples)]);
		
		frame = samples(windowStart:windowEnd);
		[x, y] = fn(frame);
		if logScale
			y(y <= 0) = nan;	% Prevent warnings and messing with the ylimit.
		end
	end
	
end
