function bestLag = BestLag (x, y, minLag, maxLag)

	numSamplesInCommon = min([length(x) length(y)]);
	numSamplesToCompare = numSamplesInCommon-maxLag;
	y = y(1:numSamplesToCompare);
	meanY = FastSum(y)/numSamplesToCompare;
	
	lags = minLag:maxLag;
	correlations = zeros(size(lags));
	for l = 1:length(lags);
		correlations(l) = FastCorrelation (x(lags(l) + (1:numSamplesToCompare)), y, meanY);
	end
	
	[~, m] = max(correlations);
	bestLag = lags(m);
	
	if false
		CascadeFigure(figure('name', 'BestLag XY')); %#ok<UNRCH>
		
		plot(x, 'r')
		hold on
		plot(bestLag + (1:length(y)), y, 'b')
		plot(bestLag + [0 0], ylim, 'r--')
		
		xlabel('Index')
		grid on, grid minor
		zoom on

		CascadeFigure(figure('name', 'BestLag Correlations'));
		
		plot(lags, correlations, 'b.-')
		hold on
		plot(bestLag + [0 0], ylim, 'r--')
		
		xlabel('Lag')
		ylabel('Correlation')
		grid on, grid minor
		zoom on
	end
end
