function Model_loop
datadir='C:\Users\clc42\Desktop\fMRI\ETS01\Analysis\';
subj{1}='16711';
subj{2}='16716';
subj{3}='16739';
subj{4}='16740';
subj{5}='16746';
subj{6}='16751';
subj{7}='16752';
subj{8}='16762';
subj{9}='16781';
subj{10}='16782';
subj{11}='16803';
subj{12}='16805';
subj{13}='16817';
subj{14}='16824';
subj{15}='16845';
subj{16}='16872';
subj{17}='16882';
subj{18}='16891';
subj{19}='16900';
subj{20}='16916';

% %Second Levels
 cd (datadir)
 
%covfile='C:\Users\clc42\Desktop\fMRI\ETS01\Analysis\Covariates\GenSwitchDiffRT.txt'; %Covariate file
%SecondLevelContrastCov(subj,covfile)
SecondLevelContrast_FLModel(subj);
%SecondLevelContrast_ReallyBasicModel_Pairedttest(subj)
%  con=14;%72%BasicModel
con=2;
 for c=1:con
     SecondLevelContrastManager_FLModel(c)
%      SecondLevelContrastManagerCov(c)
%     SecondLevelContrastManager_TimeRPP(c)
%     SecondLevelContrastManager_TimeRPP_1sec(c)
end

