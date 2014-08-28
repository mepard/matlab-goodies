function measurements = ReadLabviewData(filepath,wifiFrequencies,descriptor,channels,runs,scale)
    labviewFolder = 'C:\Users\john\Desktop\';
    if nargin < 1
        channels = 1;
    end
    if nargin < 2
        runs = 1;
    end
    if nargin < 3 || isempty(scale)
        scale = 0.050;
    end
    if isempty(wifiFrequencies)
        numFrequencies = 1;
    else
        numFrequencies = length(wifiFrequencies);
    end
    if ~isempty(filepath)
        labviewFile = filepath;
        fid = fopen(labviewFile);
        data = fread(fid,inf,'int16',0,'b');
        measurements = data * scale / 3200;
        return;
    else
        num = 1;
        evenOdd = 0;
        if isempty(wifiFrequencies)
            measurements = zeros(5000002,length(runs));
        else
            measurements = zeros(5000002,length(runs)*length(wifiFrequencies));
        end
        for l = 1:numFrequencies
            for m = channels
                for n = runs
                    if isempty(wifiFrequencies)
                        labviewFile = sprintf('%s%sChannel%dRun%2d.txt',labviewFolder,descriptor,channels(m),runs(n));
                    else
                        labviewFile = sprintf('%s%d%sChannel%dRun%2d.txt',labviewFolder,wifiFrequencies(l),descriptor,channels(m),runs(n));
                    end
                    fid = fopen(labviewFile);
                    data = fread(fid,inf,'int16',0,'b');
                    measurements(:,l*num) = measurements(:,l*num) + (-1)^evenOdd*data;
                    num = num + 1;
                end
                evenOdd = evenOdd + 1;
                num = 1;
            end
        end
        measurements = measurements*scale/3200;
    end
end
