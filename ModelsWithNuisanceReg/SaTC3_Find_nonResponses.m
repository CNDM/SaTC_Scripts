function nonResponses = SaTC3_Find_nonResponses(subs)

%%% Will create an array of run x sub, with how many non-responses each
%%% subject has in each run in the body. As usual, please change the
%%% directory if you are running on a different/local computer.

%%% This is called inside of the Model Wrapper Function

% Composed by Anthony Resnick 6/27/2017

%% Build structure
subCell = num2cell(subs);
nonResponsesRegressors = {'Question';'Benefit';'Decision'};
body = num2cell(zeros(length(nonResponsesRegressors),length(subCell)));
nonResponsesHeader = ['Subject',subCell];

nonResponsesBody = [nonResponsesRegressors,body];
nonResponses = [nonResponsesHeader;nonResponsesBody];



% Directory
scriptdir = pwd;

for s = 1:length(subs)
    sNum = num2str(subs(s));

%---------------------------------------------------------------
% ****************************************************************************
% *** Please change these to your data and save directories ***
% ****************************************************************************


%   Dropbox Directory
BehaviorDataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Regressors';

    %   Anthony Directory
%mriDataDir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/fMRI_Data/ReconScans';
%BehaviorDataDir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/Regressors';

BehaviorSubdir = fullfile(BehaviorDataDir,sprintf('%s',sNum));


runs = {'Question','Benefit','Decision'};

for r=1:3
%   Read in regressors
    cd(BehaviorSubdir)
    rawRegressors = csvread(fullfile(BehaviorSubdir, sprintf('%sRegressor.%s',runs{r},sNum)));

%   Find Non-Responses
    if sum(ismember(rawRegressors(:,2),0)) ~= 0
        nonResponses{r+1,s+1} = sum(ismember(rawRegressors(:,2),0));
    end
end
end
cd(scriptdir)
end
        