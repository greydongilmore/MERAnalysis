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
    for subji = 1:size({Data.SN},2)
        channelCount = 1;
        %--- Matrix for the left side
        if isfield(Data, 'LeftData')
            if size(Data(subji).LeftData,2)> 2
                fprintf('\n')
                disp(['START: Building left spike matrix for subject ' num2str(Data(subji).SN)])
                matrixSpike =[];
                matrix      =[];
                nspikes     =[];
                clusLabel   =[];
                index       = sum(cellfun(@isempty, Data(subji).LeftChannelLabels),2); % Locate NaNs in all depths for subject
                rmvChan     = find(index > (size(Data(subji).LeftDepth,2) - 5)); % Remove channels with all NaNs or channels that only have 5 or more sites of recording
                
                for chani = 1:size(Data(subji).LeftChannelLabels,1)
                    % for each channel at each depth check if a cluster
                    % is present
                    for depthi = 1:size(Data(subji).LeftDepth,2)
                        cluster = Data(subji).LeftCluster{chani,depthi};
                        % for a depth that has no spikes present
                        if size(cluster,1) == 0
                            matrixSpike{cnt} = zeros(1,floor(size(Data(subji).LeftData{depthi}(:,chani),1)),'single');
                            matrix{cnt}      = zeros(1,floor(size(Data(subji).LeftData{depthi}(:,chani),1)/(Fs/1000)),'single');
                            nspikes          = {};
                            clusLabel        = {};
                        % if there are spikes present
                        else
                            % this condition will ensure any cluster 0's
                            % are removed and not analyzed
                            cluster(cluster(:,1)==0,:) = [];
                            % if only cluster 0 was present then the
                            % cluster size will now be zero and there are
                            % no clusters at this depth
                            if size(cluster,1) == 0
                                matrixSpike{cnt} = zeros(1,floor(size(Data(subji).LeftData{depthi}(:,chani),1)),'single');
                                matrix{cnt}      = zeros(1,floor(size(Data(subji).LeftData{depthi}(:,chani),1)/(Fs/1000)),'single');
                                nspikes          = {};
                                clusLabel        = {};
                            else
                                clusterNumbers = unique(cluster(:,1)); % this will hold all cluster numbers
                                for iclus = 1:size(clusterNumbers,1) % cycle through all clusters present
                                    cluster = Data(subji).LeftCluster{chani,depthi};
                                    data    = Data(subji).LeftData{depthi};

                                    %--- Matrix based on sampling rate
                                    t = (((cluster(cluster(:,1) == clusterNumbers(iclus),2))/1000)*Fs)'; % Spike times converted to sampling rate
                                    matrixSpike{clusterNumbers(iclus)} = zeros(1,floor(size(Data(subji).LeftData{depthi}(:,chani),1)),'single');
                                    matrixSpike{clusterNumbers(iclus)}(int64(t)) = 1; % Ones will appear wherever spike was detected

                                    %--- Matrix based on time in milliseconds
                                    t = ((cluster(cluster(:,1) == clusterNumbers(iclus),2)))'; % Spike times
                                    matrix{clusterNumbers(iclus)} = zeros(1,floor(size(Data(subji).LeftData{depthi}(:,chani),1)/(Fs/1000)),'single');
                                    matrix{clusterNumbers(iclus)}(int64(t)) = 1;
                                    nspikes{clusterNumbers(iclus)}   = numel(t);
                                    clusLabel{clusterNumbers(iclus)} = clusterNumbers(iclus);
                                end
                            end
                        end
                        cnt                                      = 1;
                        Data(subji).LeftspikeAPsM{channelCount, depthi} = matrixSpike; matrixSpike =[];
                        Data(subji).LeftAPsM{channelCount, depthi}      = matrix;      matrix      =[];
                        Data(subji).Leftnspikes{channelCount, depthi}   = nspikes;     nspikes     =[];
                        Data(subji).LeftclusLabel{channelCount, depthi} = clusLabel;   clusLabel   =[];
                        %                         end
                    end
                    channelCount = channelCount + 1;
                end
                disp(['DONE: Built left spike matrix for subject ' num2str(Data.SN(subji))])
            else
                Data(subji).LeftspikeAPsM = {};
                Data(subji).LeftAPsM      = {};
                Data(subji).Leftnspikes   = {};
                Data(subji).LeftclusLabel = {};
            end
        end
        
        %--- Matrix for the right side
        if isfield(Data, 'RightData')
            if size(Data(subji).RightData,2)> 1
                fprintf('\n')
                disp(['START: Building right spike matrix for subject ' num2str(Data(subji).SN)])
                matrixSpike =[];
                matrix      =[];
                nspikes     =[];
                clusLabel   =[];
                index       = sum(cellfun(@isempty, Data(subji).RightChannelLabels),2); % Locate NaNs in all depths for subject
                rmvChan     = find(index > (size(Data(subji).RightDepth,2) - 5)); % Remove channels with all NaNs or channels that only have 5 or more sites of recording
                channelCount = 1;
                for chani = 1:size(Data(subji).RightChannelLabels,1)
                    for depthi = 1:size(Data(subji).RightDepth,2)
                        % for each channel at each depth check if a cluster
                        % is present
                        cluster                    = Data(subji).RightCluster{chani,depthi};
                        % for a depth that has no spikes present
                        if size(cluster,1) == 0 
                            matrixSpike{cnt} = zeros(1,floor(size(Data(subji).RightData{depthi}(:,chani),1)),'single'); % will be all zeros
                            matrix{cnt}      = zeros(1,floor(size(Data(subji).RightData{depthi}(:,chani),1)/(Fs/1000)),'single'); % will be all zeros
                            nspikes          = sum(matrix{cnt}); % will be zero
                            clusLabel        = {}; % no clusters to will be left empty
                        % if there are spikes present
                        else
                            % this condition will ensure any cluster 0's
                            % are removed and not analyzed
                            cluster(cluster(:,1)==0,:) = [];
                            % if only cluster 0 was present then the
                            % cluster size will now be zero and there are
                            % no clusters at this depth
                            if size(cluster,1) == 0
                                matrixSpike{cnt} = zeros(1,floor(size(Data(subji).RightData{depthi}(:,chani),1)),'single');
                                matrix{cnt}      = zeros(1,floor(size(Data(subji).RightData{depthi}(:,chani),1)/(Fs/1000)),'single');
                                nspikes          = {};
                                clusLabel        = {};
                            else
                                clusterNumbers = unique(cluster(:,1)); % this will hold all cluster numbers
                                for iclus = 1:size(clusterNumbers,1) % cycle through all clusters present
                                    cluster = Data(subji).RightCluster{chani,depthi};
                                    data    = Data(subji).RightData{depthi};

                                    %--- Matrix based on sampling rate
                                    t = (((cluster(cluster(:,1) == clusterNumbers(iclus),2))/1000)*Fs)'; % Spike times converted to sampling rate
                                    matrixSpike{clusterNumbers(iclus)} = zeros(1,floor(size(Data(subji).RightData{depthi}(:,chani),1)),'single');
                                    matrixSpike{clusterNumbers(iclus)}(int64(t)) = 1; % Ones will appear wherever spike was detected

                                    %--- Matrix based on time in milliseconds
                                    t = ((cluster(cluster(:,1) == clusterNumbers(iclus),2)))'; % Spike times
                                    matrix{clusterNumbers(iclus)} = zeros(1,floor(size(Data(subji).RightData{depthi}(:,chani),1)/(Fs/1000)),'single');
                                    matrix{clusterNumbers(iclus)}(int64(t)) = 1;
                                    nspikes(clusterNumbers(iclus))   = numel(t);
                                    clusLabel(clusterNumbers(iclus)) = clusterNumbers(iclus); 
                                end
                            end
                        end
                        cnt                                      = 1;
                        % append the data to the structural array for each
                        % subject 
                        Data(subji).RightspikeAPsM{chani, depthi} = matrixSpike; matrixSpike =[];
                        Data(subji).RightAPsM{chani, depthi}      = matrix;      matrix      =[];
                        Data(subji).Rightnspikes{chani, depthi}   = nspikes;     nspikes     =[];
                        Data(subji).RightclusLabel{chani, depthi} = clusLabel;   clusLabel   =[];
                        %                         end
                    end
                    channelCount = channelCount + 1;
                end
                disp(['DONE: Built right spike matrix for subject ' num2str(Data(subji).SN)])
                fprintf('\n')
            else
                Data(subji).RightspikeAPsM = {};
                Data(subji).RightAPsM      = {};
                Data(subji).Rightnspikes   = {};
                Data(subji).RightclusLabel = {};
            end
        end
        cd(mainFolder)
        if p.SaveDataStructure == true
            subjectCount = subjectCount + 1;
            subjects(subjectCount) = Data(subji).SN;
            if subjectCount == 20 || subji == size({Data.SN},2)
                cd('clusterStructures')
                disp('Saving the final cluster structure...')
                D = Data(cell2mat({Data.SN})==subjects);
                if size(D,2) == 1
                    save(['clusterSubject', num2str(subjects)], 'D' , '-v7.3');
                else
                    save(['cluster', num2str(min(subjects)), 'To', num2str(max(subjects))], 'D' , '-v7.3');
                end
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