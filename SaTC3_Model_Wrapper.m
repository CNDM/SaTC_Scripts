function SaTC3_Model_Wrapper()

%%% This is a wrapper for building models for the SaTC3 Project
%%% Please select the participants you want to run the scripts for,
%%% uncomment appropriate scripts to run.


%%% INSTRUCTIONS:
%%% Before running, make sure the data directory in each script points to
%%% the right data, and that the data is formatted correctly to run through
%%% the scripts (for example, 301_3D/Benefits/Non_moco

%% *** Update lines 21 and 23 after running script to note which participants
%%     have been run

%% Current Participants
% [301,302,303,304,305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317];

% Simple Model completed for: [301:330]
% AI Model completed for: [301:330]
%% **** LAST USED ON: 10/2/2017 *****



% ****************************************************************************
% *** Please enter subjects below: ***
% ****************************************************************************

subs = [301:330];


% ****************************************************************************
%% Building a simple model

nonResponses = SaTC3_Find_nonResponses(subs)   % Creates matrix of No-Responses

for s = 1:length(subs)  % For each Subject
    for r = 1:3 % For each task
        switch r
            case 1  % Question
                if nonResponses{r+1,s+1} == 0   % if no missed responses
                    SaTC3_QuestionModel(subs(s))
                else
                    SaTC3_QuestionModel_with_nr(subs(s))
                end
            case 2  % Benefit
                if nonResponses{r+1,s+1} == 0   % if no missed responses
                    SaTC3_BenefitModel(subs(s))
                else
                    SaTC3_BenefitModel_with_nr(subs(s))
                end
            case 3  % Decision
                if nonResponses{r+1,s+1} ~= 0   % if no missed responses
                    SaTC3_DecisionModel(subs(s))
                else
                    SaTC3_DecisionModel_with_nr(subs(s))
                end
        end
    end
end
% ****************************************************************************


% ****************************************************************************
%%  Building a Decision model, including Attractiveness and Intrusiveness 
    for s = 1:length(subs)
        SaTC3_AI_DecisionModel(subs(s));
    end
% ****************************************************************************

    
    
end