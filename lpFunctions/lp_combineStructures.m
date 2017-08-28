function [Data] = lp_combineStructures(Info, mainFolder, New, p)
%{
    The function lp_combineStructures will combine the clinical data
    strcture with the electrophysiology data structure. 

INPUT
    This function requires the two data structures Info and New.

OUTPUT
    This function will output one final data structure labelled D.
    D.SN {Nx1} 
        Cell array where N is the number of subjects. This field inidcates 
        the subject number for each patient within the directory. 
    D.Diagnosis{Nx1} 
        Cell array where N is the number of subjects. This field inidcates
        the diagnosis of each subject.
    D.Target{Nx1} 
        Cell array where N is the number of subjects. This field indicates
        what the target brain structure was.
    D.*TrajPicked (1xN)
        Double array where N is the number of subjects. Only one trajectory 
        is picked for each subject for each side of brain.
    D.*StudyNum (1xN) 
        Double array where N is the number of subjects. This field 
        indicates the study number associated for the side of brain for 
        each subject.
    D.*Indx (NxM) 
        Double array where N is the number of subjects and M is the number 
        of trajectories for each subject. There can only be a maximum of 5 
        channels per subject for each side fo the brain.
    D.*InDep (NxM) 
        Double array where N is the number of subjects and M is the number 
        of trajectories for each subject for each side of the brain. This
        field indicates the depth at which the neurosurgeon determined we
        had just entered the target brain region for each channel.
    D.*OutDep (NxM) 
        Double array where N is the number of subjects and M is the number 
        of trajectories for each subject for each side of the brain. This
        field indicates the depth at which the neurosurgeon determined we
        exited the target brain region for each channel.
    D.*Data {Nx1}{1xM}(n by m)
        Double array where n is time (based on sampling frequency) and M is 
        the number of trajectories. This double array is indexed for each 
        depth {1xM} and for each subject {Nx1}. This field houses the raw 
        data from Leadpoint for all channels at all depths for all 
        subjects. 
    D.*Depths {Nx1}(1 by m)
        Double array where m is the depth within the brain on the Z-plane. 
        This double array is indexed for each subject {Nx1}. The depths are 
        measured in millimeters, where negative values indicate depths 
        ABOVE the target brain region. Positive values indicate depths 
        BELOW the target brain. 
%}


% If this is a current case within the operating room then this function
% will be skipped.
if p.IntraoprativePatient == false
    
    % If the final data structure exists then it will be loaded
    if ~evalin('base','exist(''D'')')
        fprintf('\n')
        disp('START: Constructing the final data structure.')
        
        A = {New.SN};   
        
        for isubj = 1:length(A)
            X(isubj) = getrow(Info,(Info.SN==A{isubj}));
        end
        
        New  = rmfield( New , 'SN' );
        Data = catstruct(X,New);
        
        % Sort the struture
        [sx,sx] = sort([Data.SN],'ascend');
        Data    = Data(sx);
                
        % Save the structure
        if p.SaveClusterStructure == true
            subjectCount = 0;
            for subji = 1:size({Data.SN},2)
                subjectCount           = subjectCount + 1;
                subjects(subjectCount) = Data(subji).SN;
                
                if subjectCount == p.numPerStruct || subji == size({Data.SN},2)
                    cd(mainFolder)
                    cd('dataStructures')
                    disp('Saving the final cluster structure...')
                    for isubj = 1:length(subjects)
                        D(isubj) = Data(cell2mat({Data.SN})==subjects(isubj));
                    end
                    if size(D,2) == 1
                        save(['rawDataSubject', num2str(subjects)], 'D' , '-v7.3');
                    else
                        save(['rawData', num2str(min(subjects)), 'To', num2str(max(subjects))], 'D' , '-v7.3');
                    end
                    disp('DONE: Saved the final data structure.')
                    cd(mainFolder)
                    % Reset the counter
                    subjectCount = 0;
                    subjects     = [];
                    clear D
                end
            end
        end
        
        disp('DONE: Final data structure contructed.')
        fprintf('\n')
    else
        Data = evalin('base','D');
        fprintf('\n')
        disp('Final data structure already loaded, skipping function lp_combineStructures.')
        fprintf('\n')
    end
else
    disp('START: Constructing the final data structure for intraoperative patient.')
    Data = New;
    disp('DONE: Final data structure contructed.')

end

    
 