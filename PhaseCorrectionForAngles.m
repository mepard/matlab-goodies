function correction = PhaseCorrectionForAngles (txAngles, rxAngles)
			
	step = pi/2;
	corrections = -pi:step:pi;
	tolerance = pi/(180*100);		% .01 degrees
	
	while true
		correction = BestOf (corrections);
		if step <= tolerance
			break
		end
		step = step/4;
		corrections = correction + step * (-2:2);
	end

	function phaseCorrection = BestOf (corrections)
		% We've tried several methods of doing this. Here are the rankings, empirically determined.
		% Check the hg history if you want to know the details or re-check any.
		%
		% 		Method																Ranking
		%	Add up abs values of phase differences, use minimum							1
		%	Correlate angles using FastCorrelation										2
		%	Combined correlation of IQ													3
		%	Count sign swaps, use minimum												4
		%	Correlate angles using circcorrcoef (doesn't seem to work at all)			5
		%
		phaseDifferences = nan(size(corrections));
	
		for c = 1:length(corrections)
			phaseDifferences(c) = FastAdjustedPhaseDifferences (rxAngles, corrections(c), txAngles);
		end
		[~, minPhaseDifferences] = min(phaseDifferences);
		
		phaseCorrection = corrections(minPhaseDifferences);
	
		if false
			CascadeFigure(figure('name', 'Phase Correction')); 
			hold on
			
			plot(corrections*180/pi, phaseDifferences, 'k.-')
			
			xlabel('Correction in Degrees')
			ylabel('Total Phase Differences')
			grid on, grid minor
			zoom on
		end
	end
end

