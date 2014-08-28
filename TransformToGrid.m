function [points, originalCorners, corners, gridCorners] = TransformToGrid (points, grid)
	assert (~isreal(points))	% Must be complex
	assert (~isreal(grid))		% Must be complex
	
	originalShape = size(points);
	
	numPoints = length(points);
	points = [real(points(:)), imag(points(:))];
	grid = [real(grid(:)), imag(grid(:))];
	
	gridX = unique(grid(:,1));
	gridY = unique(grid(:,2));
	
	% We assume the grid is evenly spaced
	%
	% assert (length(unique(diff(gridX))) == 1)		These can go off due to insignificant differences.
	% assert (length(unique(diff(gridY))) == 1)
	
	numModesX = length(gridX);
	pointsPerModeX = floor(numPoints/numModesX);
	numPointsX = numModesX * pointsPerModeX;
	
	numModesY = length(gridY);
	pointsPerModeY = floor(numPoints/numModesY);
	numPointsY = numModesY * pointsPerModeY;
	
	% Isolate the points in each of the corners.
	%
	% 	2	3
	%
	% 	1	4
	%
	x_ = sort(points(1:numPointsX, 1));
	y_ = sort(points(1:numPointsY, 2));
	x1 = x_(pointsPerModeX);
	y1 = y_(pointsPerModeY);
	x2 = x_(end-pointsPerModeX+1);
	y2 = y_(end-pointsPerModeY+1);
	
	points1 = points(points(:,1) <= x1 & points(:,2) <= y1, :);
	points2 = points(points(:,1) <= x1 & points(:,2) >= y2, :);
	points3 = points(points(:,1) >= x2 & points(:,2) >= y2, :);
	points4 = points(points(:,1) >= x2 & points(:,2) <= y1, :);

	% Find the middles of the clusters the corners
	%
	corners = [	median(points1, 1)
				median(points2, 1)
				median(points3, 1)
				median(points4, 1)] ;
	
	% Find the grid corners
	%
	gridCorners = [ gridX(1), 	gridY(1) 
					gridX(1), 	gridY(end)
					gridX(end), gridY(end)
					gridX(end), gridY(1)	];
	
	% Map the corners to the gridCorners
	%
	% Could do all of this with an affine transform
	%
	%transformMatrix = @@@;
	%points = points * transformMatrix;
	
	% Adjust height and width
	%
	widthScaleFactor  = (gridX(end) - gridX(1)) / (mean(corners(3:4, 1)) - mean(corners(1:2, 1)));
	heightScaleFactor  = (gridY(end) - gridY(1)) / (mean(corners(2:3, 2)) - mean(corners([1 4], 2)));
	
	corners(:,1) = corners(:,1) * widthScaleFactor;
	corners(:,2) = corners(:,2) * heightScaleFactor;
	points(:,1) = points(:,1) * widthScaleFactor;
	points(:,2) = points(:,2) * heightScaleFactor;
	originalCorners = corners;
	
	% Correct for shear (skew)
	%
	vertialShear = mean(corners(3:4, 2) - corners(1:2, 2));
	width  		 = mean(corners(3:4, 1) - corners(1:2, 1));
	corners(:,2) = corners(:,2) - vertialShear .* (corners(:,1) - corners(1, 1)) / width;
	points(:,2) = points(:,2)  - vertialShear .* (points(:,1) - corners(1, 1)) / width;

	horizontalShear = mean(corners(2:3, 1) - corners([1 4], 1));
	height  		= mean(corners(2:3, 2) - corners([1 4], 2));
	corners(:,1) = corners(:,1) - horizontalShear .* (corners(:,2) - corners(1, 2)) / height;
	points(:,1) = points(:,1) - horizontalShear .* (points(:,2) - corners(1, 2)) / height;
	
	% Align the centers
	%
	offset = mean(corners, 1) - mean(gridCorners, 1);
	corners = corners - repmat(offset, 4, 1);
	points(:,1) = points(:,1) - offset(1);
	points(:,2) = points(:,2) - offset(2);
	
	% Wrap it up
	%
	points = complex(points(:,1), points(:,2));
	points = reshape(points, originalShape);
end
