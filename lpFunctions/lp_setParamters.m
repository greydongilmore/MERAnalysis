function [p] = lp_setParamters (mainFolder, p)

if ~evalin('base','exist(''D'')') || p.IntraoprativePatient == true
    
    directory = which ('set_parameters');
    cd(directory(1:end-17))
    
    % This will display a GUI to modify any paramters for Wave_Clus
    % paramters
    f = set_parameters_ui;
    waitfor(f)
else
    fprintf('\n')
    disp('Final data structure already loaded, skipping function lp_setParamters.')
    fprintf('\n')
end

%---------------------------------------------------------------------%
    %          Set the Parameters for Clustering (Avoid Changing)         %
    %---------------------------------------------------------------------%
    %--- SPC PARAMETERS
    p.segments_length = 1;              % length (in minutes) of segments in which the data is cut (default 5min).
    p.sr              = 24000;          % Define the sampling rate
    p.mintemp      = 0.00;              % minimum temperature for SPC
    p.maxtemp      = 0.301;             % maximum temperature for SPC
    p.tempstep     = 0.005;              % temperature steps
    p.SWCycles     = 100;               % SPC iterations for each temperature (default 100)
    p.KNearNeighb  = 9;                % number of nearest neighbors for SPC
    p.min_clus     = 30;                % minimum size of a cluster (default 60)
    p.min_clus_rel = 0.005;             % minimum cluster size, relative to the total nr. of spikes (only for batch scripts).
    p.max_clus     = 33;                % maximum number of clusters allowed (default 13)
    p.randomseed   = 15485;                 % if 0, random seed is taken as the clock value (default 0)
    %p.randomseed   = 147;                 % If not 0, random seed
    %p.temp_plot    = 'lin';               % temperature plot in linear scale
    p.temp_plot    = 'log';             % temperature plot in log scale
    
    %--- DETECTION PARAMETERS
    p.tmax             = 'all';         % maximum time to load
    %p.tmax             = 180;          % maximum time to load (in sec)
    p.tmin             = 0;             % starting time for loading (in sec)
    p.w_pre            = 20;            % number of pre-event data points stored (default 20)
    p.w_post           = 44;            % number of post-event data points stored (default 44))
    p.alignment_window = 10;            % number of points around the sample expected to be the maximum
    p.stdmin           = 5;             % minimum threshold for detection
    p.stdmax           = 15;            % maximum threshold for detection
    p.detect_fmin      = 300;           % high pass filter for detection
    p.detect_fmax      = 3000;          % low pass filter for detection (default 1000)
    p.detect_order     = 4;             % filter order for detection
    p.sort_fmin        = 300;           % high pass filter for sorting
    p.sort_fmax        = 3000;          % low pass filter for sorting (default 3000)
    p.sort_order       = 2;             % filter order for sorting
    p.ref_ms           = 1.5;           % detector dead time, minimum refractory period (in ms)
    %p.detection        = 'pos';         % type of threshold
    % p.detection        = 'neg';
    p.detection        = 'both';
    p.channels         = 1;
    
    %--- INTERPOLATION PARAMETERS
    p.int_factor       = 5;             % interpolation factor
    p.interpolation    = 'y';           % interpolation with cubic splines (default)
    % p.interpolation    = 'n';
    
    %--- FEATURES PARAMETERS
    p.inputs           = 10;            % number of inputs to the clustering
    p.scales           = 4;             % number of scales for the wavelet decomposition
    p.features         = 'wav';         % type of feature ('wav' or 'pca')
    %p.features          = 'pca'
    
    %--- TEMPLATE MATCHING
    p.match            = 'y';           % for template matching
    %p.match             = 'n';           % for no template matching
    p.max_spk          = 50000;         % max. # of spikes before starting templ. match.
    p.permut           = 'y';           % for selection of random 'par.max_spk' spikes before starting templ. match.
    % p.permut           = 'n';           % for selection of the first 'par.max_spk' spikes before starting templ. match.
cd(mainFolder)
end

