function [array1, array2] = MatchStructArrays (array1, array2, fieldName)
	values1 = [array1.(fieldName)];
	values2 = [array2.(fieldName)];
	if length(values1) ~= length(values2) || any(values1 ~= values2)
		array1(~ismember(values1, values2)) = [];
		array2(~ismember(values2, values1)) = [];
	end
end
