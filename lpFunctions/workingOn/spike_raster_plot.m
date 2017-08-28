function spike_raster_plot(New, mainFolder, p)

Fs          = p.sr;
channelindx = {'Center','Anterior','Posterior','Medial','Lateral'};

for subji = 1:size(New.SN,1)
if isfield (New, 'LeftData')
    
    % Plot for left side
    index          = sum(cellfun(@(C) strcmp(C,'NaN'), New.LeftChannelLabels{subji}),2);
    rmv_chan       = find(index > (size(New.LeftDepth{subji},2) - 5)); 
    num_chans_left = (size(New.LeftChannelLabels{subji},1)) - (size(rmv_chan,1));
    cnt            = 1;
    spike_mat      = [];
    for depthi = 1:size(New.LeftDepth{subji},2)

        y_min = min(New.LeftDepth{subji});
        y_max = max(New.LeftDepth{subji});
        
        for chani = 1:size(New.LeftChannelLabels{subji},1)        
            if size(New.LeftCluster{subji}{chani, depthi},2) == 0
                continue
            else
                if ~ismember(chani, rmv_chan)
                    clus_num = unique(New.LeftCluster{subji}{chani, depthi}(:,1));
                    if isnan(clus_num)


                    elseif clus_num == 0

                    else
                        use_clus = find(New.LeftCluster{subji}{chani, depthi}(:,1) == 1);
                        t        = (New.LeftCluster{subji}{chani, depthi}(use_clus,2))/1000; % Spike timings in the jjth trial
                        spike_mat{chani,1} = zeros(1,size(New.LeftData{subji}{depthi},1));
                        spike_mat{chani,1}(int64(t*Fs)) = 1;
                        nspikes  = numel(t); % number of elemebts / spikes
                        y_depth  = New.LeftDepth{subji}(depthi);

                        for spikesi = 1:nspikes % for every spike
                            figure (chani)
                            line([t(spikesi) t(spikesi)],[y_depth-0.25 y_depth+0.25],'Color','k'); % draw a black vertical line of length 1 at time t (x) and at trial jj (y)
                        end
                        figure (chani)
                        title(['Cluster 1: ' char(channelindx(chani))], 'FontSize', 11, 'FontWeight','bold');
                        xlabel('Time [sec]'); % Time is in millisecond
                        ylabel('Depth [mm]');
                        ylim([y_min y_max])
                        p = mtit(['Subject # ' num2str(cell2mat(New.SN(subji))) ' Left Side'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);

        %                 subplot(2,1,2)
        %                 plot (nspikes/
        %                 cnt     = cnt + 1;
        %                 p = mtit(['Subject # ' num2str(cell2mat(New.SN(subji))) ' Left Side'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);  
                    end
                cnt     = cnt + 1;
                end
            end
        end
        spike_matrix{depthi} = spike_mat;
        disp(['Finished processing left depth at ', num2str(depthi), ' of ', num2str(size(New.LeftDepth{subji},2))])
    end
else
    num_chans_left = 0;
end

if isfield (New, 'RightData')
% Plot for right side
index           = sum(cellfun(@(C) strcmp(C,'NaN'), New.RightChannelLabels{subji}),2);
rmv_chan        = find(index > (size(New.RightDepth{subji},2) - 5)); 
num_chans_right = (size(New.RightChannelLabels{subji},1)) - (size(rmv_chan,1));

for depthi = 1:size(New.RightDepth{subji},2)
    y_min = min(New.RightDepth{subji});
    y_max = max(New.RightDepth{subji});
    for chani = 1:size(New.RightChannelLabels{subji},1)       
        if ~ismember(chani, rmv_chan)           
            clus_num = unique(New.RightCluster{subji}{chani, depthi}(:,1));
            if isnan(clus_num)
               continue 
            elseif clus_num == 0
                continue
            else
                use_clus = find(New.RightCluster{subji}{chani, depthi}(:,1) == 1);
                t       = (New.RightCluster{subji}{chani, depthi}(use_clus,2))/1000; % Spike timings in the jjth trial
                nspikes = numel(t); % number of elemebts / spikes
                y_depth = New.RightDepth{subji}(depthi);
                for spikesi = 1:nspikes % for every spike
                    figure (num_chans_left + chani)
    %                 subplot(num_chans,1,cnt)
                    line([t(spikesi) t(spikesi)],[y_depth-0.25 y_depth+0.25],'Color','k'); % draw a black vertical line of length 1 at time t (x) and at trial jj (y)
                end
                figure (num_chans_left + chani)
                title(['Cluster 1: ' char(channelindx(chani))], 'FontSize', 11, 'FontWeight','bold');
                xlabel('Time [sec]'); % Time is in millisecond
                ylabel('Depth [mm]');
                ylim([y_min y_max])
                p = mtit(['Subject # ' num2str(cell2mat(New.SN(subji))) ' Right Side'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
            end
        end
        
    end
disp(['Finished processing right depth at ', num2str(depthi), ' of ', num2str(size(New.RightDepth{subji},2))])    
end
end
% Save all the figures here for each subject...


end
cd(mainFolder)
end