for subji = 1:size(D.SN,1) 
ndepths = numel(D.LeftDepths{subji}); % number of trials
fprintf('\nCounter: ')
for jj = 1:ndepths
    for ii = 1:size(D.LeftData{subji}{jj},2)
        index = find(D.LeftCluster{subji}{ii,jj}(:,1)==1);
        index(D.LeftForced{subji}{ii,jj}(1,:) == 1) = [];
        spk = D.LeftSpikes{subji}{ii,jj}(index,:);
        ymax = max(max(spk))+10;
        ymin = min(min(spk))-10;
        nspikes = size(spk,1); % number of elemebts / spikes
        figure (ii)
        for iii = 1:nspikes % for every spike
            subplot(2,1,1)
            plot(spk (iii,:),'Color','k') % draw a black vertical line of length 1 at time t (x) and at trial jj (y)
            hold on
        end
        xlabel('Samples'); % Time is in millisecond
        ylabel('Amplitude (\muV)');
        xlim([0 44])
        ylim([ymin ymax])
        mn = mean(spk,1);
        subplot(2,1,2)
        plot(mn)
        hold on
        plot(mn-std(spk))
        plot(mn+std(spk))
        xlabel('Samples'); % Time is in millisecond
        ylabel('Amplitude (\muV)');
        xlim([0 44])
        ylim([ymin ymax])
    end
end
end
%     end
%     if jj>1
%           for n = 0:log10(jj-1)
%               fprintf('\b'); % delete previous counter display
%           end
%     end
%     fprintf('%d', jj);
%     pause(.05); % allows time for display to update
% end
% fprintf('\n');
% 
% for ii = 1:subjectdata.num_trajectories
%     figure(ii)
%     subplot(2,2,1)
%     title('Go correct', 'FontSize', 11, 'FontWeight','bold');
%     xlabel('Samples'); % Time is in millisecond
%     ylabel('Amplitude (\muV)');
% 
%     figure(ii)
%     subplot(2,2,2)
%     title('Stop Correct', 'FontSize', 11, 'FontWeight','bold');
%     xlabel('Samples'); % Time is in millisecond
%     ylabel('Amplitude (\muV)');
% 
%     figure(ii)
%     subplot(2,2,3.5)
%     title('Stop Incorrect', 'FontSize', 11, 'FontWeight','bold');
%     xlabel('Samples'); % Time is in millisecond
%     ylabel('Amplitude (\muV)');
%     
%     p = mtit(['Electrode' num2str(ii)], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
% end
% end