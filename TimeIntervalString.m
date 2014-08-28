function s = TimeIntervalString (seconds)
	seconds = round(seconds);
	
	minutes = floor(seconds / 60);
	intervalInSeconds = seconds - minutes*60;
	
	hours = floor(minutes / 60);
	minutes = minutes - hours*60;
	
	days = floor(hours / 24);
	hours = hours - days*24;
	
	if days > 0
		s = sprintf('%d days, %d hours, %d minutes, %d seconds', days, hours, minutes, intervalInSeconds);
	elseif hours > 0
		s = sprintf('%d hours, %d minutes, %d seconds', hours, minutes, intervalInSeconds);
	elseif minutes > 0
		s = sprintf('%d minutes, %d seconds', minutes, intervalInSeconds);
	else
		s = sprintf('%d seconds', intervalInSeconds);
	end
end
