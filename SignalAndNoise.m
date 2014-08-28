function [signalPower, noisePower, snr] = SignalAndNoise (tx, rx)
	% Scale tx for the best correlation between tx and rx.
	% Assumes rx has already been synchronized and phase-corrected.
	%
	R = mean(rx .* conj(tx)) - mean(rx)*conj(mean(tx));
	tx = tx * R/FastVar(tx);
	
	signalPower = FastVar(tx);
	noisePower = FastVar(rx - tx);
	snr = signalPower / noisePower;
end

