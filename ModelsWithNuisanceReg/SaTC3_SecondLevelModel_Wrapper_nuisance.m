function SaTC3_SecondLevelModel_Wrapper_nuisance()

%%% This is a wrapper for building Second Level models for the SaTC3 Project
%%% Please select the participants you want to run the scripts for,
%%% uncomment appropriate scripts to run.


%%% INSTRUCTIONS:
%%% Before running, make sure the data directory in each script points to
%%% the right data, and that the data is formatted correctly to run through
%%% the scripts (for example, 301_3D/Benefits/Non_moco

%% *** Update lines 21 and 23 after running script to note which participants
%%     have been run

%% Current Participants
% [301:330];

%% Excluded Participants
% [308, 309, 310, 323, 327, 330]

% Most recent second level model includes: N = 17 (with excluded participants) | [301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317]
% Most recent second level model includes: N = 24 | [301:307,311:322, 324:326, 328, 329]
%% **** LAST USED ON: 9/27/2017 *****



% ****************************************************************************
% *** Please enter subjects below: ***
% ****************************************************************************

subs = [301,302,303,304,305,306,307,311,312,313,314,315,316,317];
subs = [subs, 318, 319, 320, 321, 322, 324, 325, 326, 328, 329];


% ****************************************************************************
%% Building a second level Simple Model
SaTC3_SecondLevelContrast_SimpleModel_nuisance(subs,'Benefit');
SaTC3_SecondLevelContrast_SimpleModel_nuisance(subs,'Question');
SaTC3_SecondLevelContrast_SimpleModel_nuisance(subs,'Decision');

% ****************************************************************************

% ****************************************************************************
%% Building a second level AI_Decision Model
SaTC3_SecondLevelContrast_AIDecisionModel_nuisance(subs);

% ****************************************************************************

    
    
end