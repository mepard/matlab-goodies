function delta = StandardErrorForDivision (x, errorX, y, errorY)
	delta = sqrt(errorX.^2 + errorY.^2.*(x./y).^2) ./ y;
end

