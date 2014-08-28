function s = ToString (varargin)
	s = '';
	for a = 1:length(varargin)
		argValue = varargin{a};

		if size(argValue,3) > 1
			error ('Horizon:impulse:notSupported', 'ToString does not support arrays with more than two dimensions.')
		end

		if ischar(argValue)
			if size(argValue,1) > 1
				error ('Horizon:impulse:notSupported', 'ToString does not support multiple rows in char arrays.')
			end
			argString = ['''', argValue, ''''];
		elseif iscell(argValue)
			argString = ['{', ArrayToString(argValue), '}'];
		elseif isstruct(argValue)
			if numel(argValue) > 1
				argString = ['[', ArrayToString(argValue), ']'];
			else
				argString = 'struct(';
				fields = fieldnames(argValue);
				for f = 1:length(fields)
					if f > 1
						argString = [argString, ','];
					end
					fieldValue = argValue.(fields{f});
					valueString = ToString(fieldValue);
					if iscell(fieldValue)
						valueString = ['{',valueString,'}'];	% Otherwise struct creates a struct for ever cell array element.
					end
					argString = [argString, ToString(fields{f}), ',', valueString];
				end
				argString = [argString, ')'];
			end
		elseif isnumeric(argValue) || islogical(argValue)
			sizeString = [DoubleToString(size(argValue,1)), ',', DoubleToString(size(argValue,2))];
			if isempty(argValue)
				argString = '[]';
			elseif numel(argValue) == 1
				argString = DoubleToString(argValue);
			elseif all(isnan(argValue(:)))
				argString = ['nan(', sizeString, ')'];
			elseif all(argValue(:) == argValue(1,1,1))
				theValue = argValue(1,1,1);
				if theValue == 0
					argString = ['zeros(', sizeString, ')'];
				elseif theValue == 1
					argString = ['ones(', sizeString, ')'];
				else
					argString = ['repmat(', DoubleToString(theValue), ',', sizeString, ')'];
				end
			else
				if size(argValue,1) == 1
					numColumns = size(argValue,2);
					dv = unique(diff(argValue));					
					if numColumns > 3 && ~any(isnan(argValue)) && length(dv) == 1
						assert(dv ~= 0)	% Should have been handled above
						assert(all(argValue(1):dv:argValue(end) == argValue))
						if dv == 1
							argString = sprintf('%s:%s', DoubleToString(argValue(1)), DoubleToString(argValue(end)));
						else
							argString = sprintf('%s:%s:%s', DoubleToString(argValue(1)), DoubleToString(dv), DoubleToString(argValue(end)));
						end
					else
						argString = ['[', ArrayToString(argValue), ']'];
					end
				else
					argString = ['[', ArrayToString(argValue), ']'];
				end
			end
			% Make sure we got it right.
			%
			evalValues = eval(argString);
			 assert(isempty(evalValues) == isempty(argValue) || all(size(evalValues) == size(argValue)))

			argValue = argValue(:);
			evalValues = evalValues(:);
			nanValues = isnan(argValue);
			assert(all(isnan(evalValues) == nanValues))
			if any(~nanValues)
				argValue = argValue(~nanValues);
				evalValues = evalValues(~nanValues);
				assert(all(isinf(argValue) | abs(evalValues - double(argValue)) <= eps(evalValues)))
            end
        elseif isa(argValue, 'function_handle')
            argString = func2str(argValue);
		else
			error ('Horizon:impulse:notSupported', 'ToString does not type %s.', class(argValue))
		end
		if a > 1
			s = [s, ',']; %#ok<*AGROW>
		end
		s = [s, argString];
	end
end

function argString = ArrayToString (argValue)
	numRows = size(argValue,1);
	numColumns = size(argValue,2);
	argString = '';
	for r = 1:numRows
		if r > 1
			argString = [argString,';'];
		end
		for c = 1:numColumns
			if c > 1
				argString = [argString,' '];
			end
			if iscell(argValue)
				argString = [argString, ToString(argValue{r,c})];
			else
				argString = [argString, ToString(argValue(r,c))];
			end
		end
	end
end

function s = DoubleToString (d)
	% Converts d to string such that no precision is lost when converting it back to a double.
	% Works on arrays, but does not preserve their shapes.
	%
	% According to http://en.wikipedia.org/wiki/IEEE_754-2008
	%
	% The original binary value will be preserved by converting to decimal and back again using:
	%	17 decimal digits for binary64
	%
	s = num2str(d, 17);
	
	% Remove leading and trailing white space
	%
	s = strtrim(s);
end
