function lp_waveClusUnsupervised(D, par, mainFolder)
%{
    The function lp_waveClusUnsupervised will extract the spike times for
    the Leadpoint data files, and perform spike sorting to provide a final
    output of individual spike units and their timing.

    The first function within this main function is 'Get_spikes', which 
    will perform spike detection on each raw file by using a standard 
    deviation threshold for both min and max spike amplitudes. These spike 
    locations will be stored in .mat files denoted by '*_spikes.mat'.
    The path for each '*_spikes.mat' file within the directory will be 
    saved to another textfile named 'clustering.txt'. 
    
    The second function within this main function is 'Do_clustering', which 
    will perform Wavelet convolution and supraparagmagnetic clustering on 
    the spike data. The output of this function are structural arrays for 
    each channel at each depth denoted by 'times_*.mat'. 

    The functions 'Get_spikes' and 'Do_clustering' are from Wave_Clus. 

INPUT
    The input is the TEXT file 'directories.txt' and all the .mat files for 
    all channels at all depths for each side fo the braint that was
    saved within the function lp_saveForCluster. 

OUTPUT
    The output file will be denoted by 'times_*.mat', which will hold all the
    information extracted by Wave_Clus. The most important being the spike
    times and the clusters associated with each spike time. These .mat
    files will be saved within the same directory.

Written by Greydon Gilmore ggilmore@uwo.ca June 2017

%}

% If cluster field exists then this function has already been executed for
% the current data. Also, if this is a current intraoperative patient then
% clustering has not yet been done. 
if ~isfield(D,'LeftCluster') || ~isfield(D,'RightCluster') || par.IntraoprativePatient == true
    
    %-------------------------------------------------------------------------%
    %                             Code Starts Here                            %
    %-------------------------------------------------------------------------%
    for subji = 1:size({D.SN},2) % Cycle through all subjects
        
        % Change to the directory that houses all the .mat files prepared for the
        % batch process of Wave_clus
        oldFolder = cd([mainFolder, '\processed\DBS-', num2str(D(subji).SN)]);
        B         = dir('*_spikes.mat');
        C         = dir('times_*.mat');
        
        % Need to remove any previous outputs from Wave_Clus prior to spiek
        % sorting again
        if size(B,1) > 1 || size(B,1) > 1
            fprintf('\n')
            disp(['Patient ' num2str(D(subji).SN) ' has previous output files from Wave_Clus, which will be removed....'])
            %--- Remove any spike .mat files
            for ifile = 1:size(B,1)
                delete(B(ifile).name);
            end
            
            %--- Remove any times .mat files
            for ifile = 1:size(C,1)
                delete(C(ifile).name);
            end
            
            %--- Remove the Wave_clus batch files from subject directory
            remove      = cellstr(ls ([mainFolder, '\batch_files'])); % Determine the files to be removed
            remove(1:2) = [];
            for ifile = 1:size(remove,1)
                [~,~,ext] = fileparts(remove{ifile}) ;
                if numel(ext) > 0
                    delete(remove{ifile});
                elseif numel(ext) == 0
                    rmdir(remove{ifile}, 's');
                end
            end
            disp(['Removed previous Wave_Clus files for patient ' num2str(D(subji).SN)])
            fprintf('\n')
        end
        
        if exist('directories.txt')
            
            % Need to copy the Wave_clus batch files to the working directory for
            % the patient.
            copyfile([mainFolder, '\batch_files'], [mainFolder, '\processed\DBS-', num2str(D(subji).SN)]);
            disp(['DONE: Copied batch files to patient ' num2str(D(subji).SN) ' folder.'])
            
            %--- Spike detection using Wave_clus
            disp(['START: Running spike detection for subject ' num2str(D(subji).SN)])
            fprintf('\n')
            
            Get_spikes([mainFolder, '\processed\DBS-', num2str(D(subji).SN), '\directories.txt'],'par', par, 'parallel',par.parallel);
            
            fprintf('\n')
            disp(['DONE: Finished spike detection for subject ' num2str(D(subji).SN)])
            fprintf('\n')
            
            %--- Save the *_spikes.mat files path to a text file for clustering
            B = dir('*_spikes.mat');
            
            for ispike = 1:size(B,1)
                clustering{ispike,1}  = B(ispike).name;
            end
            
            fileID = fopen('clustering.txt','wt');
            [nrows,~] = size(clustering);
            for rows = 1:nrows
                fprintf(fileID, '%s\n', clustering{rows,1});
            end
            fclose(fileID);
            clear clustering
            
            %--- Spike clustering using Wave_clus
            disp(['START: Running spike clustering for subject ' num2str(D(subji).SN)])
            fprintf('\n')
            
            Do_clustering([mainFolder, '\processed\DBS-', num2str(D(subji).SN), '\clustering.txt'],'parallel',par.parallel,'par',par,'make_plots',par.save_plots)
            
            fprintf('\n')
            disp(['DONE: Finished spike clustering for subject ' num2str(D(subji).SN)])
            
            %--- Remove the Wave_clus batch files from subject directory
            remove      = cellstr(ls ([mainFolder, '\batch_files'])); % Determine the files to be removed
            remove(1:2) = [];
            
            for ifile = 1:size(remove,1)
                [~,~,ext] = fileparts(remove{ifile}) ;
                if numel(ext) > 0
                    delete(remove{ifile});
                elseif numel(ext) == 0
                    rmdir(remove{ifile}, 's');
                end
            end
            fprintf('\n')
            disp(['DONE: Removed batch files from patient ' num2str(D(subji).SN) ' folder.'])
            fprintf('\n')
        end
    end
    
    % if a pool was open, close it
    if par.parallel == true
        if exist('matlabpool','file')
            matlabpool('close')
        else
            poolobj = gcp('nocreate');
            delete(poolobj);
        end
    end
    
    disp('DONE: Spike detection and Clustering.')
    fprintf('\n')
    cd(mainFolder)
else
    fprintf('\n')
    disp('Final data structure already loaded, skipping function lp_waveClusUnsupervised.')
    fprintf('\n')
end
end