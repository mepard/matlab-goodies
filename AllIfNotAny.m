function options = AllIfNotAny (options, ofThese)
	m = StrCmpi2d(options, ofThese);
	if ~any(m(:))
		options = [options, ofThese];
	end
end
