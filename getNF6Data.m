function dat = getNF6Data(dat,fn6,varargin)
% add nf6 data to existing dat file
% optional inputs:
%   dsNF6- downsample factor (newFs = fs/dsNF6)

p = inputParser;
p.addOptional('nf6Epoch',[0 0],@isnumeric);
p.addOptional('dsNF6',nan, @isnumeric);
p.addOptional('filterFlag',false,@islogical);

p.parse(varargin{:});
nf6Epoch = p.Results.nf6Epoch;
dsNF6 = p.Results.dsNF6;
filterFlag = p.Results.filterFlag;

if ischar(fn6)
    nf6 = read_nsx(fn6);
else
    nf6 = fn6;
end

nf6Samp = double(nf6.hdr.Fs);
nchan = size(nf6.data,1);
nSamples = length(1:dsNF6:size(nf6.data,2));
% downsample
if ~isnan(dsNF6)
    nf6_ds = nan(nchan,nSamples);
    for n = 1:nchan
        nf6_ds(n,:) = decimate(double(nf6.data(n,:)), dsNF6);
    end
    nf6.data = nf6_ds;
    nf6Samp = nf6Samp/dsNF6;
end

% filter
if filterFlag
    % high pass
    [b,a] = butter(2,0.5/(nf6Samp/2),"high");

    % notch filter
    f0 = 60; bw = 8;  % Narrow notch
    notch = designfilt('bandstopiir', ...
        'FilterOrder', 2, ...
        'HalfPowerFrequency1', f0 - bw/2, ...
        'HalfPowerFrequency2', f0 + bw/2, ...
        'DesignMethod', 'butter', ...
        'SampleRate', nf6Samp);

    for n=1:nchan
        nf6.data(n,:) = filtfilt(b,a, nf6.data(n,:));
        nf6.data(n,:) = filtfilt(notch, nf6.data(n,:));
    end
end

fprintf('Found %d channels of NF6 data.\n',nchan);

for tind = 1:length(dat)
    epochStartTime = dat(tind).time(1) - nf6Epoch(1);
    epochEndTime = dat(tind).time(2) + nf6Epoch(2);
    nfEndTime = nSamples / nf6Samp;
    if epochStartTime < 0
        epochStartTime = 0;
    end
    if epochEndTime > nfEndTime
        epochEndTime = nfEndTime;
    end
    msec = dat(tind).trialcodes(:,3);
    codes = dat(tind).trialcodes(:,2);
    codesamples = round(msec*nf6Samp);

    nf6data.codesamples = [codes codesamples];
    nf6data.trial = nf6.data(:,round(epochStartTime*nf6Samp):round(epochEndTime*nf6Samp));

    nf6data.startsample = codesamples(1);
    nf6data.dataFs = nf6Samp;
    dat(tind).nf6 = nf6data;
    dat(tind).nfTime = (0:1:size(nf6data.trial,2)-1)./nf6Samp - nf6Epoch(1);

end
end
