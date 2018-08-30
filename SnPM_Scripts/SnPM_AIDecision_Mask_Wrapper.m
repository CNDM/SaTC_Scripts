function SnPM_AIDecision_Mask_Wrapper()
scriptdir = pwd
subs = [301,302,303,304,305,306,307,311,312,313,314,315,316,317];
subs = [subs, 318, 319, 320, 321, 322, 324, 325, 326, 328, 329];

Masks = {'Benefit','Question'}
thresholds = [0.005,0.01,0.001]


for mask = 1:length(Masks)
    SnPM_with_Mask_Part1(subs,Masks{mask})
end
cd(scriptdir)


for mask = 1:length(Masks)
    for thresh = 1:length(thresholds)
        SnPM_with_Mask_Part2(thresholds(thresh),Masks{mask})
    end
end