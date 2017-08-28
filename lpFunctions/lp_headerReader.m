function [headerFile] = lp_headerReader(subject, p)
%{
[headerFile] = lp_header_reader(subjectdata) will read the header file 
from Leadpoint and extract the information required for data import, 
includig the time stamps of each file. 

Written by Greydon Gilmore ggilmore@uwo.ca June 2017

%}

h     = dir('*_header.txt');
headerFile = [];
for iheader = 1:size(h,1)
    header_file = h(iheader).name;
    header      = importdata(header_file);
    study_code  = header.data(1,2);
    if ismember(study_code,cell2mat(p.left_codes))
        side = 'Left';
    elseif ismember(study_code,cell2mat(p.right_codes))
        side = 'Right';
    end
    disp (['START: Reading the header file ', num2str(iheader), ' for the ', side, ' side', ' for subject ' num2str(subject)]);
    text_data   = header.textdata(2:end,:);
    num_data    = header.data;
    fileNames   = text_data(:,1);
    combined    = strfind(fileNames, 'all');
    [~,x]       = unique(fileNames);
    fileNames   = fileNames(x);

    if size(combined,1) > 1
        data                = load(cell2mat(fileNames(1)));
        if subject == 70
            summary             = sum(data(:,5:9),1); % Maximum number of channels
        else
            summary             = sum(data(:,2:6),1); % Maximum number of channels
        end
        allPossibleChannels = 1:5;
        missingChannels     = find(summary == 0);
        recordedChannels    = find(summary ~= 0);
        numChannel          = size(recordedChannels,2);
        cntMissing          = 1;
        cntRecorded         = 1;
        missingLabel        = [];
        
        for ichan = 1:length(allPossibleChannels)
            if ismember(ichan, recordedChannels)
                if ichan == 1
                    chname = 'Center';
                elseif ichan == 2
                    chname = 'Posterior';
                elseif ichan == 3
                    chname = 'Anterior';
                elseif ichan == 4
                    chname = 'Medial';
                elseif ichan == 5
                    chname = 'Lateral';
                end

                fprintf('%s side channel %i is %s.\n', side, ichan, chname)
                channelLabel{cntRecorded} = chname;
                cntRecorded = cntRecorded +1;
                clear chname
                
            elseif ismember(ichan, missingChannels)
                if ichan == 1
                    chname = 'Center';
                elseif ichan == 2
                    chname = 'Posterior';
                elseif ichan == 3
                    chname = 'Anterior';
                elseif ichan == 4
                    chname = 'Medial';
                elseif ichan == 5
                    chname = 'Lateral';
                end

                fprintf('%s side channel %i is %s and it is missing.\n', side, ichan, chname)
                missingLabel{cntMissing} = chname;
                cntMissing = cntMissing +1;
                clear chname
            end
        end
    else
        disp(['Skipped subject ' , num2str(subject) , ': ' , ' Number of files exceeded limit!'])
        disp('Ensure you have saved all channels from each depth into one file')
    end
    disp (['DONE: Reading the header file ' num2str(iheader) ' for subject ' num2str(subject)])
    fprintf('\n')
    
    %-------------------------------------------------------------------------%
    %              Save output information to structural array                %
    %-------------------------------------------------------------------------%
    headerFile(iheader).studyNumber      = study_code;
    headerFile(iheader).recordedChannels = recordedChannels;
    headerFile(iheader).recordedLabel    = channelLabel;
    headerFile(iheader).numChannel       = numChannel;
    headerFile(iheader).missingChannels  = missingChannels;
    headerFile(iheader).missingLabel     = missingLabel;
    headerFile(iheader).fileNames        = fileNames;
    headerFile(iheader).sides            = side;
end
end

