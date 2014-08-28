function varargout = GetNumericOption (varargin) %options, optionName, defaultValue
	% [hasOption, optionValue] = GetNumericOption (...);
	% optionValue = GetNumericOption (...);
	outputs = cell(nargout, 1);
	[outputs{:}] = GetOptionValue ('numeric', varargin{:});
	for o = 1:nargout
		varargout{o} = outputs{o}; %#ok<AGROW>
	end
end
