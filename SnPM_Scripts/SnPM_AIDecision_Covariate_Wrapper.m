function SnPM_AIDecision_Covariate_Wrapper()
scriptdir = pwd
subs = [301,302,303,304,305,306,307,311,312,313,314,315,316,317];
subs = [subs, 318, 319, 320, 321, 322, 324, 325, 326, 328, 329];

%Covariates = {'BenefitBeta','QuestionBeta','ProfileSum','PC','IU','ACC','AWA','COL','CONTROL','ERR','SEC','RISK','TRUST','SPA','IPA','FBFREQ'};
Covariates = {'QuestionBeta','ProfileSum','PC','IU','ACC','AWA','COL','CONTROL','ERR','SEC','RISK','TRUST','SPA','IPA','FBFREQ'};

thresholds = [0.005,0.01,0.001]


for cov = 1:length(Covariates)
    SnPM_AIDecision_Covariate_Part1(subs,Covariates{cov})
end
cd(scriptdir)
for cov = 1:length(Covariates)
    for thresh = thresholds
        SnPM_AIDecision_Covariate_Part2(Covariates{cov},thresh)
    end
end

for cov = 1:length(Covariates)
    for thresh = thresholds
        NegAtt_Redo(Covariates{cov},thresh)
    end
end