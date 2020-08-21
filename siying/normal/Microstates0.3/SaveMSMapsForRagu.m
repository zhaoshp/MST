function rd = SaveMSMapsForRagu(EEGs,nMaps,Grouping)

for i = 1:numel(EEGs)
    rd.V(i,1,:,:) = EEGs(i).msinfo.MSMaps(nMaps).Maps';
    rd.Names{i,1} = EEGs(i).setname;
end

rd.IndFeature = Grouping;
rd.Design = [1,1];
rd.strF1  = 'Class';
rd.TwoFactors = 0;
rd.DeltaX = 1;
rd.txtX = 'MS';
rd.TimeOnset = 1;
rd.StartFrame = 1;
rd.EndFrame = nMaps;
rd.axislabel = 'Class';
rd.FreqDomain = 0;
rd.DLabels1 = 'MSMap';

rd.conds{1,1} = 'None';

X = cell2mat({EEGs(1).chanlocs.X});
Y = cell2mat({EEGs(1).chanlocs.Y});
Z = cell2mat({EEGs(1).chanlocs.Z});

rd.Channel = [X; Y;Z];

