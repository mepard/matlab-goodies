function settings = DefaultTo (settings, arg, default)
	if ~isfield(settings, arg)
		settings.(arg) = default;
	end
end

