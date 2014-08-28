function [values_out, probabilities_out] = ProbabilityDensityFunction (samples, sigmas, options)
 	if nargin < 2 || isempty(sigmas)
		sigmas = -10:.02:10;
 	end
 	if nargin < 3
 		options = {};
 	end
 	
 	inSigmas = any(strcmpi(options, 'sigma')) || any(strcmpi(options, 'sigmas'));
 	inOriginalUnits = any(strcmpi(options, 'samples')) || any(strcmpi(options, 'units'));
 	
 	byArea = any(strcmpi(options, 'area'));
 	byCounts = any(strcmpi(options, 'count')) || any(strcmpi(options, 'counts'));

 	if inSigmas && inOriginalUnits
 		error ('horizon:impulse:input', 'Choose only one of sigma or original')
 	end
 	if ~inSigmas && ~inOriginalUnits
 		inSigmas = true;	% Default to old behavior.
 	end
 	
 	if byArea && byCounts
 		error ('horizon:impulse:input', 'Choose only one of area or counts')
 	end
 	if ~byArea && ~byCounts
 		byArea = true;	% Default to old behavior.
 	end
 	
 	if inSigmas
		samples = samples / FastStd(samples);		% Convert to sigmas
		values = sigmas;
 	else
 		values = sigmas * FastStd(samples);			% Convert to original values
 	end
 	
 	if numel(values) == 1
		endPoint = max(abs(samples));
		values = linspace(-endPoint, endPoint, values);
 	end
	
	counts = hist(samples, values);
	
    % See http://stackoverflow.com/questions/5320677/how-to-normalize-a-histogram-in-matlab
    %
	if byArea
		probabilities = counts/trapz(values, counts);
	else
		probabilities = counts/sum(counts);
	end
   
	if nargout == 0
		plot (values, probabilities)
	else
		values_out = values;
		probabilities_out = probabilities;
	end
end
