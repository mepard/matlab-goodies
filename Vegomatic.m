function [results, times] = Vegomatic (samples, samplesPerSecond, strideInSeconds, functions, windowsInSeconds, lengthOfResult)
% Slice samples into blocks, at strideInSeconds per block.
% For each slice, call the specified functions with the samples for the specified windows sizes
% surrounding the center of the slice.
%
% Returns one column in results for each function, window size pair.
% Returns an array of times with the center time for each slice.
%
% For example, to compute kurtosis dBG with two different window sizes:
%
% [k,t] = Vegomatic(x,24e6,20e-6,{@kurtosis_dBG,@kurtosis_dBG},[40e-6,400e-6]);
%
% To see the window lengths, which can vary at the beginning or end or due to rounding:
%
% [k,t] = Vegomatic(x,24e6,20e-6,{@length, @length},[40e-6,400e-6]);
%

	if nargin < 6 || isempty(lengthOfResult)
		lengthOfResult = 1;
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
	if numel(windowsInSeconds) ~= numel(functions)
		error ('horizon:Vegomatic:input', 'One function per window required')
	end
	
	strideInSamples = strideInSeconds * samplesPerSecond;
	windowsInSamples = windowsInSeconds * samplesPerSecond; 
	windowOffsets = windowsInSamples/2;

	numBlocks = floor(length(samples) / strideInSamples);
	results = nan(lengthOfResult, numBlocks, numel(functions));
	
	blockCenters = strideInSamples/2 + (1:numBlocks)*strideInSamples;
	for blockNum = 1:length(blockCenters)
		center = blockCenters(blockNum);
		for f = 1:length(functions)
			fn = functions{f};
			windowStart = max([1, round(center - windowOffsets(f))]);
			windowEnd = min([round(center + windowOffsets(f)), length(samples)]);
			r = fn(samples(windowStart:windowEnd));
			assert(length(r) == lengthOfResult)
			results(:,blockNum, f) = fn(samples(windowStart:windowEnd));
		end
	end
	results = squeeze(results);
	
	if nargout > 1
		times = blockCenters / samplesPerSecond;
	end
end
