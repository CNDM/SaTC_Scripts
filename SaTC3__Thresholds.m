function getThresholds()
scriptDir = pwd;
xlwriteDir = ['/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Scripts/xlwrite'];
analysisDir = ['/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/SnPM/nuisance_models'];
outputDir = ['/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Scripts/ModelsWithNuisanceReg'];

cd(xlwriteDir)
javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');
cd(scriptDir)

cd(analysisDir)
modelDir = getDirs(dir);



for mDir = 1:length(modelDir)
    cd(fullfile(analysisDir, modelDir{mDir}))
    threshDir = getDirs(dir);
    for tDir = 1:length(threshDir)
        cd(fullfile(analysisDir, modelDir{mDir},threshDir{tDir}));
        contrastDir = getDirs(dir);
        cname(mDir).contrasts = contrastDir;
        for cDir = 1:length(contrastDir)
            cd(fullfile(analysisDir, modelDir{mDir},threshDir{tDir}, contrastDir{cDir}));
            open('ClusterThreshold.fig')
            fig = gcf;
            h = findobj(fig,'-method','Text')
            x = array2table(h)
            if size(x,1) == 2
                threshold = x.h(1,1).String{1};
            elseif size(x,1) == 3
                threshold = x.h(2,1).String{1};
            elseif size(x,1) == 4
                threshold = fig.Children(1).XLabel.String;
            elseif size(x,1) == 5
                threshold = ['NOTSIG ' fig.Children(1).XLabel.String];
            elseif size(x,1) > 5
                threshold = x.h(7,1).String
            end
            close
            if cDir  == 1
                cPosition = 2;
            else
                cPosition = (cDir*8)+1;
            end
            thresharray{1,cDir} = threshold;
            data.model(mDir).threshold(tDir).contrast(cDir).thresholds = threshold
            cd('..')
        end
        %xlwrite([analysisDir '/nuisanceThresholds'],contrastDir,modelDir{mDir},'A2');
        %xlwrite([analysisDir '/nuisanceThresholds'],threshDir',modelDir{mDir},'B1');
        %data.model(mDir).threshold(tDir).contrast(cDir).thresholds = thresharray;
        cd('..')
    end
    cd('..')
end

for m = 1:length(modelDir)
    sheet = [{[]};cname(m).contrasts];
    thresh = {};
    for i = 1:size(data.model(m).threshold,2)
        for ii = 1:size(data.model(m).threshold(i).contrast,2)
            thresh(ii,i) = struct2cell(data.model(m).threshold(i).contrast(ii));
        end
    end
    sheet2 = [threshDir';thresh];
    xlwrite([analysisDir '/nuisanceThresholds_' modelDir{m}],[sheet,sheet2]);
end



for i = 1:2
    for mDir = 1:6
        for cDir = 1:6
            bigdata.Analysis(i).Mask(mDir).bigThresh(cDir,:) =  data.Analysis(i).Mask(mDir).Contrast(cDir).threshold
        end
    end
    
end
end
    function outputDir = getDirs(x)
    x = x(3:end) %Getting rid of previous dirs
    index = [x.isdir];
    idx = 1;
    for i = 1:length(index)
        if index(i) == 1
            outputDir{idx,1} = x(i).name;
            idx = idx+1;
        end
    end
    end

