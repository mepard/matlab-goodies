function counts = AccumulateFieldValues (structOrTable, rowFields, columnFields)
	isTable = istable(structOrTable);
	
	rows = GroupBy (structOrTable, rowFields);
	totals = zeros(numel(rows), numel(columnFields));
	for r = 1:numel(rows)
		for c = 1:numel(columnFields)
			if isTable
				total = sum(structOrTable.(columnFields{c})(rows(r).members));
			else
				total = sum(structOrTable(rows(r).members).(columnFields{c}));
			end
			totals(r,c) = total;
		end
	end
	rowNames = {rows.name};
	columnNames = columnFields;
	counts = array2table(totals, 'RowNames', rowNames, 'VariableNames', columnNames);
end
