function x = ResampleRate (x, currentSampleRate, newSampleRate)
	if currentSampleRate ~= newSampleRate
		reduceBy = gcd (currentSampleRate, newSampleRate);
		currentSampleRate = currentSampleRate/reduceBy;
		newSampleRate = newSampleRate/reduceBy;
		x = resample (x, newSampleRate, currentSampleRate);
	end
end
