function varargout = GetOptionValue (optionClass, options, optionName, defaultValue)
	% [hasOption, optionValue] = GetOptionValue (...);
	% optionValue = GetOptionValue (...);
	
	if ~iscell(options)
		error ('horizon:impulse:invalidArgType', 'Options must be a cell array, not a %s', class(options))
	end
	
	hasDefault = nargin >= 4;

	optionPosition = find(strcmpi(options, optionName));
	hasOption = ~isempty(optionPosition);
	if hasOption
		if optionPosition < length(options) && isa(options{optionPosition+1}, optionClass)
			optionValue = options{optionPosition+1};
		elseif hasDefault
			optionValue = defaultValue;
		else
			error ('horizon:nomad:invalidOption', 'Must specify the value for %s', optionName)
		end
	else
		if hasDefault
			optionValue = defaultValue;
		else
			optionValue = [];
		end
	end
	
	if nargout == 1
		varargout{1} = optionValue;
	else
		varargout{1} = hasOption;
		varargout{2} = optionValue;
	end
end
