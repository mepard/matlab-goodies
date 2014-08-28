function struct1 = AverageFields (structArray)
	if length(structArray) < 2
		struct1 = structArray;
		return
	end
	
	fields = fieldnames (structArray);
	for f = 1:length(fields)
		field = fields{f};
		
		value1 = structArray(1).(field);
		
		if numel(value1) == 1
			struct1.(field) = mean([structArray.(field)]);
		else
			sz = size(value1);
			assert (sz(2) == 1)		% We only need the simple case for now
			
			struct1.(field) = mean([structArray.(field)], 2);
		end
	end
end

