function [maximums, ranges, rangeCounts] = FindModes (x, numBins, options) 
	if nargin < 2 || isempty(numBins)
		numBins = 50;
	end
	if nargin < 3
		options = {}; 
    end
	
    plotModes = any(strcmpi(options, 'plot')) || nargout == 0;
    
	x = x(:);
	
	boarders = linspace (min(x), max(x), numBins+1).';
	
	centers = mean([boarders(1:end-1), boarders(2:end)],2);
	assert (numel(centers) == numBins)
    
	counts = nan(numBins, 1);
	counts(1) = sum(x < boarders(2));
	for b = 2:length(counts)-1
		counts(b) = sum(x >= boarders(b) & x < boarders(b+1));
	end
	counts(end) = sum(x >= boarders(end-1));
	assert(~any(isnan(counts)))
	
    maximums = [];
    ranges = [];
    rangeCounts = [];
	while (true)
		[maxCount, peak] = max(counts);
		
		if maxCount < 4
			break;
		end
		
		% Find a low count to the left and right
		%
		left = find (counts(peak-1:-1:1) < 2, 1, 'first');
		if ~isempty(left)
			left = peak - left;
		else
			left = 1;
		end
		
		right = find (counts(peak+1:end) < 2, 1, 'first');
		if ~isempty(right)
			right = peak + right;
		else
			right = numel(counts);
		end
		
		maximums = [maximums; centers(peak)]; %#ok<*AGROW>
		ranges = [ranges; boarders(left), boarders(right+1)];
		
		rangeCounts = [rangeCounts; sum(counts(left:right))];
		
		counts(left:right) = 0; % take out of consideration
    end
    
    [maximums, sortedOrder] = sort(maximums);
    ranges = ranges(sortedOrder,:);
    rangeCounts = rangeCounts(sortedOrder);
    
    if plotModes
    	figure
    	hold on
    	plot (x)
    	for r = 1:numel(maximums)
    		plot ([1 numel(x)], maximums(r) + [0 0], 'c')
    		plot ([1 numel(x)], ranges(r,1) + [0 0], 'r')
    		plot ([1 numel(x)], ranges(r,2) + [0 0], 'g')
    	end
    	
    	grid on
    	zoom on
    end
end
