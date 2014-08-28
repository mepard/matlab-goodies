function [z, direction] = FindZeroCrossing (x, y, expectedDirection, yHysteresis)
	if nargin < 4 || isempty(yHysteresis)
		yHysteresis = 0;
	end

    x = x(:);
	y = y(:);
	
	z = [];
	direction = [];
	
	if any(isnan(y([1 end])))	% Just check first and last.
		return
	end

	bigEnough = abs(y) > yHysteresis;
	start = find(bigEnough, 1, 'first');
	if isempty(start)
		return		% none outside hysteresis
	end
	
	x = x(start:end);
	y = y(start:end);
	bigEnough = bigEnough(start:end);
	
	stop = find(bigEnough & sign(y) ~= sign(y(1)), 1, 'first');
	if isempty(stop)
		return		% sign never changes
	end
	% clear bigEnough	This is SLOW!	% No longer needed and about to be stale.
	
	x = x(1:stop);
	y = y(1:stop);
	
	signs = sign(y);
	assert (signs(1) ~= signs(end))		% Should have been caught above
	
	direction = signs(end);
	if expectedDirection ~= 0 && direction ~= expectedDirection
		return
	end

	nonZeroValues = find(y ~= 0);
	signs = sign(y(nonZeroValues));

	signChanges = find(signs(1:end-1) ~= signs(2:end));
	assert(~isempty(signChanges));
	
	zeroCrossings = [nonZeroValues(signChanges), nonZeroValues(signChanges+1)];	
	
	y = y(zeroCrossings);
	x = x(zeroCrossings);
	if size(zeroCrossings, 1) == 1
		y = y.';	% Single row vector gets converted to column vector. Fix them.
		x = x.';
	end

	deltaY = y(:,2) - y(:,1);
	deltaX = x(:,2) - x(:,1);
	
	z = x(:,1) - (y(:,1) ./ deltaY) .* deltaX;	% Linear interpolation
	
	if numel(z) > 1
		% Find the median. 
		% z is already in order and should be odd so just pick the middle one.
		%
		z = z((numel(z)+1)/2);
	end
end
