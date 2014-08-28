function TestPhaseCorrection ()
	s = RandStream('mt19937ar');

	x = 0:pi/180:2*pi;
	
	tx = complex(sin(x), -cos(x));
	
	phaseErrors = -pi:pi/100:pi;
	gains = .1 + .9*abs(randn(s, size(phaseErrors)));
	
	corrections1 = nan(size(phaseErrors));
	corrections2 = nan(size(phaseErrors));
	for e = 1:length(phaseErrors)
		phaseError = phaseErrors(e);
		rxP = tx * exp(1i*phaseError);
		
		rx = rxP * gains(e);		%@@@ Add fuzz, too
		
		corrections1(e) = PhaseCorrection (tx, rx, false);
		corrections2(e) = PhaseCorrection (tx, rx, true);
		
		if false
			CascadeFigure(figure('name', sprintf('Correlations %g', 180*phaseError/pi)));
			plot(x*180/pi, angle(tx)*180/pi, 'g')
			hold on
			plot(x*180/pi, angle(rxP)*180/pi, 'b')
			plot(x*180/pi, angle(rx)*180/pi, 'r--')
			
			legend('Tx', 'Shifted', 'Attenuated')
		end
		if false
			rx1 = rx * exp(1i*corrections1(e));
			rx2 = rx * exp(1i*corrections2(e));
	
			rx = rx / gains(e);
			rx1 = rx1 / gains(e);
			rx2 = rx2 / gains(e);
			
			CascadeFigure(figure('name', sprintf('Phase Error %g', 180*phaseError/pi)));
			plot(x*180/pi, real(tx), 'g.')
			hold on
			plot(x*180/pi, imag(tx), 'y.')
			
			plot(x*180/pi, real(rx), 'm-')
			plot(x*180/pi, imag(rx), 'c-')
			
			plot(x*180/pi, real(rx1), 'r--')
			plot(x*180/pi, imag(rx1), 'b--')
	
			plot(x*180/pi, real(rx2), 'r:')
			plot(x*180/pi, imag(rx2), 'b:')
	
			legend({'Tx I', 'Tx Q', 'Rx I', 'Rx Q', 'C1 I', 'C1 Q', 'C2 I', 'C2 Q'}, 'location', 'best')
		end
	end
	if true
		CascadeFigure(figure('name', 'Phase Correction Error'));
		
		plot (phaseErrors*180/pi, (phaseErrors + corrections1)*180/pi, 'r.')
		hold on
		plot (phaseErrors*180/pi, (phaseErrors + corrections2)*180/pi, 'bo')
		
		xlabel('Phase Error in Degrees')
		ylabel('Correction Error in Degrees')
		
		legend('Quick', 'Robust')
		grid on, grid minor
		zoom on
	end
end
