function [frequencyRange, name] = FrequencyBand (protocol, bandNum, ulOrDl)
	frequencyBands = {	'UMTS', 1, 'UL', 	[1920e6 1980e6]
						'UMTS', 1, 'DL', 	[2110e6 2170e6]
						'UMTS', 2, 'UL', 	[1850e6 1910e6]
						'UMTS', 2, 'DL', 	[1930e6 1990e6]
						'LTE',  1, 'UL',	[1920e6 1980e6]
						'LTE',  1, 'DL',	[2110e6 2170e6]
						'LTE',  2, 'UL',	[1850e6 1910e6]
						'LTE',  2, 'DL',	[1930e6 1990e6]	};
	
	protocolBands = strcmpi(frequencyBands(:,1), protocol);
	if ~any(protocolBands)
		error ('horizon:impulse:invalidArg', 'Protocol %s is unknown', protocol)
	end
	
	protocolBands = protocolBands & [frequencyBands{:,2}]' == bandNum;
	if ~any(protocolBands)
		error ('horizon:impulse:invalidArg', 'Protocol %s band %d is unknown', protocol, bandNum)
	end
	
	protocolBands = protocolBands & strcmpi(frequencyBands(:,3), ulOrDl);
	if ~any(protocolBands)
		error ('horizon:impulse:invalidArg', 'Protocol %s band %d %s is unknown', protocol, bandNum, ulOrDl)
	end
	
	protocolBand = find(protocolBands);
	if length(protocolBand) > 1
		error ('horizon:impulse:invalidArg', 'There is more than one %s band %d %s', protocol, bandNum, ulOrDl)
	end
	
	name = sprintf('%s band %d %s', frequencyBands{protocolBand,1}, frequencyBands{protocolBand,2}, frequencyBands{protocolBand,3});
	frequencyRange = frequencyBands{protocolBand,4};
end
