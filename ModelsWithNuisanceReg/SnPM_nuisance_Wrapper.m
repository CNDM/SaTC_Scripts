function SnPM_nuisance_Wrapper()
scriptdir = pwd
subs = [301,302,303,304,305,306,307,311,312,313,314,315,316,317];
subs = [subs, 318, 319, 320, 321, 322, 324, 325, 326, 328, 329];

Models = {'Benefit','Question','Decision','AI_Decision'}
thresholds = {'0.005','0.01','0.001'};


for midx = 1:length(Models)
    for threshidx = 1:length(thresholds)
        SnPMBatch_script_nuisance(subs,Models{midx},thresholds{threshidx});
        cd(scriptdir)
    end
end


