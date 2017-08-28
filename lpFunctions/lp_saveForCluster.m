function lp_saveForCluster(mainFolder, p, D)
%{
    The function lp_saveForCluster will save the spike data for batch
    cluster processing into seperate .mat files for every channel at every
    depth. The files will be saved within a patient specific directory
    within the directory 'processed'.
INPUT
    This function will cycle through all channels and depths for the
    subject for each side of the brain.

OUTPUT
    A .mat file will be saved that houses the raw spike data for every
    channel for every depth for each side of the brain.
    
    A textfile will be written that indicates the full path for each .mat
    file and will be saved as 'directories.txt'. This textfile will be used
    by Wave_Clus during the detection process of spike sorting.

    All of these files will be saved in the .\processed directory.
%}

% If cluster field exists then this function has already been executed for
% the current data. Also, if this is a current intraoperative patient then
% clustering has not yet been done.
if ~isfield(D,'LeftCluster') || ~isfield(D,'RightCluster') || p.IntraoprativePatient == true
    cd(mainFolder)
    starting = now;
    
    for subji = 1:size({D.SN},2)
        if ~exist([mainFolder '\processed'],'dir')
            mkdir([mainFolder '\processed'])
        end
        oldFolder = cd([mainFolder '\processed']);
        
        % If a folder exists for the subject within 'processed' it will be
        % removed prior to further analysis to avoid duplicate data.
        if exist (['DBS-' num2str(D(subji).SN)],'dir')
            fprintf('\n')
            disp (['START: Removing cluster files from subject ' num2str(D(subji).SN) ' processed directory.'])
            cd(['DBS-' num2str(D(subji).SN)]);
            files = dir;
            files(1:2) = [];
            filenames = {files.name};            
            for i = 1:numel(filenames)
                fn = filenames{i};
                [num, ~] = find(fn == ['_']);
                if num == 1
                    delete (fn)
                end
            end            
            if exist ('clustering.txt','file')
                delete ('clustering.txt')
            end
            if exist ('LeftSidePlots','dir')
                rmdir('LeftSidePlots','s')
            end
            if exist ('RightSidePlots','dir')
                rmdir('RightSidePlots','s')
            end
            disp (['DONE: Removed cluster files from subject ' num2str(D(subji).SN) ' processed directory.'])
            fprintf('\n')
        else
            
            mkdir(['DBS-' num2str(D(subji).SN)]);
            cd(['DBS-' num2str(D(subji).SN)])
            cnt       = 1;
            
            %--- Left side data saving
            if  isfield(D, 'LeftData')% If the Left side contains data this condition will be met
                if size(D(subji).LeftData,2) ~=0
                    fprintf('\n')
                    disp(['START: Saving left raw spike data into .mat files  for subject ' , num2str(D(subji).SN)])
                    fprintf('\n')
                    for depthi = 1:size(D(subji).LeftData,2)
                        if depthi == 1 || D(subji).LeftDepth(depthi) ~= D(subji).LeftDepth(depthi-1)
                            depthRepeatCnt = 0;
                        else
                            depthRepeatCnt = depthRepeatCnt + 1; % Keep track of how many times a specific depth is repeated
                        end
                        if depthRepeatCnt == 0
                            for chani = 1:size(D(subji).LeftData{depthi},2)
                                data = D(subji).LeftData{depthi}(:,chani)';
                                save(['Left-Depth' num2str(depthi) '-chan' num2str(chani) '.mat'], 'data')
                                directories{cnt,1} = [pwd '\Left-Depth' num2str(depthi) '-chan' num2str(chani) '.mat'];
                                cnt                = cnt +1;
                                clear data
                            end
                        elseif depthRepeatCnt > 0
                            for chani = 1:size(D(subji).LeftData{depthi},2)
                                data = D(subji).LeftData{depthi}(:,chani)';
                                save(['Left-Depth' num2str(depthi) '-chan' num2str(chani) 'pt' num2str(depthRepeatCnt + 1) '.mat'], 'data')
                                directories{cnt,1} = [pwd '\Left-Depth' num2str(depthi) '-chan' num2str(chani) 'pt' num2str(depthRepeatCnt + 1) '.mat'];
                                cnt                = cnt +1;
                                clear data
                            end
                        end
                        disp(['Finished saving left raw spike data to .mat files for subject ' num2str(D(subji).SN) ' at depth: ' , num2str(D(subji).LeftDepth(depthi))])
                        cd([mainFolder '\processed' '\DBS-' num2str(D(subji).SN)])
                    end
                end
            end
            depthRepeatCnt = 0;
            depth_corr    = 0;
            
            %--- Right side data saving
            if isfield(D, 'RightData')
                if size(D(subji).RightData,2) ~=0
                    fprintf('\n')
                    disp(['START: Saving right raw spike data into .mat files  for subject ' , num2str(D(subji).SN)])
                    fprintf('\n')
                    for depthi = 1:size(D(subji).RightData,2)
                        if depthi == 1 || D(subji).RightDepth(depthi) ~= D(subji).RightDepth(depthi-1)
                            depthRepeatCnt = 0;
                            depth_corr    = 0;
                        else
                            depthRepeatCnt = depthRepeatCnt + 1;
                            depth_corr    = depthi - depthRepeatCnt;
                        end
                        
                        if depthRepeatCnt == 0
                            for chani = 1:size(D(subji).RightData{depthi},2)
                                data = D(subji).RightData{depthi}(:,chani)';
                                save(['Right-Depth' num2str(depthi) '-chan' num2str(chani) '.mat'], 'data')
                                directories{cnt,1} = [pwd '\Right-Depth' num2str(depthi) '-chan' num2str(chani) '.mat'];
                                cnt                = cnt +1;
                                clear data
                            end
                        elseif depthRepeatCnt > 0
                            for chani = 1:size(D(subji).RightData{depthi},2)
                                data = D(subji).RightData{depthi}(:,chani)';
                                save(['Right-Depth' num2str(depth_corr) '-chan' num2str(chani) 'pt' num2str(depthRepeatCnt + 1) '.mat'], 'data')
                                directories{cnt,1} = [pwd '\Right-Depth' num2str(depth_corr) '-chan' num2str(chani) 'pt' num2str(depthRepeatCnt + 1) '.mat'];
                                cnt                = cnt +1;
                                clear data
                            end
                        end
                        clear right_chan*
                        disp(['Finished saving right raw spike data to .mat files for subject ' num2str(D(subji).SN) ' at depth: ' , num2str(D(subji).RightDepth(depthi))])
                        cd([mainFolder '\processed' '\DBS-' num2str(D(subji).SN)])
                    end
                end
            end
            cnt       = 1;
            
            fileID    = fopen('directories.txt','wt');
            [nrows,~] = size(directories);
            for rows = 1:nrows
                fprintf(fileID, '%s\n', directories{rows,1});
            end
            fclose(fileID);
            clear directories
            
            fclose('all')
            cd(oldFolder)
        end
    end
    
    ending = now;
    total  = num2str(second(ending - starting));
    fprintf('\n')
    disp (['DONE: Finished saving all subject data for clustering in ' total ' seconds.'])
    fprintf('\n')
    cd(mainFolder)
else
    fprintf('\n')
    disp('Final data structure has cluster data already, skipping function lp_saveForCluster.')
    fprintf('\n')
end
end

