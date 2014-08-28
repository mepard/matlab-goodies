function AddWatermark (s)
	text('Units', 'normalized', 'Position', [.5 .5], 'rotation', -45, ...
			'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
			'color', [255 180 180]/255, ...
			'FontUnits', 'normalized', 'FontSize', 0.1, ...
			'string', s);
end
