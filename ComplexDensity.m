function density = ComplexDensity (x)
	allX = x(:);
	density = zeros(size(x));
	for m = 1:size(x, 1)
		for n = 1:size(x, 2)
			density(m,n) = sum(abs(allX - x(m,n)));
		end
	end
	density = density / max(density);
end
