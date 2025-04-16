function [oxy_trialstartinds] = getTrialMarkersOxy(nirs_data,nmarkers, varargin)
% extract trial markers for NIRS data. Trial markers are sent to the oxymon
%      - nirs_data: structure output of oxy2mat conversion
%      - nmarkers: expected number of trial markers
%

p = inputParser;
p.addOptional('datFile', [], @isstruct);
p.parse(varargin{:});
dat = p.Results.datFile;

% **************************************************************************** %
%                     Using Oxymon AD values for trial markers                 %
% **************************************************************************** %
% there are two oxymon box devices in the smithlab 10315 and 10343, try these numbers
marker_chan = find(strcmp(nirs_data.ADlabel,['Oxymon AdChannels_0_id_' num2str(10315)])); % channel w/ trial markers
if isempty(marker_chan)
    marker_chan = find(strcmp(nirs_data.ADlabel,['Oxymon AdChannels_0_id_' num2str(10343)])); % channel w/ trial markers
end

if ~isempty(marker_chan)
    oxypulse = nirs_data.ADvalues(:,marker_chan);
    oxypulse = oxypulse>0.5; % analog signal, turn the data into binary 0s and 1s
    [~,oxy_trialstartinds] = findpeaks(diff(oxypulse),'MinPeakHeight',0.5);

    %check that there are no missing trial starts
    if length(oxy_trialstartinds)~=nmarkers
        if ~isempty(dat) % try to debug missing markers
            % try to see if there's a simple explanation (such as extra
            % markers at the end of the file and accomadate for it)

            % plot first 10 and last 10 oxytrial markers and dat trial
            % markers to see if there are extra markers
            nevTrialTimes = [dat(:).time]; nevTrialTimes = nevTrialTimes(1:2:end);
            debugFig = figure;
            subplot(2,1,1); xline((oxy_trialstartinds(1:10)-oxy_trialstartinds(1))/nirs_data.Fs,'k'); hold on; title('first 10 trials')
            xline(nevTrialTimes(1:10)-nevTrialTimes(1),'r');
            subplot(2,1,2); h1 =xline((oxy_trialstartinds(end-9:end)-oxy_trialstartinds(1))/nirs_data.Fs,'k'); hold on; title('last 10 trials'); xlabel('time (s)')
            h2=xline(nevTrialTimes(end-9:end)-nevTrialTimes(1),'r'); legend([h1(1),h2(2)],{'nirs','nev'});

            % ask user
            if length(oxy_trialstartinds)> nmarkers % extra nirs markers
                nmissing = length(oxy_trialstartinds) - nmarkers;
                x = input(['Are there ', num2str(nmissing), ' extra NIRS markers at the end of the file? Y/N']);
                if strcmp(x,'Y')
                    oxy_trialstartinds = oxy_trialstartinds(1:end-nmissing);
                else
                    error(['# of trial markers in oxymon data (' num2str(length(oxy_trialstartinds)), ')'...
                        ' does not match NEV (' num2str(nmarkers) ').']);
                end
            else
                nmissing = nmarkers - length(oxy_trialstartinds);
                x = input(['Are there ', num2str(nmissing), ' extra NEV markers at the end of the file? Y/N']);
                if strcmp(x,'Y')
                    dat = dat(1:end-nmissing); % remove extra trials from dat
                else
                    error(['# of trial markers in oxymon data (' num2str(length(oxy_trialstartinds)), ')'...
                        ' does not match NEV (' num2str(nmarkers) ').']);
                end
            end
            close(debugFig);

        else
            error(['# of trial markers in oxymon data (' num2str(length(oxy_trialstartinds)), ')'...
                ' does not match NEV (' num2str(nmarkers) ').']);
        end

    else % check whether there are TMSI markers avialable
        warning('Oxymon AdChannel 0 not found, trying EEG digi channel on TMSI...');
        marker_chan = find(strcmp(nirs_data.ADlabel,'EEG: Digi')); % channel w/ trial markers
        if ~isempty(marker_chan)
            tmsipulse = nirs_data.ADvalues(:,marker_chan); % note: cleaner analog signal than oxymon pulses
            count = 1;
            while tmsipulse(count)==0 % first point for AD values is an arbitrary 0 (assign to 255 so it doesn't effect peak finding)
                tmsipulse(count) = 255;
                count = count + 1;
            end
            [~,oxy_trialstartinds] = findpeaks(diff(-1*tmsipulse)); % tmsi signal is a negative pulse (255 baseline, pulse drops signal below baseline)

            %check that there are no missing trial starts
            if length(oxy_trialstartinds)~=nmarkers
                error(['# of trial markers in tmsi data (' num2str(length(oxy_trialstartinds)), ')'...
                    ' does not match NEV (' num2str(nmarkers) ').']);
            end

        else
            error('Oxymon AdChannel 0 not found...');
        end
    end



end