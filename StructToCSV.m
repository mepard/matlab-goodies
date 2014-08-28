function StructToCSV(s, fileName)
	if nargin < 2
		fileName = [];
	end
	
	if ~isempty(fileName)
		fid = fopen(fileName, 'w');
		if fid < 0
			error ('Horizon:Goodies:cantCreateFile', 'Could not create %s was not found', toFile)
		end
	   	closeFidWhenDeleted = onCleanup(@() fclose(fid));	% Will fire on clear or (e.g. control-C).
	else
		fid = 1;	% stdout
	end
	
	s = FullyFlattenStruct (s);		% So we don't store arrays, structs, etc. in a CSV cell.
	
	fields = fieldnames(s);
	fieldsNameRow = cellfun(@(f) strrep(f, '_', ' '), fields, 'uniformoutput', false);
	fieldsNameRow = cellfun(@(f) sprintf('"%s",', f), fieldsNameRow, 'uniformoutput', false);
	fieldsNameRow = [fieldsNameRow{:}];
	fieldsNameRow(end) = [];		% Remove trailing comma
	fprintf (fid, '%s\n', fieldsNameRow);
	for i = 1:numel(s)
		for f = 1:length(fields)
			if f > 1
				fprintf(fid, ',');
			end
			fieldValue = s(i).(fields{f});
			if ~isempty(fieldValue)
                if ischar(fieldValue)
                    fieldValue = strrep(fieldValue, ',', '');
                end
				fprintf (fid, '%s', ToString(fieldValue));
			end
		end
		fprintf (fid, '\n');
	end
end
