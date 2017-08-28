function plottingSpikes(D, plotting, mainFolder)

ChannelLabels = {'Center', 'Anterior', 'Posterior', 'Medial', 'Lateral'};

for subji = 1:size({D.SN},2)
    if isfield (D, 'LeftData')
        if size(D(subji).LeftData,2)> 2
            numPlotsLeft = 1;
            cd([mainFolder '\processed' '\DBS-' num2str(D(subji).SN)]);
            if exist ('LeftSidePlots', 'dir')
                rmdir('LeftSidePlots','s');
            end
            mkdir (['LeftSidePlots'])
            newDir = [mainFolder '\processed' '\DBS-' num2str(D(subji).SN) '\LeftSidePlots'];
            for chani = 1:size(D(subji).LeftChannelLabels,1)
                for icluster = 1:size(D(subji).LeftclusLabel(chani,:),2)
                    clusterSize(icluster,:) = size(D(subji).LeftAPsM{chani,icluster},2);
                end
                for icluster = 1:min(clusterSize)
                    for depthi = 1:size(D(subji).LeftDepth,2)
                        
                        spPerbinFinal(icluster,:) = plotting(subji).LeftSpPerbin{chani, depthi}(icluster,:);
                        timeBinFinal(icluster,:)  = plotting(subji).LeftTimeBin{chani, depthi}(icluster,:);
                        APsMFinal(icluster,:)     = plotting(subji).LeftAPsM{chani, depthi}(icluster,:);
                        APsMFinalTemp(icluster,:) = plotting(subji).LeftAPsMMean{chani, depthi}(icluster,:);
                        
                        spPerbin(depthi,:) = spPerbinFinal;
                        timeBin(depthi,:)  = timeBinFinal;
                        APsM(depthi,:)     = APsMFinal;
                        APsMMean(depthi,:) = APsMFinalTemp;
                        
                        N             = size(D(subji).LeftData{depthi}(:,chani),1);
                        x             = D(subji).LeftData{depthi}(:,chani);
                        xf            = fft(x);
                        RMSTime(depthi,:)  = sqrt(x.^2);
                        RMSFreq(depthi,:)  = sqrt(abs(xf/N.^2));
                        RMSTotal(depthi,:) = RMSTime(depthi,:) - RMSFreq(depthi,:);
                        
                        clear spPerbinFinal timeBinFinal APsMFinal APsMFinalTemp
                    end
                    clear clusterSize
                    npnts   = size(APsM,2);
                    timevec = 1:npnts;
                    
                    %---------------------------------------------------------%
                    %         LEFT side - Raster and Firing Rate Plots        %
                    %---------------------------------------------------------%
                    figure(numPlotsLeft)
                    subplot(2,1,1)
                    imagesc(timevec,D(subji).LeftDepth,2-APsM)
                    xlabel('Time (ms)'), ylabel('Depth (mm)')
                    title(['Raster of Spike Events'])
                    
                    tidx       = dsearchn(timevec',[0 1000]');
                    dt         = timevec(tidx(2)-tidx(1)) / 1000;
                    spikeRates = sum(APsM(:,tidx(1):tidx(2)),2) / dt;
                    D(subji).LeftSpikeRate(chani,:) = spikeRates';

                    RMS     = RMSTotal;
                    npnts   = size(RMS,2);
                    timevec = 1:npnts;

                    subplot(2,1,2)
                    imagesc(timevec,D(subji).LeftDepth,RMS)
                    xlabel('Time (ms)'), ylabel('Depth (mm)')
                    title(['RMS Spike Events'])
                    p = mtit(['Subject ' num2str(D(subji).SN) ' Left Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                    graphTitle{numPlotsLeft,1} = ['Raster Left Channel ' num2str(chani)];
                    
                    %--- Plot Counter
                    numPlotsLeft = numPlotsLeft + 1;
                    
                    figure(numPlotsLeft)
                    subplot(2,1,1)
                    bar(D(subji).LeftDepth,spikeRates)
                    xlabel('Depth (mm)'), ylabel('Spike rate (sp/s)')
                    set(gca,'xlim',[D(subji).LeftDepth(1) D(subji).LeftDepth(end)])
                    title(['Spike Firing Rates'])
                    
                    summary = sum(RMS,2);
                    subplot(2,1,2)
                    bar(D(subji).LeftDepth,summary)
                    xlabel('Depth (mm)'), ylabel('Spike rate (sp/s)')
                    set(gca,'xlim',[D(subji).LeftDepth(1) D(subji).LeftDepth(end)])
                    hold on
                    plot(get(gca,'xlim'),[mean(summary) mean(summary)],'k')
                    hold off
                    p = mtit(['Subject ' num2str(D(subji).SN) ' Left Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                    graphTitle{numPlotsLeft,1} = ['Raster Left Channel ' num2str(chani)];

                    %--- Plot Counter
                    numPlotsLeft = numPlotsLeft + 1;
                    
                    %---------------------------------------------------------%
                    %                 LEFT side - 3D Depth Plot               %
                    %---------------------------------------------------------%
                    %--- Define z values                    
                    npnts3D   = size(APsM,2);
                    timevec3D = 1:npnts3D;
                    bins    = ceil(timevec3D/1000);
                    [spBin3D,tBin3D] = deal( zeros(1,max(bins)) );
                    
                    for j = 1:size(APsM,1)
                        for i3D=1:length(spBin3D)
                            spBin3D(i3D) = sum(APsM(j,bins==i3D),2);
                            tBin3D(i3D)  = mean(timevec3D==i3D);
                        end
                        spikeRT(j,:) = spBin3D;
                    end
                    zMat = spikeRT;
                    zValues = reshape(zMat,[1,size(zMat,1)*size(zMat,2)]);
                    zValues(zValues==0)=[];
                    zMin = min(zValues);
                    zMax = max(zValues);
                    
                    %--- Define y values
                    y    = D(subji).LeftDepth;
                                       
                    if size(zValues,2) ~=0
                        %--- Plot 3D Bar Graph
                        figure(numPlotsLeft)
                        width = .8;
                        b     = bar3(y,zMat);
                        colorbar
                        for k = 1:length(b)
                            zdata = b(k).ZData;
                            b(k).CData = zdata;
                            b(k).FaceColor = 'interp';
                        end
                        ylim([y(1),y(end)])
                        set(gca,'YTick',[y(1):y(end)])
                        %                         xlim([0,x(end)])
                        %                         set(gca,'XTick',[0:100:ceil(x(end))])
                        set(gca, 'CLim', [zMin zMax]);
                        view(-76,26)
                        xlabel('Time (ms)', 'FontWeight','bold'); ylabel('Depth (mm)', 'FontWeight','bold'); zlabel('Spike rate(spikes/sec)', 'FontWeight','bold');
                        title(['Spike Firing Rate'], 'FontSize', 14)
                        p = mtit(['Subject # ' num2str(D(subji).SN) ' Left Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                        graphTitle{numPlotsLeft,1} = ['SpikeFiringRateLeftChannel' num2str(chani)];
                        
                        %--- Plot Counter
                        numPlotsLeft = numPlotsLeft + 1;
                    end
                    
                    %---------------------------------------------------------%
                    %          LEFT side - InterSpike Interval Plot           %
                    %---------------------------------------------------------%
                    cnt = 1;
                    for i = 1:size(APsM,1)
                        ISIAPsM{i} = find(APsM(i,:) ==1)/1000;
                        sizing(i,1) = size(ISIAPsM{i},2);
                        if sizing(i,1) ~= 0
                            ISIData{cnt,1} = ISIAPsM{i};
                            cnt = cnt+1;
                        end
                    end
                    ISIIndex = find(sizing ~=0);
                    
                    if size(ISIIndex,1) == 0
                        clear ISIData
                        clear spPerbinFinal timeBinFinal APsM APsMMean ISIData spikeRates
                        continue
                    else
                        nrows    = size(ISIData,1);
                        if nrows > 4
                            split =1;
                        else
                            split =0;
                        end
                        
                        clear ISIAPsM sizing
                        cnt           = 1;
                        plotCount     = 1;
                        positionCount = 1;
                        figurePart    = 1;
                        subRows       = 4;
                        for iISI = 1:size(ISIData,1)
                            depth   = D(subji).LeftDepth(ISIIndex(iISI,1));
                            ISIsLow = diff(ISIData{iISI});
                            bins    = (0:0.001:.5);	%Define the bins for the histogram.
                            
                            if split ==1
                                if iISI <= 4 * plotCount
                                    numPlotsLeft  = numPlotsLeft;
                                    posi          = positionCount;
                                    positionCount = positionCount +1;
                                else
                                    numPlotsLeft  = numPlotsLeft + cnt;
                                    positionCount = 1;
                                    posi          = positionCount;
                                    plotCount     = plotCount + 1;
                                    positionCount = positionCount +1;
%                                     checkDiff      = (size(ISIData,1) - iISI);
%                                     if checkDiff < 4
%                                         subRows = checkDiff + 1;
%                                     end
                                end
                                
                                figure(numPlotsLeft)
                                subplot(subRows,1,posi)
                                hist(ISIsLow, bins)		%Plot the histogram of the ISI data,
                                xlim([0 0.25])			%... focus on ISIs from 0 to 150 ms,
                                xlabel('ISI [s]')		%... label the x-axis,
                                ylabel('Counts')		%... and the y-axis.
                                title([num2str(depth) ' mm from target.'])
                                if posi == 4 || iISI == size(ISIData,1)
                                    p = mtit(['Subject # ' num2str(D(subji).SN) ' Left Side: ' ChannelLabels{chani} ' Trajectory:' ' Part ' num2str(figurePart)], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                                    graphTitle{numPlotsLeft,1} = ['ISI Left Channel ' num2str(chani) 'Part' num2str(figurePart)];
                                    figurePart = figurePart + 1;
                                end
                            else
                                figure(numPlotsLeft)
                                subplot(nrows,1,iISI)
                                hist(ISIsLow, bins)		%Plot the histogram of the ISI data,
                                xlim([0 0.25])			%... focus on ISIs from 0 to 150 ms,
                                xlabel('ISI [s]')		%... label the x-axis,
                                ylabel('Counts')		%... and the y-axis.
                                title([num2str(depth) ' mm from target.'])
                                if iISI == size(ISIData,1)
                                    p = mtit(['Subject # ' num2str(D(subji).SN) ' Left Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                                    graphTitle{numPlotsLeft,1} = ['ISI Left Channel ' num2str(chani)];
                                end
                            end
                        end
                        numPlotsLeft = numPlotsLeft +1;
                    end
                    clear spPerbin timeBin APsM APsMMean ISIData spikeRates clusterSize
                end
            end
            clear spPerbin timeBin APsM APsMMean ISIData spikeRates clusterSize
            %-------------------------------------------------------------%
            %                  LEFT side - Save All Plots                 %
            %-------------------------------------------------------------%
            counting = 0;
            matlab.graphics.internal.setPrintPreferences('DefaultPaperPositionMode','manual');
            for i = 1:size(graphTitle,1)
                threeDIndex  = startsWith(graphTitle{i,1}, 'SpikeFiring');
                if threeDIndex
                    fileName   = strcat([newDir,'\'], graphTitle{i,1},'.fig');
                    fig_number = i + counting;
                    h          = figure (fig_number);
                    savefig(h,fileName)
                else
                    fileName   = strcat ([newDir,'\'], graphTitle{i,1}, '.png');
                    fig_number = i + counting;
                    h          = figure (fig_number);
                    print (h, '-dpng', fileName);
                end
            end
            clear graphTitle
            close all
            
        end
    else
        numPlotsLeft = 1;
    end
    
    %---------------------------------------------------------------------%
    %                          Right Side Plotting                        %
    %---------------------------------------------------------------------%
    if isfield (D, 'RightData')
        if size(D(subji).RightData,2)> 2
            numPlotsRight = 1;
            cd([mainFolder '\processed' '\DBS-' num2str(D(subji).SN)]);
            if exist ('RightSidePlots', 'dir')
                rmdir('RightSidePlots','s');
            end
            mkdir (['RightSidePlots'])
            newDir = [mainFolder '\processed' '\DBS-' num2str(D(subji).SN) '\RightSidePlots'];
            for chani = 1:size(D(subji).RightChannelLabels,1)
                for icluster = 1:size(D(subji).RightclusLabel(chani,:),2)
                    clusterSize(icluster,:) = size(D(subji).RightAPsM{chani,icluster},2);
                end
                for icluster = 1:min(clusterSize)
                    for depthi = 1:size(D(subji).RightDepth,2)
%                         if icluster == clusterSize(depthi)
                            spPerbinFinal(icluster,:) = plotting(subji).RightSpPerbin{chani, depthi}(icluster,:);
                            timeBinFinal(icluster,:)  = plotting(subji).RightTimeBin{chani,depthi}(icluster,:);
                            APsMFinal(icluster,:)     = plotting(subji).RightAPsM{chani, depthi}(icluster,:);
                            APsMFinalTemp(icluster,:) = plotting(subji).RightAPsMMean{chani, depthi}(icluster,:);
%                         else
%                             continue
%                         end
                        spPerbin(depthi,:) = spPerbinFinal;
                        timeBin(depthi,:)  = timeBinFinal;
                        APsM(depthi,:)     = APsMFinal;
                        APsMMean(depthi,:) = APsMFinalTemp;
                        
                        N             = size(D(subji).RightData{depthi}(:,chani),1);
                        x             = D(subji).RightData{depthi}(:,chani);
                        xf            = fft(x);
                        RMSTime(depthi,:)  = sqrt(x.^2);
                        RMSFreq(depthi,:)  = sqrt(abs(xf/N.^2));
                        RMSTotal(depthi,:) = RMSTime(depthi,:) - RMSFreq(depthi,:);
                        
                        clear spPerbinFinal timeBinFinal APsMFinal APsMFinalTemp 
                    end
                    clear clusterSize
                    npnts   = size(APsM,2);
                    timevec = 1:npnts;
                    
                    %---------------------------------------------------------%
                    %         Right side - Raster and Firing Rate Plots       %
                    %---------------------------------------------------------%
                    figure(numPlotsRight)
                    subplot(2,1,1)
                    imagesc(timevec,D(subji).RightDepth,2-APsM)
                    xlabel('Time (ms)'), ylabel('Depth (mm)')
                    title(['Raster of Spike Events'])
                    
                    RMS     = RMSTime;
                    npnts   = size(RMS,2);
                    timevec = 1:npnts;

                    subplot(2,1,2)
                    imagesc(timevec,D(subji).RightDepth,RMS)
                    xlabel('Time (ms)'), ylabel('Depth (mm)')
                    title(['RMS Spike Events'])
                    p = mtit(['Subject ' num2str(D(subji).SN) ' Right Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                    graphTitle{numPlotsRight,1} = ['Raster Right Channel ' num2str(chani)];
                    
                    %--- Plot Counter
                    numPlotsRight = numPlotsRight + 1;
                    
                    tidx       = dsearchn(timevec',[0 1000]');
                    dt         = timevec(tidx(2)-tidx(1)) / 1000;
                    spikeRates = sum(APsM(:,tidx(1):tidx(2)),2) / dt;
                    D(subji).RightSpikeRate(chani,:) = spikeRates';
                    
                    figure(numPlotsRight)
                    subplot(2,1,1)
                    bar(D(subji).RightDepth,spikeRates)
                    xlabel('Depth (mm)'), ylabel('Spike rate (sp/s)')
                    set(gca,'xlim',[D(subji).RightDepth(1) D(subji).RightDepth(end)])
                    title(['Spike Firing Rates'])
                    
                    summary = sum(RMS,2);
                    subplot(2,1,2)
                    bar(D(subji).RightDepth,summary)
                    hold on
                    plot(get(gca,'xlim'),[mean(summary) mean(summary)],'k')
                    hold off
                    set(gca,'xlim',[D(subji).RightDepth(1) D(subji).RightDepth(end)])
                    xlabel('Depth (mm)'), ylabel('Spike rate (sp/s)')
                    p = mtit(['Subject ' num2str(D(subji).SN) ' Right Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                    graphTitle{numPlotsRight,1} = ['Raster Right Channel ' num2str(chani)];

                    %--- Plot Counter
                    numPlotsRight = numPlotsRight + 1;
                    
                    %---------------------------------------------------------%
                    %                 Right side - 3D Depth Plots             %
                    %---------------------------------------------------------%
                   
                    %--- Define z values                    
                    npnts3D   = size(APsM,2);
                    timevec3D = 1:npnts3D;
                    bins    = ceil(timevec3D/1000);
                    [spBin3D,tBin3D] = deal( zeros(1,max(bins)) );
                    
                    for j = 1:size(APsM,1)
                        for i=1:length(spBin3D)
                            spBin3D(i) = sum(APsM(j,bins==i),2);
                            tBin3D(i)  = mean(timevec3D==i);
                        end
                        spikeRT(j,:) = spBin3D;
                    end
                    zMat = spikeRT;
                    zValues = reshape(zMat,[1,size(zMat,1)*size(zMat,2)]);
                    zValues(zValues==0)=[];
                    zMin = min(zValues);
                    zMax = max(zValues);
                    
                    %--- Define y values
                    y    = D(subji).RightDepth;
                                       
                    if size(zValues,2) ~=0
                        %--- Plot 3D Bar Graph
                        figure(numPlotsRight)
                        width = .8;
                        b     = bar3(y,zMat);
                        colorbar
                        for k = 1:length(b)
                            zdata = b(k).ZData;
                            b(k).CData = zdata;
                            b(k).FaceColor = 'interp';
                        end
                        ylim([y(1),y(end)])
                        set(gca,'YTick',[y(1):y(end)])
                        %                         xlim([0,x(end)])
                        %                         set(gca,'XTick',[0:100:ceil(x(end))])
                        set(gca, 'CLim', [zMin zMax]);
                        view(-76,26)
                        xlabel('Time (ms)', 'FontWeight','bold'); ylabel('Depth (mm)', 'FontWeight','bold'); zlabel('Spike rate(spikes/sec)', 'FontWeight','bold');
                        title(['Spike Firing Rate'], 'FontSize', 14)
                        p = mtit(['Subject # ' num2str(D(subji).SN) ' Right Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                        graphTitle{numPlotsRight,1} = ['SpikeFiringRateRightChannel' num2str(chani)];
                        
                        %--- Plot Counter
                        numPlotsRight = numPlotsRight + 1;
                    end
                    %---------------------------------------------------------%
                    %          Right side - InterSpike Interval Plot          %
                    %---------------------------------------------------------%
                    cnt = 1;
                    for i = 1:size(APsM,1)
                        ISIAPsM{i} = find(APsM(i,:) ==1)/1000;
                        sizing(i,1) = size(ISIAPsM{i},2);
                        if sizing(i,1) ~= 0
                            ISIData{cnt,1} = ISIAPsM{i};
                            cnt = cnt+1;
                        end
                    end
                    ISIIndex = find(sizing ~=0);
                    
                    if size(ISIIndex,1) == 0
                        clear ISIData
                        clear spPerbinFinal timeBinFinal APsM APsMMean ISIData spikeRates
                        continue
                    else
                        nrows    = size(ISIData,1);
                        if nrows > 4
                            split =1;
                        else
                            split =0;
                        end
                        
                        clear ISIAPsM sizing
                        cnt           = 1;
                        plotCount     = 1;
                        positionCount = 1;
                        figurePart    = 1;
                        subRows       = 4;
                        for iISI = 1:size(ISIData,1)
                            depth   = D(subji).RightDepth(ISIIndex(iISI,1));
                            ISIsLow = diff(ISIData{iISI});
                            bins    = (0:0.001:.5);	%Define the bins for the histogram.
                            
                            if split ==1
                                if iISI <= 4 * plotCount
                                    numPlotsRight  = numPlotsRight;
                                    posi           = positionCount;
                                    positionCount  = positionCount +1;
                                else
                                    numPlotsRight  = numPlotsRight + cnt;
                                    positionCount  = 1;
                                    posi           = positionCount;
                                    plotCount      = plotCount + 1;
                                    positionCount  = positionCount +1;
%                                     checkDiff      = (size(ISIData,1) - iISI);
%                                     if checkDiff < 4
%                                         subRows = checkDiff + 1;
%                                     end
                                end
                                
                                figure(numPlotsRight)
                                subplot(subRows,1,posi)
                                hist(ISIsLow, bins)		%Plot the histogram of the ISI data,
                                xlim([0 0.25])			%... focus on ISIs from 0 to 150 ms,
                                xlabel('ISI [s]')		%... label the x-axis,
                                ylabel('Counts')		%... and the y-axis.
                                title([num2str(depth) ' mm from target.'])
                                if posi == 4 || iISI == size(ISIData,1)
                                    p = mtit(['Subject # ' num2str(D(subji).SN) ' Right Side: ' ChannelLabels{chani} ' Trajectory:' ' Part ' num2str(figurePart)], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                                    graphTitle{numPlotsRight,1} = ['ISIRightChannel' num2str(chani) 'Part' num2str(figurePart)];
                                    figurePart = figurePart + 1;
                                end
                                
                                
                            else
                                figure(numPlotsRight)
                                subplot(nrows,1,iISI)
                                hist(ISIsLow, bins)		%Plot the histogram of the ISI data,
                                xlim([0 0.25])			%... focus on ISIs from 0 to 150 ms,
                                xlabel('ISI [s]')		%... label the x-axis,
                                ylabel('Counts')		%... and the y-axis.
                                title([num2str(depth) ' mm from target.'])
                                if iISI == size(ISIData,1)
                                    p = mtit(['Subject # ' num2str(D(subji).SN) ' Right Side: ' ChannelLabels{chani} ' Trajectory'], 'FontSize', 14, 'FontWeight','bold', 'xoff',0,'yoff',.025);
                                    graphTitle{numPlotsRight,1} = ['ISIRightChannel' num2str(chani)];
                                end
                                
                            end
                            
                        end
                        numPlotsRight = numPlotsRight +1;
                        
                    end
                   clear spPerbin timeBin APsM APsMMean ISIData spikeRates clusterSize
                end
            end
            clear spPerbin timeBin APsM APsMMean ISIData spikeRates clusterSize
            %-------------------------------------------------------------%
            %                  Right side - Save All Plots                %
            %-------------------------------------------------------------%
            counting = 0;
            matlab.graphics.internal.setPrintPreferences('DefaultPaperPositionMode','manual');
            for i = 1:size(graphTitle,1)
                threeDIndex  = startsWith(graphTitle{i,1}, 'SpikeFiring');
                if threeDIndex
                    fileName   = strcat([newDir,'\'], graphTitle{i,1},'.fig');
                    fig_number = i + counting;
                    h          = figure (fig_number);
                    savefig(h,fileName)
                else
                    fileName   = strcat ([newDir,'\'], graphTitle{i,1}, '.png');
                    fig_number = i + counting;
                    h          = figure (fig_number);
                    print (h, '-dpng', fileName);
                end
            end
            
            clear graphTitle
            close all
        end
    end
    numPlotsLeft  = 1;
    numPlotsRight = 1;
end
end

