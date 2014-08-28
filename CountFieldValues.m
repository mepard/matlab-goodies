function counts = CountFieldValues (structOrTable, rowFields, columnFields)
	if nargin < 3
		columnFields = {};
	end
	rows = GroupBy (structOrTable, rowFields);
	columns = GroupBy (structOrTable, columnFields);
	counts = zeros(numel(rows), numel(columns));
	for r = 1:numel(rows)
		for c = 1:numel(columns)
			counts(r,c) = numel(intersect(rows(r).members, columns(c).members));
		end
	end
	rowNames = {rows.name};
	if ~isempty(columnFields)
		columnNames = matlab.lang.makeValidName({columns.name});
	else
		columnNames = {'Count'};
	end
	counts = array2table(counts, 'RowNames', rowNames, 'VariableNames', columnNames);
end
