function PlotMore (x, y)
	for i = 1:size(y, 2)
		plot(x, y(:,i), LineSpecFor(i))
		hold on
	end
end
