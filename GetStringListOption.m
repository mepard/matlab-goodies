function varargout = GetStringListOption (options, optionName, legalValues, defaultValues)
	% [hasOption, optionValue] = GetStringListOption (...);
	% optionValue = GetStringListOption (...);

	if nargin < 3
		legalValues = {};
	end
	hasDefault = nargin >= 4;
	
	optionPosition = find(strcmpi(options, optionName));
	hasOption = ~isempty(optionPosition);
	if hasOption
		if optionPosition < length(options) && iscell(options{optionPosition+1})
			optionValues = options{optionPosition+1};
		elseif optionPosition < length(options) && ischar(options{optionPosition+1})
			optionValues = options(optionPosition+1);
		elseif hasDefault
			optionValues = defaultValues;
		else
			error ('horizon:nomad:invalidOption', 'Must specify the values for %s', optionName)
		end
	else
		if hasDefault
			optionValues = defaultValues;
		else
			optionValues = {};
		end
	end
	if ~isempty(legalValues)
		for v = 1:numel(optionValues)
			if ~any(strcmpi(legalValues, optionValues{v}))
				error ('horizon:nomad:invalidOption', '%s is not a legal value for %s', optionValues{v}, optionName)
			end
		end
	end

	if nargout == 1
		varargout{1} = optionValues;
	else
		varargout{1} = hasOption;
		varargout{2} = optionValues;
	end
end

