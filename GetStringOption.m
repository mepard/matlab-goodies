function varargout = GetStringOption (varargin) %options, optionName, defaultValue
	% [hasOption, optionValue] = GetStringOption (...);
	% optionValue = GetStringOption (...);
	outputs = cell(nargout, 1);
	[outputs{:}] = GetOptionValue ('char', varargin{:});
	for o = 1:nargout
		varargout{o} = outputs{o}; %#ok<AGROW>
	end
end
