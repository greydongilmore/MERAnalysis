%{
These set of functions extract both clinical and electrophysiological spike
activity for all subjects undergoing deep brain stimulation surgery at
London Health Science Centre. All spike recordings were collected on the
Leadpoint system. The spike detection and clustering algortihms have been
adapted from Wave_Clus. 

INPUT
    Patient specific directory containing all the raw extracted data from 
    Leadpoint saved in .txt files.
 
OUTPUT
    Structural array housing all data for each subject, including both
    clinical and electrophysiological. The clinical data includes all depth
    graphs recorded by the neurosurgeon in the operating room. 

Prior to running these functions ensure you have placed all the patients to
be analysed within the 'allData' directory. All patients should be within
their own patient specific directory (e.g. DBS-01, DBS-02 etc.). Ensure 
there is a header file within the patient directory as well. 
%}

clear
clc

mainFolder = pwd;                   % Main working directory, will be wherever you place the folder MERAnalysis
DataFolder = [pwd 'rawData'];  % Folder with the exported Leadpoint files saved as 'DBS-caseNumber'
addpath([pwd '\lpFunctions'])       % Path to the folder with the functions.

%-------------------------------------------------------------------------%
%                    Check these settings prior to running                %
%-------------------------------------------------------------------------%
p.IntraoprativePatient     = false;  % Set this to 0 unless the data being extract has just beenn collected within the OR for online processing(This will ignore the clinical data).
p.removeProcessedDirectory = false; % In order to re-run saved data set this to true.
p.SaveDataStructure        = true;  % If you want to save the final data structure after extracting raw data and clustering (Will be loaded on next run of this script instead)
p.SaveClusterStructure     = true;  % If you want to save the final cluster structure

%--- GENERAL PARAMETERS
p.left_codes      = {1,19,25};        % Define the study codes for left (from Leadpoint)
p.right_codes     = {20,26};        % Define the study codes for right (from Leadpoint)
p.save_plots      = false;          % For Wave_Clus: true or false (if true plots take awhile to plot from Wave_Clus output)
p.parallel        = true;           % For Wave_Clus: if true Wave_Clus will open parallel pool for clustering
p.STNOnly         = true;
p.numPerStruct    = 20;

%-------------------------------------------------------------------------%
%             Load Final Data Structure If Removal is False               %
%-------------------------------------------------------------------------%
if p.IntraoprativePatient == true
    DataFolder = [pwd '\intraoperativeData'];
end
% A = dir(DataFolder);
% A(1:2) = [];
% [~,inx] = sort({A.date});
% A = A(inx);
% for ifile = 7:length(A)
%     cd(DataFolder)
%     load(A(ifile).name)
%     cd(mainFolder)
%---------------------------------------------------------------------%
%                         Extract Raw Data                            %
%---------------------------------------------------------------------%
[p]       = lp_setParamters (mainFolder, p); % Set cluster settings. Will be skipped if structure is loaded.
[Info, p] = lp_ConstructInfo(p); % Construct info struc array from excel sheet 'PatientInfo1.xlsx'
[New, p]  = lp_extractLeadpointFiles(mainFolder, DataFolder, p); % Extract data from the Leadpoint files
[D]       = lp_combineStructures(Info, mainFolder, New, p); % Combine the spike data and clinical data together
lp_saveForCluster(mainFolder, p, D) % Save spike data into seperate Matlab array files
clear Info New
% end
%---------------------------------------------------------------------%
%                  Use Wave_Clus for Spike Sorting                    %
%---------------------------------------------------------------------%
% for ifile = 6:length(A)
%     cd(DataFolder)
%     load(A(ifile).name)
%     cd(mainFolder)
lp_waveClusUnsupervised(D, p, mainFolder); % Start parallel pool, detect and cluster the spikes. Need Wave_clus functions in Matlab path
% end
[D] = lp_importAnalyzedData(D, p, mainFolder); % Bring output of cluster back into the data structral array
[D] = lp_buildSpikeMatrix(D, p, mainFolder);

%---------------------------------------------------------------------%
%                       Post-Process The Data                         %
%---------------------------------------------------------------------%
[plotting] = lp_prepForPlotting (D);
plottingSpikes(D, plotting, mainFolder);
