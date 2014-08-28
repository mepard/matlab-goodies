function Y = PlotFFT (samples, samplesPerSecond, centerFrequency)

	numSamples = length(samples);                     % Length of signal
	
	numPoints = 2^nextpow2(numSamples); % Next power of 2 from length of samples
	Y = fft(samples,numPoints)/numSamples;
	Y = fftshift(Y);
	
	f = centerFrequency + samplesPerSecond/2*linspace(-1,1,numPoints);

	plot(f,2*abs(Y)) 
	hold on
	plot(centerFrequency + [0 0], ylim, 'r')
	title('Amplitude Spectrum of samples')
	xlabel('Frequency (Hz)')
	ylabel('|Y(f)|')

end
