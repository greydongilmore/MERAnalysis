function [New, p] = lp_extractLeadpointFiles(mainFolder, DataFolder, p)
%{
    The function lp_extractLeadpointFiles will import all the Leadpoint
    files from the allData directory. This function will loop through all
    the patient folders within the directory and import the data at each
    depth for every recording channel. Each file name is used to extract
    the depth and study number for each subject. The study number will
    indicate which side of the brain the files are from and the depth
    information will indicate the position on te Z-plane within the brain.
    The Leadpoint files code the left side files with either '19' or '25'
    and the right side files with either '20' or '26'. 

INPUT
    This function will cycle through all the directories within the allData
    folder and import the raw .txt files for each subject. The input
    assumes that every .txt file within a subject direcory houses all
    recorded channels. The Leadpoint Export Utility lets you either save
    all recorded channels to the same file or a seperate file for each
    channel. This function assumes you saved all channels within the same
    .txt file at each depth. 

OUTPUT
    There are two output fields for each recorded side...

    New.*data   = {1xn}, where n is the number of depths taken on the MER
    New.*depths = {1xn}, where n is the number of depths taken on the MER
    
    The arrays are stored ina structural array:
    
    New.LeftData {n}, where n is the number fo subjects being processed
    New.LeftDepth {n}, where n is the number fo subjects being processed

Written by Greydon Gilmore ggilmore@uwo.ca June 2017

%}     

% If final data structure loaded, then skip this function
if p.IntraoprativePatient == true || ~evalin('base','exist(''D'')')
        
    %-------------------------------------------------------------------------%
    %                             Code Starts Here                            %
    %-------------------------------------------------------------------------%
    oldFolder = cd(DataFolder);     % DataFolder is the location where all the folders are saved
    Data      = [];
    A         = dir;
    A(1:2)    = [];                 % To remove the directory and up one directory
    
    %-------------------------------------------------------------------------%
    %           Find the specific patient folder inside main folder           %
    %-------------------------------------------------------------------------%
    folderID = [];
    for i = 1:length(A)
        if (length(A(i).name) >=3 && strcmp('DBS' , A(i).name(1:3)))
            folderID = [folderID ; i];
            SN       = str2num(A(i).name(5:end));
        end
        New(i).SN   = SN;
    end
    A      = A(folderID);
    
    
    % After this point the list of folders in the A structure and the subject
    % numbers in the D structure are in the same order
    
    %-------------------------------------------------------------------------%
    %    Loop through all the files to extract data for Left and Right side   %
    %-------------------------------------------------------------------------%
    formatSpec      = '%f %f %f %f %f %f %f %f %f';   % define the format of each textfile from Leadpoint
    skippedNum      = 1;                              % initialize in case a subject is skipped
    leftStudyCodes  = p.left_codes;                   % these are the know study codes for the left side
    rightStudyCodes = p.right_codes;                  % these are the know study codes for the right side
    
    for isubji = 1:size({New.SN},2)
        
        if p.IntraoprativePatient == true
        else
            % If a folder exists for the subject within 'processed' the subject
            % will either be skipped or the folder will be removed.
            if exist ([mainFolder, '\processed' , '\DBS-', num2str(New(isubji).SN)])
                rmdir ([mainFolder, '\processed' , '\DBS-', num2str(New(isubji).SN)], 's')
                disp(['Removed processed folder for subject ' , num2str(New(isubji).SN) , '.'])
                cd(oldFolder)
            end
        end
        
        cd([DataFolder ,'/DBS-', num2str(New(isubji).SN)]);
        
        B = dir('*.txt'); % all .txt files within the patient specific directory
        
        if size(B, 1) > 120 % Skip a subject who has greater than 120 files, ensure you save all channels from each depth into one file
            disp(['Skipped subject ' , num2str(New(isubji).SN) , ': ' , ' Number of files exceeded limit!'])
            disp('Ensure you have saved all channels from each depth into one file')
            p.patientsSkipped(skippedNum) = New(isubji).SN;    % Save skipped subjects into an array
            skippedNum                   = skippedNum +1;
            continue
            
        else
            disp('START: Extracting data from Leadpoint files.')
            fprintf('\n')
            
            %--- Read from headerFile
            [headerFile]             = lp_headerReader(New(isubji).SN, p);
                        
            %--- Find and remove header file
            try
                B(endsWith({B(:).name},'_header.txt'))  = [];
            catch
                B(cell2mat({B(:).bytes}) < 10000) = [];
            end
            
            %--- Determine how many leading zeros the patient has and the study codes
            if New(isubji).SN < 100
                lead_zeros = '000000';
                for numi = 1:size(B, 1)
                    study_code(numi,1) = str2num(B(numi).name(10:11));
                end
            else
                lead_zeros = '00000';
                for numi = 1:size(B, 1)
                    study_code(numi,1) = str2num(B(numi).name(10:11));
                end
            end
            
            %--- Determine which side the files belong to
            minCode = min(unique(study_code));
            maxCode = max(unique(study_code));
            if minCode == maxCode % If min and max are the same code then there is only one side recorded
                if ismember(minCode,cell2mat(leftStudyCodes))
                    side.L   = minCode;
                    side.R   = NaN;
                    headerFile.sides = NaN;
                elseif ismember(minCode,cell2mat(rightStudyCodes))
                    side.L   = NaN;
                    side.R   = minCode;
                end
            else
                side.L = minCode;
                side.R = maxCode;
            end
            clear study_code min_code max_code

            New(isubji).headerFile = headerFile;
            %--- Left data extraction
            if ~isnan(side.L) % If there is Left data for the subject this condition will be met
                LeftCode = side.L;
                [~,headerFileIndex] = ismember(LeftCode, cell2mat({headerFile.studyNumber})); % This will provide the correct index for left side info from headerFile
                clear data depth
                cnt = 1;
                disp(['START: Extracting left data for subject ' , num2str(New(isubji).SN)])
                fprintf('\n')
                for ifile = 1:length(B)
                    if str2num(B(ifile).name(10:11)) == LeftCode
                        NAME       = B(ifile).name;
                        fileID     = fopen (NAME);
                        depth(cnt) = round(str2num(B(ifile).name(20:24))/10)/10; % Need to add condition for zeros that are negative or positive!!!
                        
                        if ~ismember (depth(cnt), depth(1:end-1)) || size(depth,2) == 1
                            data{cnt}  = cell2mat(textscan(fileID,formatSpec));
                            if New(isubji).SN == 70
                                data{cnt}  = data{cnt}(:,5:9);
                            else
                                data{cnt}  = data{cnt}(:,2:6);
                            end
                            data{cnt}(:,headerFile(headerFileIndex).missingChannels) = [];% Extract only the data corresponding to recording channels, missing channels will be removed
                            if size(headerFile(headerFileIndex).missingChannels,2) > 0 % If there are missing channels display what channels are missing
                                disp(['Left data for subject ' , num2str(New(isubji).SN) , ': ' , NAME , ' imported, missing channels ' ...
                                    num2str(headerFile(headerFileIndex).missingChannels) ' Depth = ' , num2str(depth(cnt))])
                            else
                                disp(['Left data for subject ' , num2str(New(isubji).SN) , ': ' , NAME , ' Depth = ' , num2str(depth(cnt))])
                            end
                            cnt        = cnt + 1;
                        else
                            [~,loc]    = ismember (depth(cnt), depth(1:end-1)); % Find the index of the repeated depth
                            disp(['Removed duplicate left side data for subject ' , num2str(New(isubji).SN) , ': ' , 'at Depth = ' , num2str(depth(cnt))])
                            depth(cnt) = []; % Removed data from previous repeated depth and save the new data from that depth instead
                            temp       = cell2mat(textscan(fileID,formatSpec));
                            data{loc}  = temp(:,2:6);
                            data{loc}(:,headerFile(headerFileIndex).missingChannels) = [];
                            clear temp loc
                        end
                    end
                end
                [~,b]                   = sort(depth, 'ascend'); % This will sort the depths from negative to positive
                depth                   = depth(b);
                data                    = data(b);
                New(isubji).LeftData  = data;
                New(isubji).LeftDepth = depth;
            else
                New(isubji).LeftData  = {};
                New(isubji).LeftDepth = {};
            end
            
            %--- Right data extraction
            if ~isnan(side.R)
                RightCode = side.R;
                [~,headerFileIndex] = ismember(RightCode, cell2mat({headerFile.studyNumber}));
                clear data depth b
                cnt = 1;
                fprintf('\n')
                disp(['START: Extracting right data for subject ' , num2str(New(isubji).SN)])
                fprintf('\n')
                for ifile = 1:length(B)
                    if str2num(B(ifile).name(10:11)) == RightCode
                        NAME       = B(ifile).name;
                        fileID     = fopen (NAME);
                        depth(cnt) = round(str2num(B(ifile).name(20:24))/10)/10;
                        
                        if ~ismember (depth(cnt), depth(1:end-1)) || size(depth,2) == 1
                            data{cnt}  = cell2mat(textscan(fileID,formatSpec));
                            data{cnt}  = data{cnt}(:,2:6);
                            if size(data{cnt},1) > 10* p.sr
                                data{cnt} = data{cnt}(1:10* p.sr,:);
                            end
                            if headerFileIndex ~=0
                                data{cnt}(:,headerFile(headerFileIndex).missingChannels) = [];% Extract only the data corresponding to recording channels
                                
                                if size(headerFile(headerFileIndex).missingChannels,2)>0
                                    disp(['Right data for subject ' , num2str(New(isubji).SN) , ': ' , NAME , ' imported, missing channels ' ...
                                        num2str(headerFile(headerFileIndex).missingChannels) ' Depth = ' , num2str(depth(cnt))])
                                else
                                    disp(['Right data for subject ' , num2str(New(isubji).SN) , ': ' , NAME , ' Depth = ' , num2str(depth(cnt))])
                                end
                            else
                                disp(['Right data for subject ' , num2str(New(isubji).SN) , ': ' , NAME , ' Depth = ' , num2str(depth(cnt))])
                            end
                            cnt        = cnt + 1;
                        else
                            [~,loc]    = ismember (depth(cnt), depth(1:end-1)); % Find the index of the repeated depth
                            disp(['Removed duplicate right side data for subject ' , num2str(New(isubji).SN) , ': ' , 'at Depth = ' , num2str(depth(cnt))])
                            depth(cnt) = [];
                            temp       = cell2mat(textscan(fileID,formatSpec));
                            data{loc}  = temp(:,2:6);
                            data{loc}(:,headerFile(headerFileIndex).missingChannels) = [];
                            clear temp loc
                        end
                    end
                end
                [~,b]                    = sort(depth, 'ascend');
                depth                    = depth(b);
                data                     = data(b);
                New(isubji).RightData  = data;
                New(isubji).RightDepth = depth;
            else
                New(isubji).RightData  = {};
                New(isubji).RightDepth = {};
            end
            fclose('all')
            fclose('all')
        end
    end
    
    cd(mainFolder)
    fprintf('\n')
    disp('DONE: Extracting data from Leadpoint files for all subjects.')
    fprintf('\n')
else
    New = [];
    fprintf('\n')
    disp('Final data structure already loaded, skipping function lp_extractLeadpointFiles.')
    fprintf('\n')
end
end
