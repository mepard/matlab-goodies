function hasOption = GetLogicalOption (options, optionName, default)
	hasDefault = nargin > 2;
	hasOption = any(strcmpi(options, optionName));
	hasNotOption = any(strcmpi(options, ['~' optionName]));
	if hasOption && hasNotOption
		error ('horizon:impulse:optionConflict', 'Choose one of %s and %s', optionName, ['~' optionName])
	end
	if ~hasOption && ~hasNotOption
		if hasDefault
			hasOption = default;
		else
			error ('horizon:impulse:optionMissing', 'Specify either %s and %s', optionName, ['~' optionName])
		end
	end
end

