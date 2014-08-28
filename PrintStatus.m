function varargout = PrintStatus (testNum, numTests, startTic)
	testsRemaining = numTests - testNum;
	
	elapsedTime = toc(startTic);
	if testsRemaining == 0
		status = sprintf('100%% complete at %s after %s.', datestr(now), TimeIntervalString(elapsedTime));
	else
		secondsPerTest = elapsedTime/testNum;
		secondsRemaining = testsRemaining * secondsPerTest;
		estimatedCompletionTime = addtodate (now, round(1000*secondsRemaining), 'millisecond');
		status = sprintf('%g%% complete. Estimated completion is %s (%s from now).', ...
					100*testNum/numTests, datestr(estimatedCompletionTime), TimeIntervalString(secondsRemaining));
	end
	if nargout > 0
		varargout{1} = status;
	else
		fprintf (1, '%s\n', status)
		FlushDiary()
	end
end

