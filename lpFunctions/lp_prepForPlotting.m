function [plotting] = lp_prepForPlotting (D)

% downsampling to a smaller number of bins
plotting = [];
for subji = 1:size({D.SN},2)
    if isfield (D, 'LeftData')
        if size(D(subji).LeftData,2)> 2
            fprintf('\n')
            disp(['START: Preparing for plotting left spike matrix for subject ' num2str(D(subji).SN)])
            numPlotsLeft = 1;
            for chani = 1:size(D(subji).LeftChannelLabels,1)
                for depthi = 1:size(D(subji).LeftDepth,2)
                    for icluster = 1:size(D(subji).LeftAPsM{chani, depthi},1)
                        APsM = D(subji).LeftAPsM{chani, depthi}{icluster};
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
            plotting(subji).LeftSpPerbin = spPerbinLeftTemp;
            plotting(subji).LeftTimeBin  = timeBinLeftTemp;
            plotting(subji).LeftAPsM     = APsMLeftTemp;
            plotting(subji).LeftAPsMMean = APsMMeanLeftTemp;
            disp(['DONE: Prepared for plotting left spike matrix for subject ' num2str(D.SN(subji))])
            fprintf('\n')
            clear spPerbinLeftTemp timeBinLeftTemp APsMLeftTemp APsMMeanLeftTemp
        else
            plotting(subji).LeftSpPerbin = {};
            plotting(subji).LeftTimeBin  = {};
            plotting(subji).LeftAPsM     = {};
            plotting(subji).LeftAPsMMean = {};
        end
    end
    
    if isfield (D, 'RightData')
        if size(D(subji).RightData,2)> 2
            fprintf('\n')
            disp(['START: Preparing for plotting right spike matrix for subject ' num2str(D(subji).SN)])
            for chani = 1:size(D(subji).RightChannelLabels,1)
                for depthi = 1:size(D(subji).RightDepth,2)
                    if size(D(subji).RightAPsM{chani, depthi}, 1) ~= 0
                        for icluster = 1:size(D(subji).RightAPsM{chani, depthi}, 1)
                            APsM = D(subji).RightAPsM{chani, depthi}{icluster};
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
            plotting(subji).RightSpPerbin = spPerbinRightTemp;
            plotting(subji).RightTimeBin  = timeBinRightTemp;
            plotting(subji).RightAPsM     = APsMRightTemp;
            plotting(subji).RightAPsMMean = APsMMeanRightTemp;
            disp(['DONE: Prepared for plotting right spike matrix for subject ' num2str(D(subji).SN)])
            fprintf('\n')
            clear spPerbinRightTemp timeBinRightTemp APsMRightTemp APsMMeanRightTemp
        else
            plotting(subji).RightSpPerbin = {};
            plotting(subji).RightTimeBin  = {};
            plotting(subji).RightAPsM     = {};
            plotting(subji).RightAPsMMean = {};
        end
    end    
end
            
end

