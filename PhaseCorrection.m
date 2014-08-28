function correction = PhaseCorrection (txSamples, rxSamples, robust)
	if nargin < 3 || isempty(robust)
		robust = true;
	end
	if robust
		correction = PhaseCorrectionForAngles (angle(txSamples), angle(rxSamples));
	else
		It = real(txSamples);
		Qt = imag(txSamples);
		
		Ir = real(rxSamples);
		Qr = imag(rxSamples);

		correction = atan2(sum(Qt.*Ir) - sum(It.*Qr), sum(It.*Ir) + sum(Qt.*Qr));
	end
	
end
