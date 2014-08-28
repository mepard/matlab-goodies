function ClaimUnusedSpace (axesPairs)
	% Claim unused space in figure.
	%
	% Identify primaries and pairs
	%
	allAxes = axesPairs(~isnan(axesPairs(:))).';
	primaries = find(ismember(allAxes, axesPairs(:,1)));

	pairs = cell(size(allAxes));
	for a = primaries
		% Find the matching secondary axes, if there is one.
		p = axesPairs(:,1) == allAxes(a);
		s = find(allAxes == axesPairs(p,2));
		pairs{a} = [a s];
	end

	% Grab the current positions and margins
	%
	positions = GetAxesProperties(allAxes, 'Position');		% left, bottom, width, height
	assert(issorted(-positions(primaries,2)))			% Should be top to bottom

	margins = GetAxesProperties(allAxes, 'TightInset');		% left, bottom, right, top

	% Set up horizontal locations and margins
	%
	leftMargin = max(margins(:,1));
	positions(:,1) = leftMargin;					% All against left edge
	positions(:,3) = positions(:,3) + leftMargin;	% and that much wider

	rightMargin = max(margins(:,3));

	margins(:,3) = rightMargin;
	positions(:,3) = 1 - positions(:,1) - rightMargin;

	% Vertical is more difficult due to plotyy pairs
	%
	defaultHeightFraction = 1/length(primaries);
	heightFractions = defaultHeightFraction * ones(size(allAxes));
	assert(abs(1 - sum(heightFractions(primaries))) <= eps(1))

	availableVerticalSpace = 1;
	for a = primaries
		pair = pairs{a};
		availableVerticalSpace = availableVerticalSpace - max(margins(pair,2)) - max(margins(pair,4));
	end
	assert(availableVerticalSpace > 0 && availableVerticalSpace < 1)

	positions(:,4) = heightFractions .* availableVerticalSpace;

	% Set vertical positions from bottom to top
	%
	previousTop = 0;
	for a = primaries(end:-1:1)
		pair = pairs{a};
		bottom = previousTop + max(margins(pair,2));
		positions(pair,2) = bottom;
		previousTop = bottom + max(positions(pair,4)) + max(margins(pair,4));
	end
	assert(abs(1 - sum(previousTop)) <= eps(1))

	% Make it so
	%
	for a = 1:length(allAxes)
		set (allAxes(a), 'Position', positions(a,:))
	end
end
