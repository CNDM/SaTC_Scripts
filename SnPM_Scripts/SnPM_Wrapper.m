function SnPM_Wrapper()

%%% This is a wrapper to run the SnPM functions for the SaTC3 project. It
%%% might be a good idea to run them one at a time in case anything wrong
%%% occurs.

subs = [301,302,303,304,305,306,307,311,312,313,314,315,316,317];
subs = [subs, 318, 319, 320, 321, 322, 324, 325, 326, 328, 329];


%% Attractiveness-Intrusiveness Decision Model
% SnPMBatch_script_AID005(subs);
% SnPMBatch_script_AID001(subs);
% SnPMBatch_script_AID01(subs);
% 
% %% Decision Model
% SnPMBatch_script_Decision005(subs);
% SnPMBatch_script_Decision001(subs);
% SnPMBatch_script_Decision01(subs);
% 
% %% Benefit Model
% SnPMBatch_script_Benefit005(subs);
% SnPMBatch_script_Benefit001(subs);
% SnPMBatch_script_Benefit01(subs);
% 
% %% Question Model
% SnPMBatch_script_Question005(subs);
% SnPMBatch_script_Question001(subs);
% SnPMBatch_script_Question01(subs);

PPI_SnPMBatch_script(subs);
