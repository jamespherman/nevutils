function dat = nf62dat(dat,filename,varargin)
p = inputParser;
p.addOptional('readNF6',true, @islogical);
p.addOptional('nf6data', struct([]), @isstruct);
p.addOptional('dsNF6',1, @isnumeric);
p.addOptional('nf6Epoch',[0 0], @isnumeric);
p.addOptional('filterFlag',false,@islogical);

p.parse(varargin{:});
readNF6 = p.Results.readNF6;
nf6data = p.Results.nf6data;
dsNF6 = p.Results.dsNF6;
nf6Epoch = p.Results.nf6Epoch;
filterFlag = p.Results.filterFlag; % filter with a high pass and 60 hz notch

if readNF6
    if ~isempty(nf6data)
        fn6 = nf6data;
        dat = getNF6Data(dat,fn6,'nf6Epoch',nf6Epoch,'dsNF6',dsNF6,'filterFlag',filterFlag);
    else
        fn6 = filename;
        if ~exist(fn6,'file')
            fprintf('nf6 file does not exist!\n');
        else
            dat = getNF6Data(dat,fn6,'nf6Epoch',nf6Epoch,'dsNF6',dsNF6,'filterFlag',filterFlag);
        end
    end
end
