function [z, direction] = FindZeroCrossings (x, y)
	if nargin < 2
		y = x;
		x = [];
	end
	
	originalShape = size(y);

	useIndices = isempty(x);
	if useIndices
		x = 1:numel(y);
	end	
	
	x = x(:);
	y = y(:);
	
	debug = nargout == 0;
	if debug
		figure
		hold on
		plot(x, y, 'b.-')
	end
	
	nonZeroValues = find(y ~= 0);
	signs = sign(y(nonZeroValues));
	
	signChanges = find(signs(1:end-1) ~= signs(2:end));

	if isempty(signChanges)
		z = [];
		direction = [];
	else
		zeroCrossings = [nonZeroValues(signChanges), nonZeroValues(signChanges+1)];	
		
		y = y(zeroCrossings);
		x = x(zeroCrossings);
		if size(zeroCrossings, 1) == 1
			y = y.';	% Single row vector gets converted to column vector. Fix them.
			x = x.';
		end
		direction = sign(y(:,2));

		deltaY = y(:,2) - y(:,1);
		deltaX = x(:,2) - x(:,1);
		
		z = x(:,1) - (y(:,1) ./ deltaY) .* deltaX;	% Linear interpolation
		if useIndices
			z = round(z);
		end
		
		if debug
			plot (x(:,1), y(:,1), 'ro')
			plot (x(:,2), y(:,2), 'bo')

			upCrossings = find(direction > 0); 
			dnCrossings = find(direction < 0); 
			plot(z(upCrossings), zeros(size(upCrossings)), 'k*')
			plot(z(dnCrossings), zeros(size(dnCrossings)), 'r*')
			
			grid on
			box on
			zoom on
		end
	end
	if originalShape(1) == 1
		z = z.';
		direction = direction.';
	end
end
