function [Info, p] = lp_ConstructInfo(p)
%{
    The function lp_ConstructInfo will import the data from the patient
    excel spreadhseet and store the information within the strcutural array
    Info. This function was written by Neda Kordjazi.

INPUT
    An excel spreadsheet that houses all the clinical information for each
    subject

OUTPUT
    A structural array with fields associated with all the clinical
    information taken from the operation room.

%}

%This function will be skipped if the patient files are from a case
%that is happening in real-time (There will be no clinical data at present)
if p.IntraoprativePatient == false 
if ~evalin('base','exist(''D'')') 
    
    %----------------------------------------------------------%
    %                  Worksheet: Surgial Plan                 %
    %----------------------------------------------------------%
    disp('START: Importing clinical data from excel file.')
    %--- Import the data
    [~, ~, fullData] = xlsread([pwd, '\Patient Info1.xlsx'],'Surgial Plan');
    fullData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),fullData)) = {''};
    cellVectors = fullData(:,[3,4,6,7,8,9]);
    raw         = fullData(:,[1,2,5,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]);
    
    %--- Replace non-numeric cells with NaN
    R      = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells
    
    %--- Create output variable
    data = reshape([raw{:}],size(raw));
    
    %--- Create table
    SurgicalPlan = table;
    
    %--- Allocate imported array to column variable names
    SurgicalPlan.studynumber      = data(:,1);
    SurgicalPlan.subjectnumber    = data(:,2);
    SurgicalPlan.Lastname         = cellVectors(:,1);
    SurgicalPlan.Firstname        = cellVectors(:,2);
    SurgicalPlan.PIN              = data(:,3);
    SurgicalPlan.surgeon          = cellVectors(:,3);
    SurgicalPlan.neurologist      = cellVectors(:,4);
    SurgicalPlan.SurgeryData      = cellVectors(:,5);
    SurgicalPlan.target           = cellVectors(:,6);
    SurgicalPlan.trajpicked_left  = data(:,4);
    SurgicalPlan.CIn_left         = data(:,5);
    SurgicalPlan.COut_left        = data(:,6);
    SurgicalPlan.AIn1_left        = data(:,7);
    SurgicalPlan.AOut1_left       = data(:,8);
    SurgicalPlan.PIn2_left        = data(:,9);
    SurgicalPlan.POut2_left       = data(:,10);
    SurgicalPlan.MIn3_left        = data(:,11);
    SurgicalPlan.MOut3_left       = data(:,12);
    SurgicalPlan.LIn4_left        = data(:,13);
    SurgicalPlan.LOut4_left       = data(:,14);
    SurgicalPlan.trajpicked_right = data(:,15);
    SurgicalPlan.CIn5_right       = data(:,16);
    SurgicalPlan.COut5_right      = data(:,17);
    SurgicalPlan.AIn6_right       = data(:,18);
    SurgicalPlan.AOut6_right      = data(:,19);
    SurgicalPlan.PIn7_right       = data(:,20);
    SurgicalPlan.POut7_right      = data(:,21);
    SurgicalPlan.MIn8_right       = data(:,22);
    SurgicalPlan.MOut8_right      = data(:,23);
    SurgicalPlan.LIn9_right       = data(:,24);
    SurgicalPlan.LOut9_right      = data(:,25);
    
    SurgicalPlan          = SurgicalPlan(4:end,:);
    
    %--- Clear temporary variables
    clearvars data raw cellVectors R fullData;
    
    %----------------------------------------------------------%
    %                    Worksheet: File Info                  %
    %----------------------------------------------------------%
    
    %--- Import the data
    [~, ~, fullData] = xlsread([pwd, '\Patient Info1.xlsx'],'File Info');
    fullData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),fullData)) = {''};
    cellVectors = fullData(:,[3,4,6,7,8,9]);
    raw         = fullData(:,[1,2,5,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]);
    
    %--- Replace non-numeric cells with NaN
    R      = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells
    
    %--- Create output variable
    data   = reshape([raw{:}],size(raw));
    
    %--- Create table
    FileInfo = table;
    
    %--- Allocate imported array to column variable names
    FileInfo.studynumber      = data(:,1);
    FileInfo.subjectnumber    = data(:,2);
    FileInfo.lastname         = cellVectors(:,1);
    FileInfo.firstname        = cellVectors(:,2);
    FileInfo.pin              = data(:,3);
    FileInfo.target           = cellVectors(:,3);
    FileInfo.diagnosis        = cellVectors(:,4);
    FileInfo.date             = cellVectors(:,5);
    FileInfo.neurologist      = cellVectors(:,6);
    FileInfo.study_num_left   = data(:,4);
    FileInfo.num_traj_left    = data(:,5);
    FileInfo.num_depths_left  = data(:,6);
    FileInfo.center_left      = data(:,7);
    FileInfo.anterior_left    = data(:,8);
    FileInfo.posterior_left   = data(:,9);
    FileInfo.medial_left      = data(:,10);
    FileInfo.lateral_left     = data(:,11);
    FileInfo.study_num_right  = data(:,12);
    FileInfo.num_traj_right   = data(:,13);
    FileInfo.num_depths_right = data(:,14);
    FileInfo.center_right     = data(:,15);
    FileInfo.anterior_right   = data(:,16);
    FileInfo.posterior_right  = data(:,17);
    FileInfo.medial_right     = data(:,18);
    FileInfo.lateral_right    = data(:,19);
    
    FileInfo              = FileInfo(4:end, :);
    
    %--- Clear temporary variables
    clearvars data raw cellVectors R fullData;
    
    %----------------------------------------------------------%
    %         Remove any Subjects with Missing Data            %
    %----------------------------------------------------------%
    TargetMissing      = find(ismissing(SurgicalPlan(:,'target')) == 1);
    TrajectorysMissing = find(ismissing(SurgicalPlan(:,'trajpicked_left')) == 1 & ismissing(SurgicalPlan(:,'trajpicked_right')) == 1);
    DepthsMissing      = find(sum(ismissing(SurgicalPlan(:,11:20)),2) == 10 & sum(ismissing(SurgicalPlan(:,22:31)),2) == 10);
    EphysMissing       = find(sum(ismissing(FileInfo(:,[11 19])),2) == 2); 
    allMissing         = unique([TargetMissing;TrajectorysMissing;DepthsMissing;EphysMissing]);
    
    
    
    if p.STNOnly == true
        STNOnly    = find(cellfun(@isempty,strfind(table2array(SurgicalPlan(:,'target')), 'STN')));
        allMissing = unique([allMissing;STNOnly]);
    end
    subjectsRemoved            = table2array(SurgicalPlan(allMissing,'subjectnumber'));
    SurgicalPlan(allMissing,:) = [];
    FileInfo(allMissing,:)     = [];
    p.removedCases             = subjectsRemoved;
    
    %--- Clear temporary variables
    clearvars TargetMissing TrajectorysMissing DepthsMissing EphysMissing STNOnly allMissing subjectsRemoved
    
    %----------------------------------------------------------%
    %             Construct the data structure                 %
    %----------------------------------------------------------%
    Info.SN               = SurgicalPlan.subjectnumber;
    Info.Diagnosis        = FileInfo.diagnosis;
    Info.Target           = FileInfo.target;
    
    %--- Left data
    Info.LeftTrajPicked   = SurgicalPlan.trajpicked_left;
    Info.LeftStudyNum     = FileInfo.study_num_left;
    LeftCenterIn          = SurgicalPlan.CIn_left;
    LeftCenterOut         = SurgicalPlan.COut_left;
    LeftAnteriorIn        = SurgicalPlan.AIn1_left;
    LeftAnteriorOut       = SurgicalPlan.AOut1_left;
    LeftPosteriorIn       = SurgicalPlan.PIn2_left;
    LeftPosteriorOut      = SurgicalPlan.POut2_left;
    LeftMedialIn          = SurgicalPlan.MIn3_left;
    LeftMedialOut         = SurgicalPlan.MOut3_left;
    LeftLateralIn         = SurgicalPlan.LIn4_left;
    LeftLateralOut        = SurgicalPlan.LOut4_left;
    LeftNumChan           = FileInfo.num_traj_left;
    LeftNumDepth          = FileInfo.num_depths_left;
    LeftCenterIndx        = FileInfo.center_left;
    LeftAnteriorIndx      = FileInfo.anterior_left;
    LeftPosteriorIndx     = FileInfo.posterior_left;
    LeftMedialIndx        = FileInfo.medial_left;
    LeftLateralIndx       = FileInfo.lateral_left;
    
    %--- Right data
    Info.RightTrajPicked  = SurgicalPlan.trajpicked_right;
    Info.RightStudyNum    = FileInfo.study_num_right;
    RightCenterIn         = SurgicalPlan.CIn5_right;
    RightCenterOut        = SurgicalPlan.COut5_right;
    RightAnteriorIn       = SurgicalPlan.AIn6_right;
    RightAnteriorOut      = SurgicalPlan.AOut6_right;
    RightPosteriorIn      = SurgicalPlan.PIn7_right;
    RightPosteriorOut     = SurgicalPlan.POut7_right;
    RightMedialIn         = SurgicalPlan.MIn8_right;
    RightMedialOut        = SurgicalPlan.MOut8_right;
    RightLateralIn        = SurgicalPlan.LIn9_right;
    RightLateralOut       = SurgicalPlan.LOut9_right;
    RightNumChan          = FileInfo.num_traj_right;
    RightNumDepth         = FileInfo.num_depths_right;
    RightCenterIndx       = FileInfo.center_right;
    RightAnteriorIndx     = FileInfo.anterior_right;
    RightPosteriorIndx    = FileInfo.posterior_right;
    RightMedialIndx       = FileInfo.medial_right;
    RightLateralIndx      = FileInfo.lateral_right;
    
    Info.LeftIndx         = [LeftCenterIndx  LeftAnteriorIndx  LeftPosteriorIndx  LeftMedialIndx  LeftLateralIndx];
    Info.RightIndx        = [RightCenterIndx RightAnteriorIndx RightPosteriorIndx RightMedialIndx RightLateralIndx];
    
    Info.LeftInDep        = [LeftCenterIn  LeftAnteriorIn  LeftPosteriorIn  LeftMedialIn  LeftLateralIn];
    Info.LeftOutDep       = [LeftCenterOut LeftAnteriorOut LeftPosteriorOut LeftMedialOut LeftLateralOut];
    
    Info.RightInDep       = [RightCenterIn  RightAnteriorIn  RightPosteriorIn  RightMedialIn  RightLateralIn];
    Info.RightOutDep      = [RightCenterOut RightAnteriorOut RightPosteriorOut RightMedialOut RightLateralOut];
    
    
    %--- The data will be saved if it has not been already
    chk = exist ('stn_allInfo.mat');
    if chk == 2
    else
        save('stn_allInfo' , 'Info');
    end
    disp('DONE: Imported all clinical data from excel file.')
end
else
    Info = []; % For present intraoperative cases the Info structure will be left empty
    fprintf('\n')
    if p.IntraoprativePatient == false
        disp('Final data structure already loaded, skipping function lp_ConstructInfo.')
    else
        disp('Current intraoperative patient, info structure is left empty.')
    end
    fprintf('\n')
end
end