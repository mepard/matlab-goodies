function x = ReadBinary (fileName, fileDataType, isComplex, numToKeepPerRow, numToSkipPerRow, rowRange, asInteger)
	% Read binary file, such as created by the Gnu Radio File Sink.
	% Creates n-by-valuesPerRow matrix, where n is the number of rows.
	%

	if nargin < 2 || isempty(fileDataType)
		fileDataType = 'int16';
	end
	if nargin < 3 || isempty(isComplex)
		isComplex = true;
	end
	if nargin < 4 || isempty(numToKeepPerRow)
		numToKeepPerRow = 1;
	end
	if nargin < 5 || isempty(numToSkipPerRow)
		numToSkipPerRow = 0;
	end
	if nargin < 6
		rowRange = [];
	end
	if nargin < 7 || isempty(asInteger)
		asInteger = false;
	end
	if isComplex && asInteger
		error ('Horizon:Goodies:cantReturnComplexIntegers', 'MATLAB doesn''t support complex integers')
	end
	
	returnSize = numel(rowRange) == 1 && isnan(rowRange);
	if returnSize
		rowRange = [];
	end
	
	[bytesPerRealValue, isInteger] = BytesPerValue (fileDataType);
	
	if isComplex
		numRealValuesPerRow = 2*numToKeepPerRow;
		skipBytesPerRow = numToSkipPerRow * 2*bytesPerRealValue;
	else
		numRealValuesPerRow = numToKeepPerRow;
		skipBytesPerRow = numToSkipPerRow * bytesPerRealValue;
	end
	bytesPerRow = bytesPerRealValue*numRealValuesPerRow + skipBytesPerRow;
	
	fid = fopen (fileName, 'r');
	if fid < 0
		error ('Horizon:Goodies:FileNotFound', '%s was not found', fileName)
	end
   	closeFidWhenDeleted = onCleanup(@() fclose(fid));	% Will fire on clear or (e.g. control-C).

	fseek (fid, 0, 'eof');
	bytesInFile = ftell(fid);

	rowsInFile = bytesInFile/bytesPerRow;

	startingRow = 0;
	numRows = rowsInFile;

	if ~returnSize
		if ~isempty(rowRange)
			startingRow = startingRow + rowRange(1);
			if isinf(rowRange(2))
				numRows = rowsInFile - startingRow;
			else
				numRows = diff(rowRange);
				if startingRow + numRows > rowsInFile
					error ('horizon:nomad:eof', 'Sample range %s exceeds file size.', ToString(rowRange))
				end
			end
		end
		
		status = fseek (fid, startingRow*bytesPerRow, 'bof');
		assert(status == 0)
	
		numValuesToRead = numRows*numRealValuesPerRow;
		[x, count] = fread (fid, numValuesToRead, ['*', fileDataType], skipBytesPerRow);
		assert(count == numValuesToRead)
	end
	clear closeFidWhenDeleted		% Cause fid to be closed now since we're done with it
	
	if returnSize
		x = [numRows, numToKeepPerRow];
	else
		if asInteger
			assert (~isComplex)
			assert (isInteger)
		else
			if isInteger
				x = double(x)/double(intmax(fileDataType));
			else
				x = double(x);
			end

			if isComplex
				x = reshape(x, 2, []);
				x = complex(x(1,:), x(2,:));
			end
		end
		x = reshape(x, numToKeepPerRow, []);
		x = x .';
	end
end
