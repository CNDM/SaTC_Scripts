function SaTC3_IndDiff_loop
directory.scriptdir = pwd;
directory.datadir='/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans';
directory.covariates = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Covariates';
subs = [301:307,311:322, 324:326, 328, 329];

subj{1}= '400924821';
subj{2}= '04350864';
subj{3}= '400926921';
subj{4}= '400929814';
subj{5}= '400929802';
subj{6}= '400936858';
subj{7}= '400934374';
subj{8}= '400940706';
subj{9}= '400940672';
subj{10}= '400942058';
subj{11}= '400942045';
subj{12}= '400990720';
subj{13}= '400991841';
subj{14}= '400993094';
subj{15}= '401009006';
subj{16}= '401016136';
subj{17}= '401016127';
subj{18}= '401016128';
subj{19}= '401016133';
subj{20}= '401016315';
subj{21}= '401018612';
subj{22}= '401018619';
subj{23}= '401024275';
subj{24}= '401025886';

Covariates = {'BenefitBeta','QuestionBeta','ProfileSum','PC','IU','ACC','AWA','COL','CONTROL','ERR','SEC','RISK','TRUST','SPA','IPA','FBFREQ'};
% %Second Levels

 
% % Decision Model
% for cov = 1:length(Covariates)
% SaTC3_SecondLevelContrastCov_DecisionModel(subj,subs,Covariates{cov},directory)
% end
% % AIDecision Model
% for cov=1:length(Covariates)
% SaTC3_SecondLevelContrastCov_AIDecisionModel(subj,subs,Covariates{cov},directory)
% end

% Decision Model nuisance
% for cov = 1:length(Covariates)
% SaTC3_SecondLevelContrastCov_DecisionModel_nuisance(subj,subs,Covariates{cov},directory)
% end
% % AIDecision Model nuisance
for cov=1:length(Covariates)
SaTC3_SecondLevelContrastCov_AIDecisionModel_nuisance(subj,subs,Covariates{cov},directory)
end
