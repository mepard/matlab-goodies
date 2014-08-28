function ExcludeFromLegend (h)
	set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
