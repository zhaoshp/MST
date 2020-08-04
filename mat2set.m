clc;clear;close all; 
clc;clear;close all
tic;
addpath(genpath('D:\scripts\StanfordShenzhen\Toolbox'),'-END'); %('D:\scripts\StanfordShenzhen\Toolbox'),'-END');'F:\DG\Toolbox'),'-END';
%rmpath(genpath(['D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221']));%'D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221' 'F:\DG\Toolbox\fieldtrip-20180221'
addpath('D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221');%'D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221'
ft_defaults;
StudyFolder = 'J:\ADstudy\EEG\Preprocessed';
FilesALL = dir(StudyFolder);
for issub = 3:length(FilesALL) %[3]
    Subfolder = [StudyFolder '\' FilesALL(issub).name];
    namelist=dir([Subfolder,'\*.','mat']);
% namelist = dir('*.mat');
    len = length(namelist);
    
    for k=1:len
        suf = namelist(k).name;
        load([Subfolder '\' suf]);
        folder='K:\ADstudy\EEG\SET';
        mkdir(folder)
        path1=[folder '\' suf(1:end-8)];
        mkdir(path1)
        suf_new = suf(1:end-4);suffix = '.set';savename=[suf_new suffix];
        EEG = pop_saveset( EEG1, 'filename',savename,'filepath',path1);
    end
end