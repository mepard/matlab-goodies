function cellsOut = UniqueCells(cellsIn)
	% Like unique, but works on cell arrays containing structs, strings, almost anything.
	%
	cellsOut = {};
	while ~isempty(cellsIn)
		cellsOut = [cellsOut, {cellsIn{1}}];
		matches = cellfun(@(c) isequaln(c, cellsIn{1}), cellsIn);
		assert(matches(1))
		cellsIn(matches) = [];
	end
end
