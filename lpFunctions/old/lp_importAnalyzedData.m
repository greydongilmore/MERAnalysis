function [D] = lp_importAnalyzedData(D, p, mainFolder)
%{
    The function lp_importAnalyzedData will read in the output files from
    Wave_Clus and store the data within the D structural array.

INPUT
    The function will import all the 'times_*.mat' files within the patient
    specific directory.

OUTPUT
    D.*Cluster {Subji x 1}{NxM}(n,1:2)
        Tis field provides the cluster class and timestamp for every spike
        in the raw recording.
        Double array where n indicates every spike that was detected, thus 
        the size of n will indicate how many spikes were detected in that 
        channel at that depth. The first column will indicate which cluster 
        class the spike belongs to, if there are any '0' in the first 
        column this indiates that the spike at that timepoint could not be 
        clustered. The second column indicates the timestamp of when the 
        spike occured in the recording. This double array is indexed for 
        each channel(N) at each depth(M) {NxM}. Each subject has their own 
        cluster field {Subji x 1}. 
    D.*Spikes {Subjix1}{NxM}(n by m)
        This field provides the raw data for every spike event in the raw
        file.
        Double array where n indicates the spike number and m is the number 
        of samples taken for each spike event. Thus the size of n will 
        indicate how many spikes were detected in that channel at that 
        depth. This double array is indexed for each channel(N) at each 
        depth(M) {NxM}. Each subject has their own spike field {Subji x 1}.  
    D.*Inspk {Subjix1}{NxM}(n by m)  
        This field provides the wavelet coefficients extracted for each 
        spike event.
        Double array where n indicates every spike that was detected and m 
        is the wavelet coefficients taken for each spike event. This double 
        array is indexed for each channel(N) at each depth(M) {NxM}. Each 
        subject has their own coefficient field {Subji x 1}. 
    D.*Ipermut {Subjix1}{NxM}(1 by m) 
        This field provides the order in which each spike was classified,
        as a control each spike was radomized prior to sorting.
        Double array where m is the order in which each spike was used 
        during the sorting process. This double array is 
        indexed for each channel(N) at each depth(M) {NxM}. Each subject 
        has their own permutation field {Subji x 1}. 
    D.*Forced {Subjix1}{NxM}(1 by m)
        This field indicates which spike events were forced into membership
        with other clusters if they were not clustered. 
        Double logical array where m indicates if the spike event was 
        forced into a cluster class. This double array is indexed for each 
        channel(N) at each depth(M) {NxM}. Each subject has their own 
        forced membership field {Subji x 1}. 
    D.*Parameters {Subjix1}{NxM}
        This field indicates the paramters that were used during the spike 
        detection and sorting. 
        Structural array that houses all the fields associated wiith the 
        setup paramters for Wave_Clus. This structral array is indexed for 
        each channel(N) at each depth(M) {NxM}. Each subject has their own 
        forced membership field {Subji x 1}. 
    D.*ChannelLabels {Subjix1}{NxM}(n by 1)  
        This field indicates which the channel had spike activity for all 
        the depths. 
        Double character array where n indicates the channel that had spike 
        activity present. This double character array is indexed for each 
        channel(N) at each depth(M) {NxM}. Each subject has their own 
        forced membership field {Subji x 1}. 
%}

% If cluster field exists then this function has already been executed for
% the current data. Also, if this is a current intraoperative patient then
% clustering has not yet been done. 
if ~isfield(D,'LeftCluster') || ~isfield(D,'RightCluster') || p.IntraoprativePatient == true
    
    cd ([mainFolder '\processed'])
    cnt    = 1;
        
    for subji = 1:size(D.SN,1)
        oldFolder  = cd([mainFolder '\processed\DBS-' num2str(D.SN(subji))]);
        filesLeft  = dir('times_Left*.mat');
        filesRight = dir('times_Right*.mat');
        
        %--- Determine depths and channels for Left side
        if isfield(D, 'LeftData')
            if size(D.LeftData{subji},2)> 2
                combinedLeft = zeros(size(filesLeft,1), 2);
                for fileLefti = 1:size(filesLeft,1)
                    file   = filesLeft(fileLefti).name;
                    a      = strsplit(file, '_');
                    b      = strsplit(a{2}, '-');
                    combinedLeft(fileLefti,1) = str2double(regexp(b{2},'[\d.]+','match'));
                    combinedLeft(fileLefti,2) = str2double(regexp(b{3},'[\d.]+','match'));
                end
                [X,Y]         = sort(combinedLeft(:,1),'ascend');
                combinedLeft  = combinedLeft(Y,:);
                numDepthsLeft = unique(X);
            end
        end
        %--- Determine depths and channels for Right side
        if isfield(D, 'RightData')
            if size(D.RightData{subji},2)> 2
                combinedRight = zeros(size(filesRight,1), 2);
                for fileRighti = 1:size(filesRight,1)
                    file   = filesRight(fileRighti).name;
                    a      = strsplit(file, '_');
                    b      = strsplit(a{2}, '-');
                    combinedRight(fileRighti,1) = str2double(regexp(b{2},'[\d.]+','match'));
                    combinedRight(fileRighti,2) = str2double(regexp(b{3},'[\d.]+','match'));
                end
                [X,Y]           = sort(combinedRight(:,1),'ascend');
                combinedRight  = combinedRight(Y,:);
                numDepthsRight = unique(X);
            end
        end
        
        %--- Extract and save data for Left side
        if isfield(D,'LeftData')
            if size(D.LeftData{subji},2)> 2
                disp('START: Importing left data from Wave_clus.')
                fprintf('\n')
                for depthi = 1:size(D.LeftDepths{subji},2)
                    numChans = combinedLeft(combinedLeft(:,1) == depthi, 2);
                    if size(numChans,1) ~=0
                        for chani = 1:size(numChans,1)
                            channel = numChans(chani);
                            file   = (['times_Left-Depth' num2str(depthi) '-chan' num2str(channel) '.mat']);
                            load(file)
                            D.LeftCluster{subji,1}{channel, depthi}       = cluster_class;
                            D.LeftSpikes{subji,1}{channel, depthi}        = spikes;
                            D.LeftInspk{subji,1}{channel, depthi}         = inspk;
                            D.LeftIpermut{subji,1}{channel, depthi}       = ipermut;
                            D.LeftForced{subji,1}{channel, depthi}        = forced;
                            D.LeftParameters{subji,1}{channel, depthi}    = par;
                            D.LeftChannelLabels{subji,1}{channel, depthi} = num2str(channel);

                        end
                        disp(['Left wave_clus data for subject ' , num2str(D.SN(subji)) , ' has been imported for depth: ' num2str(depthi)])
                    else
                        for chani = 1:size(D.LeftData{subji}{depthi},2)
                            D.LeftCluster{subji,1}{chani,depthi}       = [];
                            D.LeftSpikes{subji,1}{chani,depthi}        = [];
                            D.LeftInspk{subji,1}{chani,depthi}         = [];
                            D.LeftIpermut{subji,1}{chani,depthi}       = [];
                            D.LeftForced{subji,1}{chani,depthi}        = [];
                            D.LeftParameters{subji,1}{chani,depthi}    = [];
                            D.LeftChannelLabels{subji,1}{chani,depthi} = [];
                        end
                    end
                end
                fprintf('\n')
                disp(['DONE: Importing wave_clus Left side data for subject ' , num2str(D.SN(subji))])
                fprintf('\n')
            else
                D.LeftCluster{subji,1}       = {};
                D.LeftSpikes{subji,1}        = {};
                D.LeftInspk{subji,1}         = {};
                D.LeftIpermut{subji,1}       = {};
                D.LeftForced{subji,1}        = {};
                D.LeftParameters{subji,1}    = {};
                D.LeftChannelLabels{subji,1} = {};
            end
        else
            D.LeftCluster{subji,1}       = {};
            D.LeftSpikes{subji,1}        = {};
            D.LeftInspk{subji,1}         = {};
            D.LeftIpermut{subji,1}       = {};
            D.LeftForced{subji,1}        = {};
            D.LeftParameters{subji,1}    = {};
            D.LeftChannelLabels{subji,1} = {};
        end
        
        %--- Extract and save data for Right side
        if isfield(D,'RightData')
            if size(D.RightData{subji},2)> 2
                disp('START: Importing right data from Wave_clus.')
                fprintf('\n')
                for depthi = 1:size(D.RightDepths{subji},2)
                    numChans = combinedRight(combinedRight(:,1) == depthi, 2);
                    if size(numChans,1) ~= 0 
                        for chani = 1:size(numChans,1)
                            channel = numChans(chani);
                            file   = (['times_Right-Depth' num2str(depthi) '-chan' num2str(channel) '.mat']);
                            load(file)
                            D.RightCluster{subji,1}{channel, depthi}       = cluster_class;
                            D.RightSpikes{subji,1}{channel, depthi}        = spikes;
                            D.RightInspk{subji,1}{channel, depthi}         = inspk;
                            D.RightIpermut{subji,1}{channel, depthi}       = ipermut;
                            D.RightForced{subji,1}{channel, depthi}        = forced;
                            D.RightParameters{subji,1}{channel, depthi}    = par;
                            D.RightChannelLabels{subji,1}{channel, depthi} = num2str(channel);

                        end
                        disp(['Right wave_clus data for subject ' , num2str(D.SN(subji)) , ' has been imported for depth: ' num2str(depthi)])
                    else
                       for chani = 1:size(D.RightData{subji}{depthi},2)
                            D.RightCluster{subji,1}{chani,depthi}       = [];
                            D.RightSpikes{subji,1}{chani,depthi}        = [];
                            D.RightInspk{subji,1}{chani,depthi}         = [];
                            D.RightIpermut{subji,1}{chani,depthi}       = [];
                            D.RightForced{subji,1}{chani,depthi}        = [];
                            D.RightParameters{subji,1}{chani,depthi}    = [];
                            D.RightChannelLabels{subji,1}{chani,depthi} = [];
                        end
                    end
                end
                fprintf('\n')
                disp(['DONE: Importing wave_clus Right side data for subject ' , num2str(D.SN(subji))])
                fprintf('\n')
            else
                D.RightCluster{subji,1}       = {};
                D.RightSpikes{subji,1}        = {};
                D.RightInspk{subji,1}         = {};
                D.RightIpermut{subji,1}       = {};
                D.RightForced{subji,1}        = {};
                D.RightParameters{subji,1}    = {};
                D.RightChannelLabels{subji,1} = {};
            end
        else
            D.RightCluster{subji,1}       = {};
            D.RightSpikes{subji,1}        = {};
            D.RightInspk{subji,1}         = {};
            D.RightIpermut{subji,1}       = {};
            D.RightForced{subji,1}        = {};
            D.RightParameters{subji,1}    = {};
            D.RightChannelLabels{subji,1} = {};
        end
    end
    
    cd(mainFolder)
    disp('DONE: Importing wave_clus data for all subjects.')
    fprintf('\n')
else
    fprintf('\n')
    disp('Final data structure already loaded, skipping function lp_importAnalyzedData.')
    fprintf('\n')
end
end