%% 组平均
clc;clear all;close all
EEG = pop_loadset('filename','GrandMeang1g1.set','filepath','G:\desktop\Desktop\run2\');
EEG = eeg_checkset( EEG );
maps = EEG.data;
maps2 = squeeze(maps(:,:,4));
figure;topoplot(maps2(:,1),EEG.chanlocs);
figure;topoplot(maps2(:,2),EEG.chanlocs);
figure;topoplot(maps2(:,3),EEG.chanlocs);
figure;topoplot(maps2(:,4),EEG.chanlocs);

%% 单个被试
clc;clear all;close all
ConDir = 'G:\desktop\Desktop\run2\';
DirCon = dir(fullfile(ConDir,'*.set'));  %%%% find all the set file in your folder
FileNamesCon = {DirCon.name};

for f = 1:numel(FileNamesCon)
    EEG = pop_loadset(FileNamesCon{f}, ConDir); 
    maps(f,:,:) = EEG.msinfo.MSMaps(1,4).Maps;
    ALLEEG(1,f) = EEG;
end

for i = 1:numel(FileNamesCon)
    figure;
    subplot(1,4,1);topoplot(squeeze(maps(i,1,:)),EEG.chanlocs);
    subplot(1,4,2);topoplot(squeeze(maps(i,2,:)),EEG.chanlocs);
    subplot(1,4,3);topoplot(squeeze(maps(i,3,:)),EEG.chanlocs);
    subplot(1,4,4);topoplot(squeeze(maps(i,4,:)),EEG.chanlocs);
end

    
   
    
    
    
    
