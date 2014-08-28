function samples = GenerateTone (cyclesPerSecond, samplesPerSecond, numSeconds, options)
	if nargin < 4
		options = {};
	end
	
	complexTone = any(strcmpi(options, 'complex'));
	integralWavelengths = any(strcmpi(options, 'wavelengths'));
	
	samplesPerWavelength = samplesPerSecond/cyclesPerSecond;

	numSamples = numSeconds*samplesPerSecond;
	if integralWavelengths
		remainder = rem(numSamples, samplesPerWavelength);
		if remainder ~= 0
			numSamples = numSamples + samplesPerWavelength - remainder;
		end
	end
	samples = sin(2*pi*(0:numSamples-1)/samplesPerWavelength);
	
	if complexTone
		samples = hilbert(samples);
	end
end
