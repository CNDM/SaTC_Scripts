function theData = SaTC3_buildRegressor(s)

%%%% Takes Subject number as input, builds 3 files of onsets, Responses,
%%%% and RT, saves these into the saveDir as csv files. Please change the
%%%% dataDir and saveDir to match where your data is, and where you want to
%%%% save the new files. Will create folders for each sub number

% Composed by Anthony Resnick, June 8 2017



cwd = pwd;

%---------------------------------------------------------------
% ****************************************************************************
% *** Please change these to your data and save directories ***
% ****************************************************************************

% Dropbox Directory
dataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/Data/';
saveDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Regressors';

% Anthony's Directory
%dataDir = '/Users/CNDM/Documents/SaTC3_withPractice/Data/';
%saveDir = '/Users/CNDM/Documents/SaTC3_withPractice/Regressors/';

%---------------------------------------------------------------

    subjectID = num2str(s);
    sourcename = fullfile(dataDir,subjectID);
    cd(sourcename)
    try
        Bene=read_table_DMRate(['Benefit.2.' subjectID '.out.txt']);
        Quest=read_table_DMRate(['Question.1.' subjectID '.out.txt']);
        
        for r=1:2
            Dec(r)=read_table_DMDec(['Dec.' num2str(r) '.' subjectID '.out.txt']);
        end
        
        Header = {'Onset','Response','RT'};
        BenefitRegressor = [Bene.col5-12,str2num(cell2mat(Bene.col6)),Bene.col7];
        QuestionRegressor = [Quest.col5-12,str2num(cell2mat(Quest.col6)),Quest.col7];
        
        DecisionRegressor1 = [Dec(1).col6-12,str2num(cell2mat(Dec(1).col7)),Dec(1).col8]; 
        DecisionRegressor2 = [(Dec(2).col6-12)+(Dec(1).col6(end)-12 + (Dec(1).col9(end)+6)),str2num(cell2mat(Dec(2).col7)),Dec(2).col8];
        DecisionRegressor = [DecisionRegressor1;DecisionRegressor2];
        
        cd(saveDir)
        
        if exist(fullfile(saveDir,subjectID),'dir')==0
            mkdir(fullfile(saveDir,subjectID));
        end
        
        if exist(fullfile(saveDir,subjectID,sprintf('BenefitRegressor.%s',subjectID)))==2
            overwrite = input('WARNING: This file already exists \n Would you like to Overwrite it? (y/n)\n','s');
            if overwrite=='n'
                cd(cwd)
                return
            else
            csvwrite(fullfile(saveDir,subjectID,sprintf('BenefitRegressor.%s',subjectID)),BenefitRegressor)
            csvwrite(fullfile(saveDir,subjectID,sprintf('QuestionRegressor.%s',subjectID)),QuestionRegressor)
            csvwrite(fullfile(saveDir,subjectID,sprintf('DecisionRegressor.%s',subjectID)),DecisionRegressor)
            end
        else
            csvwrite(fullfile(saveDir,subjectID,sprintf('BenefitRegressor.%s',subjectID)),BenefitRegressor)
            csvwrite(fullfile(saveDir,subjectID,sprintf('QuestionRegressor.%s',subjectID)),QuestionRegressor)
            csvwrite(fullfile(saveDir,subjectID,sprintf('DecisionRegressor.%s',subjectID)),DecisionRegressor)
        end 
        
    display(sprintf('Procedure successful for: %s',subjectID));
    catch ME %#ok<*NASGU>
        display(sprintf('Procedure failed for: %s',subjectID));
    end
cd(cwd)
end

