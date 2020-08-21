%% 3 Tutorial: EEG microstates analysis on spontaneous EEG Data
%
% This script executes the analysis steps of the Tutorial described in
% detail in section 3.3 to 3.8 of:
% Poulsen, A. T., Pedroni, A., Langer, N., & Hansen, L. K. (2018).
% Microstate EEGlab toolbox: An introductionary guide. bioRxiv.
%
% Authors:
% Andreas Trier Poulsen, atpo@dtu.dk
% Technical University of Denmark, DTU Compute, Cognitive systems.
%
% Andreas Pedroni, andreas.pedroni@uzh.ch
% University of Zurich, Psychologisches Institut, Methoden der
% Plastizitaetsforschung.
clc;clear;close all; 
clc;clear;close all
% start EEGLAB to load all dependent paths
eeglab;

%% set the path to the directory with the EEG files
tic;
addpath('E:\eeg_code\Toolbox\eeglab14_1_1b'); %('D:\scripts\StanfordShenzhen\Toolbox'),'-END');'F:\DG\Toolbox'),'-END';
% rmpath(genpath(['D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221']));%'D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221' 'F:\DG\Toolbox\fieldtrip-20180221'
% addpath('E:\eeg_code\Toolbox\fieldtrip-20180221');%'D:\scripts\StanfordShenzhen\Toolbox\fieldtrip-20180221'
% ft_defaults;

%% 3.3 Data selection and aggregation
%% 3.3.1 Loading datasets in EEGLAB
% change this path to the folder where the EEG files are saved
StudyFolder = 'E:\study\Normal_s\pre\Preprocessed';     %for the pre input file path
StudyFolder_2= 'E:\study\Normal_s\post\Preprocessed';   %for the post input file path
out_folder='E:\study\Normal_s\pre\features_2';          %for the pre output file path
out_folder_2='E:\study\Normal_s\post\features_2';       %for the post output file path
FilesALL = dir(StudyFolder);
for issub = 3:length(FilesALL) 
    Subfolder = [StudyFolder '\' FilesALL(issub).name];
    namelist=dir([Subfolder,'\*.','mat']);

    len = length(namelist);
    
    for k=1:len
        suf = namelist(k).name;
        load([Subfolder '\' suf]);
        
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG1, 0 );
        eeglab redraw % updates EEGLAB datasets
    end
end
FilesALL_2 = dir(StudyFolder_2);
for issub = 3:length(FilesALL_2) 
    Subfolder = [StudyFolder_2 '\' FilesALL_2(issub).name];
    namelist=dir([Subfolder,'\*.','mat']);

    len = length(namelist);
    
    for k=1:len
        suf = namelist(k).name;
        load([Subfolder '\' suf]);
        
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG1, 0 );
        eeglab redraw % updates EEGLAB datasets
    end
end

num=(length(FilesALL)-2)*4;


%% 3.3.2 Select data for microstate analysis
[EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG, 'datatype', 'spontaneous',...
'avgref', 1, ...
'normalise', 0, ...
'MinPeakDist', 10, ...
'Npeaks', 1000, ...
'GFPthresh', 1, ...
'dataset_idx', 1:num);
% store data in a new EEG structure
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw % updates EEGLAB datasets
%% 3.4 Microstate segmentation
% select the "GFPpeak" dataset and make it the active set
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, num,'retrieve',num+1,'study',0);
eeglab redraw
% Perform the microstate segmentation
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', ...
'sorting', 'Global explained variance', ...
'Nmicrostates',4, ...
'verbose', 1, ...
'normalise', 0, ...
'Nrepetitions', 50, ...
'max_iterations', 1000, ...
'threshold', 1e-06, ...
'fitmeas', 'CV',...
'optimised',1);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% 3.5 Review and select microstate segmentation
%% 3.5.1 Plot microstate prototype topographies
% figure;MicroPlotTopo( EEG,'plot_range', [] );
%% 3.5.2 Select active number of microstates
% EEG = pop_micro_selectNmicro( EEG);
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% Import microstate prototypes from other dataset to the datasets that should be back-fitted
% note that dataset number 5 is the GFPpeaks dataset with the microstate
% prototypes
for i = 1:num
fprintf('Importing prototypes and backfitting for dataset %i\n',i)
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',i,'study',0);
EEG = pop_micro_import_proto( EEG, ALLEEG, num+1);

%% 3.6 Back-fit microstates on EEG
EEG = pop_micro_fit( EEG, 'polarity', 0 );
%% 3.7 Temporally smooth microstates labels
EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
'smooth_type', 'reject segments', ...
'minTime', 30, ...
'polarity', 0 );
%% 3.9 Calculate microstate statistics
EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
'polarity', 0 );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
results(i)=ALLEEG(i).microstate.stats;
end

all_results=results;
for issub = 3:length(FilesALL) 
    Subfolder = [StudyFolder '\' FilesALL(issub).name];
    namelist=dir([Subfolder,'\*.','mat']);

    len = length(namelist);

    for k=1:len
        suf = namelist(k).name;
        
        mkdir(out_folder);
        path1=[out_folder '\' suf(1:end-8)];
        mkdir(path1);
        results=all_results((issub-3)*len+k);
        
        suf_new = suf(1:end-4);suffix = 'MST.mat';savename=[suf_new suffix];
        save([path1 '\' savename],'results');
        
        eeglab redraw % updates EEGLAB datasets
    end
end
base_num=(length(FilesALL)-2)*2;
for issub = 3:length(FilesALL) 
    Subfolder = [StudyFolder_2 '\' FilesALL_2(issub).name];
    namelist=dir([Subfolder,'\*.','mat']);

    len = length(namelist);

    for k=1:len
        suf = namelist(k).name;
        
        mkdir(out_folder_2);
        path1=[out_folder_2 '\' suf(1:end-9)];
        mkdir(path1);
        results=all_results((issub-3)*len+k+base_num);
        
        suf_new = suf(1:end-4);suffix = 'MST.mat';savename=[suf_new suffix];
        save([path1 '\' savename],'results');
        
        eeglab redraw % updates EEGLAB datasets
    end
end
save([out_folder '\cache.mat']);
%% 3.8 Illustrating microstate segmentation
% Plotting GFP of active microstates for the 4200-5700 ms for subject 1.
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0);
figure;
MicroPlotSegments( EEG, 'label_type', 'backfit', ...
'plotsegnos', 'first', 'plot_time', [4200 5700], 'plottopos', 1 );
eeglab redraw