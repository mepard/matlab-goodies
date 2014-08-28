function FlushDiary ()
	if strcmpi(get(0,'Diary'), 'on')
		diary off
		diary on
	end
end
