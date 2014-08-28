function ConfigureAxes (ax, xlimit, ylimit, options)
	if nargin < 2
		xlimit = [];
	end
	if nargin < 3
		ylimit = [];
	end
	if nargin < 4
		options = {};
	end
	addLimitTicksBoth = any(strcmpi(options, 'addLimitTicks'));
	addLimitTicksX = addLimitTicksBoth || any(strcmpi(options, 'addLimitTicksX'));
	addLimitTicksY = addLimitTicksBoth || any(strcmpi(options, 'addLimitTicksY'));
	xlimitOption = ExtractLimitVector (options, 'xlim');
	ylimitOption = ExtractLimitVector (options, 'ylim');
	minorBoth = any(strcmpi(options, 'MinorGrid'));
	minorX = minorBoth || any(strcmpi(options, 'XMinorGrid'));
	minorY = minorBoth || any(strcmpi(options, 'YMinorGrid'));
	
	if ~isempty(xlimitOption)
		xlimit = xlimitOption;
	end
	if ~isempty(ylimitOption)
		ylimit = ylimitOption;
	end
	
	if length(xlimit) == 2 && diff(xlimit) > 0
		set(ax, 'xlim', xlimit);
	end
	if length(ylimit) == 2 && diff(ylimit) > 0
		set(ax, 'ylim', ylimit);
	end
	
	if addLimitTicksX
		AddLimitTicks (ax, 'x')
	end
	if addLimitTicksY
		AddLimitTicks (ax, 'y')
	end
	
	if minorX
		set(ax, 'XMinorGrid', 'on')
	end
	if minorY
		set(ax, 'YMinorGrid', 'on')
	end
end

function limitVector = ExtractLimitVector (options, optionName)
	limitOption = find(strcmpi(options, optionName), 1, 'last');
	if isempty(limitOption)
		limitVector = [];
	else
		if limitOption >= length(options)
			error ('horizon:impulse:missingOptionValue', '%s option must be followed by 2-element range vector', optionName)
		end
		limitVector = options{limitOption+1};
		if ~isnumeric(limitVector) || length(limitVector) ~= 2
			error ('horizon:impulse:missingOptionValue', '%s option must be followed by 2-element range vector', optionName)
		end
	end
end

function AddLimitTicks (ax, xOrY)
	limits = get(ax, [xOrY, 'lim']);
	ticks = get(ax, [xOrY, 'tick']);
	while limits(1) < ticks(1)
		ticks = [ticks(1) - diff(ticks([1 2])), ticks];
	end
	while limits(end) > ticks(end)
		ticks = [ticks, ticks(end) + diff(ticks([end-1 end]))];
	end
	set (ax, [xOrY, 'tick'], ticks)
	set (ax, [xOrY, 'lim'], ticks([1 end]))
end
