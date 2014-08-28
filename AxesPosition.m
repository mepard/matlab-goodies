function position = AxesPosition (ah, units)
	previousUnits = set (ah, 'Units', units);
	position = get(ah, 'Position');
	set (ah, 'Units', previousUnits);
end

