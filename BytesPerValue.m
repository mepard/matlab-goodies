function [bytesPerValue, isInteger] = BytesPerValue (dataType)
	oneValue = zeros(1,1,dataType); %#ok<NASGU>
	isInteger = isinteger(oneValue);
	
	dataTypeInfo = whos('oneValue');
	bytesPerValue = dataTypeInfo.bytes;
end
