function [plotting] = lp_prepForPlotting (D)

% downsampling to a smaller number of bins
plotting = [];
for subji = 1:size(D.SN,1)
    if isfield (D, 'LeftData')
        if size(D.LeftData{subji},2)> 2
            fprintf('\n')
            disp(['START: Preparing for plotting left spike matrix for subject ' num2str(D.SN(subji))])
            numPlotsLeft = 1;
            for chani = 1:size(D.LeftChannelLabels{subji},1)
                for depthi = 1:size(D.LeftDepths{subji},2)
                    for icluster = 1:size(D.LeftAPsM{subji}{chani, depthi},1)
                        APsM = D.LeftAPsM{subji}{chani, depthi}{icluster};
                        if size(APsM,2) > 1
                            npnts   = size(APsM,2);
                            timevec = 1:npnts;
                            bins    = ceil(timevec/10);
                            [spPerbin,timeBin] = deal( zeros(1,max(bins)) );

                            for i=1:length(spPerbin)
                                spPerbin(i) = mean(sum(APsM(:,bins==i),2) ,1);
                                timeBin(i)  = mean(timevec(bins==i));
                            end

                            spPerbinTemp(icluster,:) = spPerbin;
                            timeBinTemp(icluster,:)  = timeBin;
                            APsMTemp(icluster,:)     = APsM;
                            APsMFinalTemp(icluster,:)= mean(APsM);

                            clear spPerbin timeBin APsM
                        end    
                    
                    end
                    spPerbinLeft{depthi} = spPerbinTemp;
                    timeBinLeft{depthi}  = timeBinTemp;
                    APsMLeft{depthi}     = APsMTemp;
                    APsMMeanLeft{depthi} = APsMFinalTemp;   
                    
                    clear spPerbinTemp timeBinTemp APsMTemp APsMMeanTemp spikeRates
                end
                
                spPerbinLeftTemp(chani,:) = spPerbinLeft;
                timeBinLeftTemp(chani,:)  = timeBinLeft;
                APsMLeftTemp(chani,:)     = APsMLeft;
                APsMMeanLeftTemp(chani,:) = APsMMeanLeft;
                clear spPerbinLeft timeBinLeft APsMLeft APsMMeanLeft
            end
            plotting.LeftSpPerbin{subji,1} = spPerbinLeftTemp;
            plotting.LeftTimeBin{subji,1}  = timeBinLeftTemp;
            plotting.LeftAPsM{subji,1}     = APsMLeftTemp;
            plotting.LeftAPsMMean{subji,1} = APsMMeanLeftTemp;
            disp(['DONE: Prepared for plotting left spike matrix for subject ' num2str(D.SN(subji))])
            fprintf('\n')
            clear spPerbinLeftTemp timeBinLeftTemp APsMLeftTemp APsMMeanLeftTemp
        else
            plotting.LeftSpPerbin{subji,1} = {};
            plotting.LeftTimeBin{subji,1}  = {};
            plotting.LeftAPsM{subji,1}     = {};
            plotting.LeftAPsMMean{subji,1} = {};
        end
    end
    
    if isfield (D, 'RightData')
        if size(D.RightData{subji},2)> 2
            fprintf('\n')
            disp(['START: Preparing for plotting right spike matrix for subject ' num2str(D.SN(subji))])
            for chani = 1:size(D.RightChannelLabels{subji},1)
                for depthi = 1:size(D.RightDepths{subji},2)
                    if size(D.RightAPsM{subji}{chani, depthi}, 1) ~= 0
                        for icluster = 1:size(D.RightAPsM{subji}{chani, depthi}, 1)
                            APsM = D.RightAPsM{subji}{chani, depthi}{icluster};
                            if size(APsM,2) > 1
                                npnts   = size(APsM,2);
                                timevec = 1:npnts;
                                bins    = ceil(timevec/10);
                                [spPerbin,timeBin] = deal( zeros(1,max(bins)) );

                                for i=1:length(spPerbin)
                                    spPerbin(i) = mean(sum(APsM(:,bins==i),2) ,1);
                                    timeBin(i)  = mean(timevec(bins==i));
                                end

                                spPerbinTemp(icluster,:) = spPerbin;
                                timeBinTemp(icluster,:)  = timeBin;
                                APsMTemp(icluster,:)     = APsM;
                                APsMFinalTemp(icluster,:)= mean(APsM);

                                clear spPerbin timeBin APsM
                            end
                        end

                        spPerbinRight{depthi} = spPerbinTemp;
                        timeBinRight{depthi}  = timeBinTemp;
                        APsMRight{depthi}     = APsMTemp;
                        APsMMeanRight{depthi} = APsMFinalTemp;
                        clear spPerbinTemp timeBinTemp APsMTemp APsMMeanTemp
                    end
                end
                
                spPerbinRightTemp(chani,:) = spPerbinRight;
                timeBinRightTemp(chani,:)  = timeBinRight;
                APsMRightTemp(chani,:)     = APsMRight;
                APsMMeanRightTemp(chani,:) = APsMMeanRight;
                clear spPerbinRight timeBinRight APsMRight APsMMeanRight
            end
            plotting.RightSpPerbin{subji,1} = spPerbinRightTemp;
            plotting.RightTimeBin{subji,1}  = timeBinRightTemp;
            plotting.RightAPsM{subji,1}     = APsMRightTemp;
            plotting.RightAPsMMean{subji,1} = APsMMeanRightTemp;
            disp(['DONE: Prepared for plotting right spike matrix for subject ' num2str(D.SN(subji))])
            fprintf('\n')
            clear spPerbinRightTemp timeBinRightTemp APsMRightTemp APsMMeanRightTemp
        else
            plotting.RightSpPerbin{subji,1} = {};
            plotting.RightTimeBin{subji,1}  = {};
            plotting.RightAPsM{subji,1}     = {};
            plotting.RightAPsMMean{subji,1} = {};
        end
    end    
end
            
end

