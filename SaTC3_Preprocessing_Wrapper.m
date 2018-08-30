function SaTC3_Preprocessing_Wrapper()

%%% This is a wrapper for the preprocessing steps for the SaTC3 Project
%%% Please select the participants you want to run the scripts for,
%%% uncomment appropriate scripts to run.


%%% INSTRUCTIONS:
%%% Before running, make sure the data directory in each script points to
%%% the right data, and that the data is formatted correctly to run through
%%% the scripts (for example, 301_3D/Benefits/Non_moco

%% *** Update lines 21 and 23 after running script to note which participants
%%     have been run

%% Current Participants
% [301:326];

% Preprocessing completed for: 

% Part 1 (Funcprepro):   [301:330]

% Part 2:   [301:330]

% Waiting to check coregistration/movement: []

%% **** LAST USED ON: 9/27/2017 *****



% ****************************************************************************
% *** Please enter subjects to be preprocessed below: ***
% ****************************************************************************

%subs = [318:330];
subs = 301
%% Convert DICOMS to NIFTIS
%%% Select Convert Dicom ONLY!

% SaTC_DicomConvert()


%% Functional Preprocessing Part 1 (Slice-Timing, Realignment, Coregistration)
%%% Make sure origin is reset for ACC for all scans
% 
for s = subs
    SaTC3_Funcprepro(s)
end

%%% Check Movement and Coregistration before continuing

%% Function Preprocessing Part 2 (Segmentation/Normalisation, Smoothing)

for s = subs
    SaTC3_AnatSegment(s)
    SaTC3_NormSmooth(s)
end
    
    
end
    
    
    
    
    
    
    
    
    