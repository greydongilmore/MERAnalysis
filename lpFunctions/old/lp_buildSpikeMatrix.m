function [Data] = lp_buildSpikeMatrix(Data, p, mainFolder)
%{
    The function lp_buildSpikeMatrix takes the timestamps for all spike
    events and creates a binary array which is the same size as the raw
    file. All the data is converted into either '0' or '1', where '0'
    indicates no spike and '1' indicates a spike event.

INPUT

OUTPUT
    D.*spikeAPsM{subji,1}{chani, depthi} 
        This field houses the sparse binary matrix of spike events and its
        size is equal to the size of the raw data file (in sample numbers)
    D.*APsM{subji,1}{chani, depthi}  
        This field houses the sparse binary matrix of spike events and its
        size is converted into seconds based on the sampling freqency. 
    D.*nspikes{subji,1}{chani, depthi}{1 x M}  
        This field houses the number of spikes for each cluster class. M 
        is the number of spikes found at that depth in that channel for 
        the specific cluster.  
    D.*clusLabel{subji,1}{chani, depthi} {1 x M} 
        This field houses the cluster label for the spike events. M 
        is the number of unique clusters found at that depth in that channel. 
%}

if ~isfield(Data,'LeftAPsM') || ~isfield(Data,'RightAPsM') || p.IntraoprativePatient == true
    
    Fs = p.sr;
    cnt = 1;
    subjectCount = 0;
    for subji = 1:size(Data.SN,1)
        channelCount = 1;
        %--- Matrix for the left side
        if isfield(Data, 'LeftData')
            if size(Data.LeftData{subji},2)> 2
                fprintf('\n')
                disp(['START: Building left spike matrix for subject ' num2str(Data.SN(subji))])
                matrixSpike =[];
                matrix      =[];
                nspikes     =[];
                clusLabel   =[];
                index       = sum(cellfun(@isempty, Data.LeftChannelLabels{subji}),2); % Locate NaNs in all depths for subject
                rmvChan     = find(index > (size(Data.LeftDepths{subji},2) - 5)); % Remove channels with all NaNs or channels that only have 5 or more sites of recording
                
                for chani = 1:size(Data.LeftChannelLabels{subji},1)
                    for depthi = 1:size(Data.LeftDepths{subji},2)
%                         if ~ismember(chani, rmvChan)
                            cluster = Data.LeftCluster{subji}{chani,depthi};
                            if size(cluster,1) == 0
                                matrixSpike{cnt} = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)),'single');
                                matrix{cnt}      = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                nspikes          = {};
                                clusLabel        = {};
                            else
                                cluster(cluster(:,1)==0,:) = [];
                                if size(cluster,1) == 0
                                    matrixSpike{cnt} = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)),'single');
                                    matrix{cnt}      = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                    nspikes          = {};
                                    clusLabel        = {};
                                else
                                    clusterNumbers             = unique(cluster(:,1));
                                    for iclus = 1:size(clusterNumbers,1)
                                        if clusterNumbers(iclus) == 0 || isnan(clusterNumbers(iclus))
                                            matrixSpike{cnt} = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)),'single');
                                            matrix{cnt}      = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                            cnt              = cnt +1;
                                            
                                        else
                                            cluster                          = Data.LeftCluster{subji}{chani,depthi};
                                            data                             = Data.LeftData{subji}{depthi};
                                            
                                            %--- Matrix based on sampling rate
                                            t = (((cluster(cluster(:,1) == clusterNumbers(iclus),2))/1000)*Fs)'; % Spike times
                                            matrixSpike{clusterNumbers(iclus)} = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)),'single');
                                            matrixSpike{clusterNumbers(iclus)}(int64(t)) = 1;
                                            
                                            %--- Matrix based on time in milliseconds
                                            t = ((cluster(cluster(:,1) == clusterNumbers(iclus),2)))'; % Spike times
                                            matrix{clusterNumbers(iclus)} = zeros(1,floor(size(Data.LeftData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                            matrix{clusterNumbers(iclus)}(int64(t)) = 1;
                                            
                                            nspikes{clusterNumbers(iclus)}   = numel(t);
                                            clusLabel{clusterNumbers(iclus)} = clusterNumbers(iclus);
                                            
                                        end
                                    end
                                end
                            end
                            cnt                                      = 1;
                            Data.LeftspikeAPsM{subji,1}{channelCount, depthi} = matrixSpike; matrixSpike =[];
                            Data.LeftAPsM{subji,1}{channelCount, depthi}      = matrix;      matrix      =[];
                            Data.Leftnspikes{subji,1}{channelCount, depthi}   = nspikes;     nspikes     =[];
                            Data.LeftclusLabel{subji,1}{channelCount, depthi} = clusLabel;   clusLabel   =[];
%                         end
                    end
                   channelCount = channelCount + 1; 
                end
            disp(['DONE: Built left spike matrix for subject ' num2str(Data.SN(subji))])
            else
                Data.LeftspikeAPsM{subji,1} = {};
                Data.LeftAPsM{subji,1}      = {};
                Data.Leftnspikes{subji,1}   = {};
                Data.LeftclusLabel{subji,1} = {};
            end
        end
        
        %--- Matrix for the right side
        if isfield(Data, 'RightData')
            if size(Data.RightData{subji},2)> 1
                fprintf('\n')
                disp(['START: Building right spike matrix for subject ' num2str(Data.SN(subji))])
                matrixSpike =[];
                matrix      =[];
                nspikes     =[];
                clusLabel   =[];
                index       = sum(cellfun(@isempty, Data.RightChannelLabels{subji}),2); % Locate NaNs in all depths for subject
                rmvChan     = find(index > (size(Data.RightDepths{subji},2) - 5)); % Remove channels with all NaNs or channels that only have 5 or more sites of recording
                channelCount = 1;
                for chani = 1:size(Data.RightChannelLabels{subji},1)
                    for depthi = 1:size(Data.RightDepths{subji},2)
%                         if ~ismember(chani, rmvChan)
                            cluster                    = Data.RightCluster{subji}{chani,depthi};
                            if size(cluster,1) == 0
                                matrixSpike{cnt} = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)),'single');
                                matrix{cnt}      = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                nspikes          = {};
                                clusLabel        = {};
                            else
                                cluster(cluster(:,1)==0,:) = [];
                                if size(cluster,1) == 0
                                    matrixSpike{cnt} = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)),'single');
                                    matrix{cnt}      = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                    nspikes          = {};
                                    clusLabel        = {};
                                else
                                    clusterNumbers             = unique(cluster(:,1));
                                    for iclus = 1:size(clusterNumbers,1)
                                        if clusterNumbers(iclus) == 0 || isnan(clusterNumbers(iclus))
                                            matrixSpike{cnt} = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)),'single');
                                            matrix{cnt}      = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                            cnt              = cnt +1;
                                            
                                        else
                                            cluster                          = Data.RightCluster{subji}{chani,depthi};
                                            data                             = Data.RightData{subji}{depthi};
                                            
                                            %--- Matrix based on sampling rate
                                            t = (((cluster(cluster(:,1) == clusterNumbers(iclus),2))/1000)*Fs)'; % Spike times
                                            matrixSpike{clusterNumbers(iclus)} = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)),'single');
                                            matrixSpike{clusterNumbers(iclus)}(int64(t)) = 1;
                                            
                                            %--- Matrix based on time in milliseconds
                                            t = ((cluster(cluster(:,1) == clusterNumbers(iclus),2)))'; % Spike times
                                            matrix{clusterNumbers(iclus)} = zeros(1,floor(size(Data.RightData{subji}{depthi}(:,chani),1)/(Fs/1000)),'single');
                                            matrix{clusterNumbers(iclus)}(int64(t)) = 1;
                                            
                                            nspikes(clusterNumbers(iclus))   = numel(t);
                                            clusLabel(clusterNumbers(iclus)) = clusterNumbers(iclus);
                                            
                                        end
                                    end
                                end
                            end
                            cnt                                      = 1;
                            Data.RightspikeAPsM{subji,1}{chani, depthi} = matrixSpike; matrixSpike =[];
                            Data.RightAPsM{subji,1}{chani, depthi}      = matrix;      matrix      =[];
                            Data.Rightnspikes{subji,1}{chani, depthi}   = nspikes;     nspikes     =[];
                            Data.RightclusLabel{subji,1}{chani, depthi} = clusLabel;   clusLabel   =[];
%                         end
                    end
                    channelCount = channelCount + 1;     
                end
            disp(['DONE: Built right spike matrix for subject ' num2str(Data.SN(subji))])
            fprintf('\n')    
            else
                Data.RightspikeAPsM{subji,1} = {};
                Data.RightAPsM{subji,1}      = {};
                Data.Rightnspikes{subji,1}   = {};
                Data.RightclusLabel{subji,1} = {};
            end
        end
        cd(mainFolder)
        if p.SaveDataStructure == true
            subjectCount = subjectCount + 1;
            subjects(subjectCount) = Data.SN(subji);
            if subjectCount == 10 || subji == size(Data.SN,1)
                cd('clusterStructures')
                disp('Saving the final cluster structure...')
                D = getrow(Data , ismember(Data.SN , 0));
                for i = 1:length(subjects)
                    SN       = subjects(i);
                    D        = addstruct(D , getrow(Data , ismember(Data.SN , SN)));
                end
                save(['cluster', num2str(min(subjects)), 'To', num2str(max(subjects))], 'D' , '-v7.3');
                disp('DONE: Saved the final cluster structure.')
                cd(mainFolder)
                
                % Reset the counter
                subjectCount = 0;
                subjects     = [];
                clear D
            end
        end    
    end
    
   
else
    fprintf('\n')
    disp('Final data structure already has spike sparse matrix, skipping function lp_buildSpikeMatrix.')
    fprintf('\n')
end
end