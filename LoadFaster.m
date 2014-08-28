function values = LoadFaster (fileName)
	saved = load(fileName);
	assert(all(ismember(fieldnames(saved), {'names', 'isFactored', 'values'})))
	
	isFactored = find(saved.isFactored);
	for v = isFactored(:).'
		factoredStruct = saved.values{v};
		saved.values{v} = UnfactorStruct (factoredStruct.same, factoredStruct.rest);
	end
	
	if nargout == 0
		for v = 1:numel(saved.names)	% Don't use arrayfun because arrayfun will be the 'caller'.
			assignin('caller', saved.names{v}, saved.values{v});
		end
	else
		for v = 1:numel(saved.names)
			values.(saved.names{v}) = saved.values{v};
		end
	end
end
