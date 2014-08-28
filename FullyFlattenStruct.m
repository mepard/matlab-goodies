function s = FullyFlattenStruct (s)
	% s.ss.b -> s.ss_b		sub-struct
	% s.a(1:10) -> s.a_1, s.a_2, ... s.a_10
	% s.a(1:3,1:2) -> s.a_1_1, s.a_2_1, s.a_3_1, s.a_1_2, s.a_2_2, s.a_3_2
	% s.c{1} -> s.c
	
	s = s(:);
	
	% Keep flattening until there's nothing left to flatten
	while true	
		% Flatten arrays first so struct or cell arrays with multiple elements get numbered, then flattened.
		FlattenArrays;	% Don't need to go around again, if there's nothing else to do
		if Decellerize
			continue	% Could result in new arrays or sub-structs or cells, go around again.
		end
		if FlattenSubstructs
			continue 	% Could result in new arrays or sub-structs or cells, go around again.
		end
		break		% Finished at last
	end

	function flattenedAny = FlattenArrays
		flattenedAny = false;
		fields = fieldnames(s);
		for f = 1:length(fields)
			fieldName = fields{f};
			
			flattenedThisField = false;
			removeFieldIfFlattened = true;
			
			charElements = arrayfun(@(v) ischar(v.(fieldName)), s);

			% First do the char elements
			% 
			if any(charElements)
				if any(arrayfun(@(v) ndims(v.(fieldName)) > 2, s(charElements))); %#ok<ISMAT>
					error ('horizon:impulse:goodies', 'FullyFlattenStruct doesn''t support char arrays with more than two dimensions.')
				end
				
				% Process all the empty elements as char, too.
				%
				charElements = charElements | arrayfun(@(v) isempty(v.(fieldName)), s);
				if any(arrayfun(@(v) ~isrow(v.(fieldName)) && ~iscolumn(v.(fieldName)) && ~isempty(v.(fieldName)), s(charElements)))
					for i = find(charElements).'
						% Make each row a separate field
						%
						valueToFlatten = s(i).(fieldName);
						for r = 1:size(valueToFlatten, 1)
							suffix = sprintf ('_%d', r);
							s(i).([fieldName suffix]) = valueToFlatten(r,:);
						end
					end
					flattenedThisField = true;
				else
					% All are rows or columns. Make all into rows.
					%
					for i = find(charElements).'
						valueToFlatten = s(i).(fieldName);
						if iscolumn(valueToFlatten)
							s(i).(fieldName) = valueToFlatten(:).';	% Make it a row vector
							flattenedThisField = true;
						end
					end
					removeFieldIfFlattened = false;
				end
			end
			
			% Now do the non-character elements.
			%
			if any(~charElements)
                if all(arrayfun(@(v) numel(v.(fieldName)), s(~charElements)) <= 1)
					removeFieldIfFlattened = false;		% All empty or scalers, leave as is.
                else
					lastNonSingletonDimensions = arrayfun(@(v) find(size(v.(fieldName)) > 1, 1, 'last'), s(~charElements), 'uniformOutput', false);
                    maxDimension = max([lastNonSingletonDimensions{:}]);
                    for i = find(~charElements).'
						valueToFlatten = s(i).(fieldName);
						dimensions = arrayfun(@(d) size(valueToFlatten, d), 1:maxDimension);
						subscripts = ones(1, maxDimension);
						subscripts(1) = 0;	% So we can pre-increment.
						for m = 1:numel(valueToFlatten)
							% Increment the subscripts.
							for d = 1:maxDimension
								if subscripts(d) < dimensions(d)
									subscripts(d) = subscripts(d) + 1;
									break;
								end
								subscripts(d) = 1;	% Now increment the next one 
							end
							suffix = sprintf ('_%d', subscripts);
							s(i).([fieldName, suffix]) = valueToFlatten(m);
							s(i).(fieldName) = [];	% In case keep the field below.
						end
					end
					flattenedThisField = true;
				end	
			end
			
			if flattenedThisField
				if removeFieldIfFlattened
					s = rmfield(s, fieldName);
                    fprintf (1, 'Flattened and removed %s\n', fieldName);
                else
                    fprintf (1, 'Flattened %s\n', fieldName);
				end
				flattenedAny = true;
			end
		end
	end

	function flattenedAny = Decellerize
		flattenedAny = false;
		fields = fieldnames(s);
		for f = 1:length(fields)
            flattenedThisField = false;
			fieldName = fields{f};
			for i = 1:numel(s)
				valueToFlatten = s(i).(fieldName);
				if iscell(valueToFlatten)
					assert(numel(valueToFlatten) <= 1)	% Did arrays first to avoid this.
					if isempty(valueToFlatten)
						s(i).(fieldName) = [];
					else
						s(i).(fieldName) = valueToFlatten{1};
					end
                    flattenedThisField = true;
				end
            end
            if flattenedThisField
                fprintf (1, 'Decellerized %s\n', fieldName);
				flattenedAny = true;
            end
		end
	end
	
	function flattenedAny = FlattenSubstructs
		flattenedAny = false;
		fields = fieldnames(s);
		for f = 1:length(fields)
			fieldName = fields{f};
			flattenedThisField = false;
			anyNonStructInstances = false;
			for i = 1:numel(s)
				valueToFlatten = s(i).(fieldName);
				if isstruct(valueToFlatten)
					assert(numel(valueToFlatten) <= 1)	% Did arrays first to avoid this.
					flattenedThisField = true;
                    if ~isempty(valueToFlatten)
                        subFields = fieldnames(valueToFlatten);
                        for f2 = 1:length(subFields)
                            subField = subFields{f2};
                            subfieldValue = valueToFlatten.(subField);  % Fails strangely if substruct has no elements.
                            s(i).([fieldName, '_', subField]) = subfieldValue;
                        end
                    end
					s(i).(fieldName) = [];	% In case we keep the original field below.
				elseif ~isempty(valueToFlatten)
					anyNonStructInstances = true;
				end
			end
			if flattenedThisField
				if ~anyNonStructInstances
					s = rmfield(s, fieldName);
                    fprintf (1, 'Flattened and removed substruct %s\n', fieldName);
                else
                    fprintf (1, 'Flattened substruct %s\n', fieldName);
				end
				flattenedAny = true;
			end
		end
	end
end

