function KillOtherMatlabs ()
	if ~ispc
		error ('horizon:impulse:notImplemented', '%s has not been implemented for this platform.', mfilename)
	end
	
	[status, tasklistCSV] = system('tasklist /FI "Windowtitle eq MATLAB Command Window" /FI "Imagename eq MATLAB.exe" /fo CSV /nh');
	
	if (status ~= 0)
		error ('horizon:impulse:tasklistFailed', 'tasklist failed with status %d', status);
	elseif isempty(tasklistCSV)
		warning ('horizon:impulse:noOtherMatlabs', 'There are no other MATLABs to kill');
    else
        tasklist = csv2cell(tasklistCSV);

		if numel(tasklist) == 1
			warning ('horizon:impulse:noOtherMatlabs', tasklist{1});
		else
			pids = cellfun(@(p) sprintf('/pid %s ', p), tasklist(:,2)', 'uniformOutput', false);
	
			system (['taskkill ', [pids{:}], '/f /t 2>&1']);
		end
    end
end
