# SaTC_Scripts
All of the fMRI Analysis scripts used in SaTC
Scripts: This is where all the scripts for the fMRI Analysis are kept. We will go over the wrapper functions and what they call. 
	SaTC3_Preprocessing_Wrapper.m
-	Does preprocessing. Calls:
o	SaTC_DicomConvert: Converts from dicom to nifti and formats scans into folders.
o	SaTC3_Funcprepro: Does Slice-Timing, Realignment, and CoRegistration
o	SaTC3_AnatSegment: Segments
o	SaTC3_NormSmooth: Normalizes and Smooths the scans.

SaTC3_Model_Wrapper.m
-	Runs the basic Models
o	SaTC3_Find_nonResponses: Creates a matrix of missed responses. Each row is either Question, Benefit, or Decision. Each column is a subject. Is used to determine whether or not to run the model with missed responses.
o	SaTC3_QuestionModel
o	SaTC3_QuestionModel_with_nr: These run the model during the question phase, parametrically modulated with intrusiveness ratings.
o	SaTC3_BenefitModel
o	SaTC3_BenefitModel_with_nr: These run the model during the benefits phase, parametrically modulated with attractiveness ratings.
o	SaTC3_DecisionModel
o	SaTC3_DecisionModel_with_nr: These run the model during the decision phase, parametrically modulated with the willingness ratings.
o	SaTC3_AI-DecisionModel: This runs the model during the decision phase, parametrically modulated with the willingness ratings and the previous ratings of attractiveness and intrusiveness for the corresponding benefit and question.

SaTC3_SecondLevelModel_Wrapper
-	Runs the second level models
o	SaTC3_SecondLevelContrast_SimpleModel: Takes the model as an argument and runs the second level analysis for either the Benefit, Question, or Decision model.
o	SaTC3_SecondLevelContrast_AIDecisionModel: Runs the second level model for the AIDecision model.

SaTC3_IndDiff_Loop: 
-	Runs the models with covariates
o	SaTC3_SecondLevelContrastCov_DecisionModel: Runs the Decision models with the covariates
o	SaTC3_SecondLevelContrastCov_AIDecisionModel: Runs the AIDecision models with the covariates
o	SaTC3_SecondLevelContrastCov_DecisionModel_nuisance: Runs the Decision models with the nuisance regressor with the covariates
o	SaTC3_SecondLevelContrastCov_AIDecisionModel_nuisance: Runs the AIDecision models with the nuisance regressor with the covariates

Miscellaneous scripts:
-	These scripts are miscellaneous scripts either used in conjunction or as one-off scripts to, for example, print out the results of an analysis or to grab the thresholds and combine them into one or multiple excel files.
o	PrintTables_MainModels: Goes through the main models and prints the spm results into a .csv 
o	PrintTables_NuisanceThreshold: Goes through the main models with the nuisance regressor and prints the spm results into a .csv
o	PrintTables_PPIModels: Goes through the PPI analysis (without nuisance) and prints the spm results into a .csv
o	SaTC3_Thresholds: Goes through the SnPM results and grabs the cluster threshold, saves it to an excel. Might need some maintenance or double-checking.
o	SaTC3_buildRegressor: Builds the regressor files used in the GLMs from the behavioral data
o	SaTC3_Thresholds_ppiNuisance: Goes through the PPI SnPM analysis and grabs the cluster thresholds, saves it to an excel. Still needs maintenance but arguably better and easier to adapt than the SaTC3_Thresholds script, since it uses Khoi’s old get_any_files function to grab all the ClusterThreshold.fig files in a directory (ALL of them, even if they are in subdirectories). Might need to double check that x.h(number,1) is the correct index for what you want to get!

ModelsWithNuisanceReg: This is a mirror of the scripts you saw before, but specifically for the models with the nuisance regressor. What this does also include is the SnPMBatch_script. It can easily be adapted, although as we have learned with the SnPMBatch_script_PPI, if being used on a different computer (especially a windows) there are some changes that need to be made!

PPI_Scripts: This was never used with a wrapper so here is a run-down of the steps:
1.	Run the Create_PPI (or Create_PPI_nuisance) script. The Create_PPI_nuisance script makes use of the make_VOI_nuisance script, which will create your VOIs for you. Very easy to make changes to. The Create_PPI scripts will create the PPI files you will use in the interaction.
2.	Run the PPI_Interaction (or PPI_Interaction_nuisance) script. This will run the interaction for each voi, for each contrast.
3.	Run the PPI_SecondLevel (or PPI_SecondLevel_nuisance) script. This will run the second level analyses on the interactions.

SnPM_Scripts: For the new nuisance models I (Anthony) was mostly getting away with using my new Batch Script, although with using it on Blaine’s computer, which is a pc and also a different computer, I ran into things that made it a little difficult to use the batch script.  If you want to avoid making a lot of changes to that kind of script, you can look here, which has scripts to run the SnPM analysis on all of the models (Covariates, PPI, Masked, and basic models). 
