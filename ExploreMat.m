function ExploreMat (pathNames, repairSourceFile, options)
	if nargin < 2
		repairSourceFile = '';
	end
	if nargin < 3
		options = {};
	end
	
	pathNames = ExpandWildcards(pathNames, {'exists'});
	
	if ~isempty(repairSourceFile)
		pathNames(strcmp(pathNames, repairSourceFile)) = [];
		repairData = ExploreFile (repairSourceFile, {'quiet','struct'});
		for f = 1:length(pathNames)
			RepairFile (pathNames{f}, repairData);
		end
	else
		for f = 1:length(pathNames)
			ExploreFile (pathNames{f}, options)
		end
	end
end

function RepairFile (fileName, repairData)
	[path, name, extension] = fileparts(fileName);
	
	repairedPath = [path, filesep, 'Repaired'];
	if ~exist (repairedPath, 'dir')
		mkdir(repairedPath);
	end
	
	newName = [repairedPath, filesep, name, extension];
	
	fileData = ExploreFile (fileName, {'quiet'});
	if isempty(fileData)
		return	% Not repairable. Error was reported in ExploreFile.
	end
	if ~fileData.fileNeedsRepair
		fprintf (1, '%s does not need repair.\n', fileName);
		return
	end
	
	% Adjust the dimensions
	%
	if rem(fileData.numElements, repairData.numFields) ~= 0
		fprintf (2, 'The number of data elements of %s (%d) does not divide evenly by number of fields in the repair data (%d)\n', ...
					fileName, fileData.numElements, repairData.numFields);
		return	% Not repairable.
	end
	
	numStructArrayElements = fileData.numElements / repairData.numFields;
	repairData.contents(repairData.dimensionIndex(1), repairData.dimensionIndex(2)) = numStructArrayElements;
	
	fid = fopen(newName, 'wb');
	assert (fid >= 0)
	closeFidWhenDeleted = onCleanup(@() fclose(fid));	% Will fire on clear or (e.g. control-C).

	% Write the header
	%
	fwrite (fid, fileData.headerText);
	fwrite (fid, [0 0], 'uint32');			% subsystem offsets
	fwrite (fid, 256, 'uint16');			% version
	fwrite (fid, flip('MI'));				% endian indicator, little endian
	assert (ftell(fid) == 128)
	
	% Write a matrix data element
	%
	fwrite (fid, 14, 'uint32');				% matrix data element type
	fwrite (fid, 4*(numel(repairData.contents) + numel(fileData.contents)), 'uint32');	% number of bytes in element
	fwrite (fid, repairData.contents, 'uint32');
	fwrite (fid, fileData.contents, 'uint32');
	
	clear closeFidWhenDeleted
	
	fprintf (1, '%s repaired. %d struct array elements.\n', newName, numStructArrayElements);
end

function fileData = ExploreFile (fileName, options)
	if nargin < 2
		options = {};
	end
	
	summary = any(strcmpi(options, 'summary'));
	quiet = any(strcmpi(options, 'quiet'));
	details = ~summary && ~quiet;
	exploreStructElements = any(strcmpi(options, 'struct'));
	
	fid = fopen(fileName, 'rb');
	assert (fid >= 0)
	closeFidWhenDeleted = onCleanup(@() fclose(fid));	% Will fire on clear or (e.g. control-C).

	fseek (fid, 0, 'eof');
	bytesInFile = ftell(fid);
	frewind (fid);

	if details
		fprintf (1, 'File: %s\n', fileName);
		fprintf (1, 'Size: %d bytes\n', bytesInFile);
	end

	headerText = fread (fid, 116);
	subsysOffsets = fread (fid, 2, '*uint32');
	version = fread (fid, 1, '*uint16');
	endianIndicator = fread (fid, 2);
	endianIndicator = flip(endianIndicator);    % We only do little endian.
	if any(endianIndicator.' ~= 'MI') && details
		fprintf (2, 'Endian indicator is %s instead of MI. Some values will be wrong.\n', endianIndicator);
	end

	if details
		fprintf (1, 'Header text: %s\n', headerText);
		fprintf (1, 'Subsys offsets: %d %d\n', subsysOffsets);
		fprintf (1, 'Version: %d\n', version);
		fprintf (1, 'Endian indicator: %s\n', endianIndicator);
	end

	assert(ftell(fid) == 128)
	if rem(bytesInFile - 128, 8) ~= 0 && details
		fprintf (2, 'File has non-integral number if 8-byte blocks.\n');
	end

	num8byteBlocks = floor((bytesInFile - 128)/8);

	contentsAsUint32s = fread (fid, [2,num8byteBlocks], '*uint32');
	clear closeFidWhenDeleted		% done with file

	dataElementIsPlausable = contentsAsUint32s(1,:) == 14 & rem(contentsAsUint32s(2,:),8) == 0;

	fileMightBeRepairable = false;
	currentPosition = 1;
	chainStartPosition = 1;
	numElements = 0;
	while true
		filePosition = 128 + 8*(currentPosition-1);
		if ~dataElementIsPlausable(currentPosition)
			numElements = 0;
			if details
				fprintf (2, 'Tag at file position %d is invalid. Searching for valid tag.\n', filePosition);
			end
			chainStartPosition = chainStartPosition + find(dataElementIsPlausable(chainStartPosition+1:end),1,'first');
			if isempty(chainStartPosition)
				fprintf (2, 'File %s has no valid tags remaining after file position %d.\n', fileName, filePosition);
				break
			end
			currentPosition = chainStartPosition;
			filePosition = 128 + 8*(currentPosition-1);
			if details
				fprintf (2, 'Found a possible data element at file position %d\n', filePosition);
			end
		end
	
		numberOfBytes = contentsAsUint32s(2,currentPosition);
		nextFilePosition = filePosition + 8 + numberOfBytes;

		numElements = numElements + 1;
		if details
			fprintf (1, 'Matrix element %d file positions: %d - %d, size %d\n', numElements, filePosition, nextFilePosition, numberOfBytes);
		end
		
		if nextFilePosition > bytesInFile
			dataElementIsPlausable(currentPosition) = false;
			if details
				fprintf (2, 'Element %d: ends %d bytes beyond the end of the file\n', numElements, nextFilePosition - bytesInFile);
			end
			continue
		end
		if nextFilePosition == bytesInFile
			if ~quiet
				if summary
					fprintf (1, 'File %s has %d elements starting at position %d\n', fileName, numElements, 128 + 8*(chainStartPosition-1));
				else
					fprintf (1, 'Clean EOF reached. Start of chain is at file position %d\n', 128 + 8*(chainStartPosition-1));
				end
			end
			fileMightBeRepairable = true;
			break
		end
		currentPosition = currentPosition + 1 + numberOfBytes/8;
	end
	
	if exploreStructElements
		if ~fileMightBeRepairable || numElements ~= 1 || chainStartPosition ~= 1
			fprintf (2, 'Can''t explore struct elements for %s.\n', fileName);
			return
		end
		
		startingPosition = filePosition + 8;
		endingPosition = nextFilePosition;
		contentsAsUint32s = contentsAsUint32s(:,chainStartPosition+1:end);
		
		startOfStructData = nan;
		currentPosition = 1;
		numSubelements = 0;
		while currentPosition <= size(contentsAsUint32s,2)
			dataType = contentsAsUint32s(1,currentPosition);
			numberOfBytes = contentsAsUint32s(2,currentPosition);
			numSubelements = numSubelements + 1;
			filePosition = startingPosition + 8*(currentPosition-1);
			
			if numSubelements == 6
				% Immediately follows the field names
				startOfStructData = currentPosition;
			end
			
			smallElementTypeAndSize = typecast(dataType, 'uint16');	%@@@ Endianness??
			assert(length(smallElementTypeAndSize) == 2)
			if smallElementTypeAndSize(2) ~= 0
				dataType = smallElementTypeAndSize(1);
				numberOfBytes = smallElementTypeAndSize(2);
				if details
					fprintf (1, 'Subelement %d: file position %d, type %d, size %d (small format)\n', numSubelements, filePosition, dataType, numberOfBytes);
				end
				nextFilePosition = filePosition + 8;
				currentPosition = currentPosition + 1;
			else
				if details
					fprintf (1, 'Subelement %d: file position %d, type %d, size %d\n', numSubelements, filePosition, dataType, numberOfBytes);
				end
				nextFilePosition = filePosition + 8 + numberOfBytes;
				if numSubelements == 2
					% This is the Dimensions subelement
					numDimensions = numberOfBytes/4;
					dimensionsLocations = currentPosition+(1:ceil(numDimensions/2));
					dimensions = contentsAsUint32s(:,dimensionsLocations);
					dimensions = dimensions(:).';
					if details
						fprintf (1, 'Dimensions: %s\n', ToString(dimensions(1:numDimensions)));
					end
				end
				currentPosition = currentPosition + 1 + ceil(numberOfBytes/8);
			end
		end
		if nextFilePosition == endingPosition
			numDataSubelements = numSubelements - 5;
			numStructArrayElements = prod(dimensions);
			if rem(numDataSubelements, numStructArrayElements) ~= 0
				fprintf (2, 'The number of data subelements of %s (%d) does not divide evenly by the size of the struct array (%d)\n', ...
							fileName, numDataSubelements, numStructArrayElements);
			else
				whichDimension = find(dimensions == numStructArrayElements, 1);
				if isempty(whichDimension)
					fprintf (2, 'Can''t find the dimension of %s to edit.\n', fileName);
				else
					if nargout > 0
						fileData.numFields = numDataSubelements / numStructArrayElements;
						fileData.dimensionIndex = [whichDimension, dimensionsLocations(1)];
						fileData.contents = contentsAsUint32s(:,1:startOfStructData-1);
					elseif summary && ~quiet
						fprintf (1, 'File %s has %d fields and %d struct array elements\n', fileName, numDataSubelements / numStructArrayElements, numStructArrayElements);
					end
				end
			end
		else
			fprintf (2, 'The last subelement of %s ended at %d instead of %d\n', fileName, nextFilePosition, endingPosition);
		end
	else
		if nargout > 0
			if fileMightBeRepairable
				fileData.fileNeedsRepair = numElements ~= 1 || chainStartPosition ~= 1;
				fileData.headerText = headerText;
				fileData.numElements = numElements;
				fileData.contents = contentsAsUint32s(:,chainStartPosition:end);
			else
				fprintf (2, 'Can''t repair %s.\n', fileName);
				fileData = [];
			end
		end
	end
end