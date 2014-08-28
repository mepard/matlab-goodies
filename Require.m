function Require (settings, arg)
	if ~isfield(settings, arg)
		error ('horizon:HSPA:missingArg', '-%s required for %s', arg, settings.action)
	end
end

