function MegaMovie (samples, options, saveInDir)
	if nargin < 2
		options = {};
	end
	if nargin < 3
		saveInDir = [];
	end
	
	plotActualCDF = any(strcmpi(options, 'cdf'));
	plotDenormalized = any(strcmpi(options, 'denormalized'));
	if plotDenormalized && plotActualCDF
		error ('horizon:ncat:invalidOptions', 'Can''t specify both cdf and denormalize because the scales are different')
	end
	
	% Apply the Quantile SPARTs
	%
	tau = 25;
	mu = .01;

	numQuantileBins = 25;
	quantileRange = [.01 .99];
	quantiles = quantileRange(1):(diff(quantileRange)/numQuantileBins):quantileRange(2);
	
	spartedMixture = nan(length(samples), length(quantiles));
	for q = 1:length(quantiles)
		spartedMixture(:,q) = QuantileSPART(samples, mu, tau, quantiles(q));
	end
	
	tausPerQuantileWindow = 4;
	quantileWindowLength = tausPerQuantileWindow*tau;		% Look back this far for actual quantiles and CDF.
	
	numBufferFrames = 2*tausPerQuantileWindow;
	numFrames = floor(length(samples)/tau) - numBufferFrames - 1;
	
	if plotDenormalized
		cdfOrQuantiles = 'quantiles';
	else
		cdfOrQuantiles = 'CDF';
	end
	
	MovieMaker (sprintf('Estimated vs actual %s', cdfOrQuantiles), numFrames, @SetupMovie, @DrawFrame, saveInDir, options);
	
	return	% Only functions below.
	
	function movieState = SetupMovie(movieState)		
		plotProperties = DefaultPlotProperties();
		
		movieState.quantileAxes = subplot(2,1,1);
		
		amplitudeRange = [-1 1] * max(abs(samples));
		
		frameRange = FrameLocation (1);
		
		[actuals, estimates, cdfSigmas, cdfProbabilities] = EstimateQuantiles (frameRange);
		
		legends = { sprintf('Quantile values from sort of %d recent samples', quantileWindowLength), ...
					sprintf('Estimates from %d SPARTs, tau %d mu %g', length(quantiles), tau, mu)};
		
		if plotActualCDF
			movieState.cdfLine = line (cdfSigmas, cdfProbabilities, plotProperties.Line(3));
			legends = ['CDF from histogram', legends];
		end
		movieState.actualLine = line (actuals, quantiles, plotProperties.Line(2, {'marker'}));
		movieState.estimateLine = line (estimates, quantiles, plotProperties.Line(1, {'marker'}));

		if plotDenormalized
			xlim (amplitudeRange)
			xlabel ('Amplitude', plotProperties.labelProperties{:})
		else
			xlim ([-4 4])
			xlabel ('Standard Deviations (\sigma)', plotProperties.labelProperties{:})
		end
		
		ylim ([0 1])
		ylabel ('Quantile', plotProperties.labelProperties{:})
		
		legend (legends, 'location', 'northwest')
		title (get(gcf, 'name'))
		
		box on
		grid on

		movieState.sampleAxes = subplot(2,1,2);
		hold on
		plot (samples, plotProperties.Line(1));

		movieState.frameLine = plot (frameRange(2) + [0 0], amplitudeRange, plotProperties.Line(2));
		
		xlim ([1 length(samples)])
		ylim (amplitudeRange)

		xlabel ('Sample', plotProperties.labelProperties{:})
		ylabel ('Amplitude', plotProperties.labelProperties{:})

		box on
		grid on
		
		if movieState.savingMovie
			framesPerSecond = 15;
			numSeconds = 60;
			maxFrames = framesPerSecond * numSeconds;
			if maxFrames < movieState.numFrames
				movieState.increment = round(movieState.numFrames/maxFrames);
			end
		else
			set (movieState.sampleAxes, 'ButtonDownFcn', {@SelectFrame, movieState.fig})
			set (movieState.sampleAxes, 'HitTest', 'on')
			set (get(movieState.sampleAxes, 'Children'), 'HitTest', 'off')
		end
	end
	
	function SelectFrame (~, ~, fig)
		movieState = guidata(fig);
      	currentPoint = get(movieState.sampleAxes,'Currentpoint');
      	
      	newFrameNum = SampleNumToFrameNum (currentPoint(1));
      	if ~isempty(newFrameNum)
			movieState.currentFrame = newFrameNum;
			movieState.handledEvent = true;
			guidata(movieState.fig, movieState)
      	end
	end
	
	function movieState = DrawFrame (movieState, currentFrame)
		frameRange = FrameLocation (currentFrame);
		
		[actuals, estimates, ~, cdfProbabilities] = EstimateQuantiles (frameRange);
			
		if plotActualCDF
			set (movieState.cdfLine, 'YData', cdfProbabilities)
		end
		set (movieState.actualLine, 'XData', actuals)
		set (movieState.estimateLine, 'XData', estimates)
		
		set (movieState.frameLine, 'XData', frameRange(2) + [0 0])
	end
	
	function frameNum = SampleNumToFrameNum (sampleNum)
		frameNum = round(sampleNum/tau + quantileWindowLength/tau - numBufferFrames);
		if frameNum < 0 || frameNum > numFrames
			frameNum = [];
		end
	end
	
	function frameRange = FrameLocation (frameNum)
		frameEnd = tau*(numBufferFrames+frameNum);
		frameStart = frameEnd-quantileWindowLength;
		frameRange = [frameStart frameEnd];
	end
	
	function [actuals, estimates, cdfSigmas, cdfProbabilities] = EstimateQuantiles (frameRange)
		frame = samples(frameRange(1):frameRange(2));
			
		sortedFrame = sort(frame);
		actuals = sortedFrame(ceil(length(sortedFrame)*quantiles));
		estimates = spartedMixture(frameRange(2),:);

		if ~plotDenormalized
			stdFrame = FastStd(frame);			% Convert to sigmas
			actuals = actuals/stdFrame;
			estimates = estimates/stdFrame;
		end
		
		if plotActualCDF
			[cdfSigmas, pdf] = ProbabilityDensityFunction(frame);
			cdfProbabilities = PDFtoCDF(cdfSigmas, pdf);
		else
			cdfSigmas = [];
			cdfProbabilities = [];
		end
	end
end

