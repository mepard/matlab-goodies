function PrintAnnotation (x, y, color, s)
	if (x < 0)
		axesSize = AxesSize(gca, 'Points');
		x = axesSize(1) + x;
		horizontalAlignment = 'right';
	else
		horizontalAlignment = 'left';
	end
	if (y < 0)
		axesSize = AxesSize(gca, 'Points');
		y = axesSize(2) + y;
		verticalAlignment = 'top';
	else
		verticalAlignment = 'bottom';
	end
	text('Units', 'points', 'HorizontalAlignment', horizontalAlignment, 'VerticalAlignment', verticalAlignment, 'Position', [x, y], 'color', color, 'FontSize', 14, 'string', s);
end
