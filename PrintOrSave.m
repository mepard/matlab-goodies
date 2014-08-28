function PrintOrSave (figures, saveInDir, options)
	if any(strcmpi(options, 'print'))
		PrintFigure (figures)
	end
	
	if any(strcmpi(options, 'save'))
		if any(strcmpi(options, 'slides'))
			saveInDir = [saveInDir, filesep, 'Slides'];
		else
			saveInDir = [saveInDir, filesep, 'Plots'];
		end
		SaveFigure(figures, saveInDir, options);
	end
end

