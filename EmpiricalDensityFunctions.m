function [sigmas, cdf, pdf] = EmpiricalDensityFunctions (x, sigmasIn, options)
	if nargin < 2
		sigmasIn = [];
	end
	if nargin < 3
		options = {};
	end
	interpolate = any(strcmpi(options, 'interpolate'));
	discrete = any(strcmpi(options, 'discrete'));
	wantPDF = nargout > 2 || any(strcmpi(options, 'pdf'));
	interpolate = interpolate || ~isempty(sigmasIn) || (wantPDF && ~discrete);
	
	x = x(:);
	x = x/FastStd(x);

	if discrete
		[sigmas, pdf, probabilities] = DiscreteProbabilityDistribution (x, {'density'});
	else
		sigmas = sort(x);
		probabilities = (1:length(x)) / length(x);
	end
	
	if interpolate
		if isempty(sigmasIn)
			endPoint = max(abs(sigmas([1 end])));
			sigmasIn = linspace(-endPoint, endPoint, 101);
		elseif numel(sigmasIn) == 1
			endPoint = max(abs(sigmas([1 end])));
			sigmasIn = linspace(-endPoint, endPoint, sigmasIn);
		end
		
		if discrete
			pdf = IntegrateOverEachRange (sigmas, pdf, sigmasIn);
			sigmas = sigmasIn;
			cdf = cumtrapz(sigmas, pdf);
			cdf(cdf > 1) = 1;
		else
			%method = 'interfilter3';
			method = 'interp1';
			%method = '';
			if strcmpi(method, 'interfilter3')
				ds = mean(diff(sigmas));

				sigmasPadded = [sigmas(1) - (10:-1:1).'.*ds; ...
								sigmas; ...
								sigmas(end) + (1:10).'.*ds];
				probabilitiesPadded = [zeros(10, 1); probabilities; ones(10, 1)];
				[cdf, pdf] = interfilter3 (sigmasIn, probabilitiesPadded, sigmasPadded, .1);
				cdf(cdf > 1) = 1;
				cdf(cdf < 0) = 0;
				cdf(find(cdf == 1, 1, 'first'):end) = 1;
				cdf(1:find(cdf > 0, 1, 'first')-1) = 0;
		
				pdf(pdf < 0) = 0;
				pdf = pdf / trapz(sigmasIn, pdf);
			elseif strcmpi(method, 'interp1')
				cdf = interp1(sigmas, probabilities, sigmasIn, 'linear');

				endOfLeftTail = find(sigmasIn >= sigmas(1), 1, 'first')-1;
				startOfRightTail = find(sigmasIn > sigmas(end), 1, 'first');
				assert(all(isnan(cdf(1:endOfLeftTail))))
				assert(all(isnan(cdf(startOfRightTail:end))))
	
				cdf(1:endOfLeftTail) = 0;
				cdf(startOfRightTail:end) = 1;
				if wantPDF
					pdf = CDFtoPDF (sigmasIn, cdf);
				end
			else
				cdf = nan(size(sigmasIn));
				endOfLeftTail = find(sigmasIn >= sigmas(1), 1, 'first');
				cdf(1:endOfLeftTail-1) = 0;

				% Interpolate to find the probabilities at each sigmaIn.
				% interp1 producing a very ragged result when used all at once.
				% interfilter3 works okay and outputs the PDF (derivative), but the PDF has
				% negative values.
				%
				s = 1;
				for i = endOfLeftTail:length(sigmasIn)
					sigma = sigmasIn(i);
					s = s + find(sigmas(s:end) >= sigma, 1, 'first') - 1;
					if isempty(s)
						cdf(i:end) = 1;
						break;
					end
					if sigmas(s) == sigma
						cdf(i) = probabilities(s);
						continue
					end
					if s == 1
						cdf(i) = mean([0 probabilities(1)]);
						continue
					end
					cdf(i) = probabilities(s-1) + ((sigma - sigmas(s-1))/diff(sigmas(s-1:s))) * diff(probabilities(s-1:s));
				end
				if wantPDF
					pdf = CDFtoPDF (sigmasIn, cdf);
				end
			end

			sigmas = sigmasIn;
		end
	else
		cdf = probabilities;
	end
	if nargout == 1
		if wantPDF
			sigmas = pdf;
		else
			sigmas = cdf;
		end
	end
end

function new_pdf = IntegrateOverEachRange (sigmas, pdf, sigmasIn)
	new_pdf = nan(size(sigmasIn));
	sigmasIn = sigmasIn(:);
	boundaries = [-inf; (sigmasIn(2:end) + sigmasIn(1:end-1))/2; inf];
	for s = 1:length(boundaries)-1
		in_range = sigmas >= boundaries(s) & sigmas < boundaries(s+1);
		new_pdf(s) = sum(pdf(in_range));
	end
	new_pdf = new_pdf/trapz(sigmasIn, new_pdf);
end

function pdf = CDFtoPDF (sigmas, cdf)
    assert(all(size(sigmas) == size(cdf)))
	assert(cdf(end) == 1)
	assert(issorted(cdf))
	assert(all(abs(diff(sigmas) - mean(diff(sigmas))) <= 1e-11))	% We require even spacing.
    
    originalShape = size(sigmas);
    sigmas = sigmas(:);
    cdf = cdf(:);
    
	pdf = [0; diff(cdf)];
	pdf = pdf / trapz(sigmas, pdf);
    
    pdf = reshape(pdf, originalShape);
end
