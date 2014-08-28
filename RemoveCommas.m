function table = RemoveCommas (table)
	
	% Remove commas to prevent problem when saved as CSV file.
	%
	if size(table, 1) > 0
		variableNames = table.Properties.VariableNames;
		for v = 1:numel(variableNames)
			values = table.(variableNames{v});
			if iscell(values) && ischar(values{1})
				values = cellfun (@(r) strrep(r, ',', ''), values, 'UniformOutput', false);
				table.(variableNames{v}) = values;
			end
		end
	end
	rowNames = table.Properties.RowNames;
	rowNames = cellfun (@(r) strrep(r, ',', ''), rowNames, 'UniformOutput', false);
	table.Properties.RowNames = rowNames;
end
