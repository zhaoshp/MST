%% Read the data and perform preprocessing
clear all; close all; clc

% dipfit_version = inputdlg('Your version of DIPFIT');
% dipfit_version = dipfit_version{1};

% eeglabpath = fileparts(which('eeglab.m'));                  % Getting eeglab path
% DipFitPath = fullfile(eeglabpath,'plugins',strcat('dipfit',dipfit_version));  % Crafting DipFit Path

ConDir = uigetdir([],'Path to the data of one condition/group level');  %%%% get the directory name of one condition/group level via directory dialog box 

con_name = inputdlg('The name of this condition');
con_name = con_name{1};

group_name = inputdlg('The name of this group');
group_name = group_name{1};

SavePath   = uigetdir([],'Path to store the results');  %%%% get the directory name of saving-results path via directory dialog box

ConIndex = [];

DirCon = dir(fullfile(ConDir,'*.set'));  %%%% find all the set file in your folder
FileNamesCon = {DirCon.name};

elec_deleted = inputdlg('Any electrode to be deleted?  True = 1 False = 0');
elec_deleted = str2num(elec_deleted{1});
if elec_deleted
    prompt = {'The name of the first electrode','The name of the second electrode',...
              'The name of the third electrode','The name of the fourth electrode',...
              'The name of the fifth electrode','The name of the sixth electrode',...
              'The name of the seventh electrode','The name of the eighth electrode',...
              'The name of the nineth electrode','The name of the tenth electrode'};
    dlg_title = 'The names of the electrodes to be deleted';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    answer = answer';
else
    answer = cell(1,10);
end

n = 1;
for i = 1:10
    if ~isempty(answer{1,i})
        answer2{1,n}= answer{1,i};
        n = n + 1;
    end
end

% Read the data and preprocess
eeglab
for f = 1:numel(FileNamesCon)
    EEG = pop_loadset(FileNamesCon{f}, ConDir); 
    setname = strrep(FileNamesCon{f},'.set',''); 
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',setname,'gui','off'); 
%     EEG = pop_chanedit(EEG, 'lookup',fullfile(DipFitPath,'standard_BESA','standard-10-5-cap385.elp')); % Add the channel positions
    if ~isempty(answer{1,1})
        EEG = pop_select( EEG,'nochannel',answer2);
    end
    EEG = pop_reref( EEG, []); % Make things average reference
    EEG = pop_eegfiltnew(EEG, 2, 20, [], 0, [], 0);
    EEG.condition = con_name;
    EEG.group = group_name;
    ALLEEG = eeg_store(ALLEEG, EEG, CURRENTSET);
    ConIndex = [ConIndex CURRENTSET]; 
end

eeglab redraw

%% Cluster the stuff
% Define the parameters for clustering
use_gfppeaks = inputdlg('Using the maps of GFPPeaks as original maps? True = 1 False = 0');
use_gfppeaks = str2num(use_gfppeaks{1});

ignore_polarity = inputdlg('Ignore the polarity of maps? True = 1 False = 0');
ignore_polarity = str2num(ignore_polarity{1});

use_aahc = inputdlg('Use AAHC? True = 1 False = 0');
use_aahc = str2num(use_aahc{1});

restarts_num = inputdlg('Number of restarts');
restarts_num = str2num(restarts_num{1});

ClustPars = struct('MinClasses',3,'MaxClasses',6,'GFPPeaks',use_gfppeaks,'IgnorePolarity',ignore_polarity,...
                   'MaxMaps',inf,'Restarts',restarts_num, 'UseAAHC',use_aahc);

% Loop across all subjects to identify the individual clusters
for i = 1:numel(ConIndex) 
    tmpEEG = eeg_retrieve(ALLEEG,ConIndex(i)); % the EEG we want to work with
    fprintf(1,'Clustering dataset %s (%i/%i)\n',tmpEEG.setname,i,numel(ConIndex)); % Some info for the impatient user
    tmpEEG = pop_FindMSTemplates(tmpEEG, ClustPars); % This is the actual clustering within subjects
    ALLEEG = eeg_store(ALLEEG, tmpEEG, ConIndex(i)); % Done, we just need to store this
end

eeglab redraw

%% Now we combine the microstate maps across subjects and edit the mean
EEG = pop_CombMSTemplates(ALLEEG, ConIndex, 0, 0, strcat('GrandMean',con_name,group_name));
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG] = pop_ShowIndMSMaps(EEG, 4, 1, ALLEEG); % Here, we go interactive to allow the user to put the classes in the canonical order
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % and store it
GrandMeanConIndex = CURRENTSET; % And keep track of it

eeglab redraw

%% And we sort things out over means and subjects
ALLEEG = pop_SortMSTemplates(ALLEEG, ConIndex, 0, GrandMeanConIndex); 

eeglab redraw

%% eventually save things
for f = 1:numel(ALLEEG)
    EEG = eeg_retrieve(ALLEEG,f);
    fname = [EEG.setname,'.set'];
    pop_saveset( EEG, 'filename',fname,'filepath',SavePath);
end

%% fitting the maps
fitting_gfp = inputdlg('Fitting based on GFP peaks? True = 1 False = 0');
fitting_gfp = str2num(fitting_gfp{1});
FitPars = struct('nClasses',4,'lambda',1,'b',30,'PeakFit',fitting_gfp, 'BControl',true);

% Using the individual templates
pop_QuantMSTemplates(ALLEEG, ConIndex, 0, FitPars, [], fullfile(SavePath,'ResultsFromIndividualTemplates.csv'));

% And using the grand mean template
pop_QuantMSTemplates(ALLEEG, ConIndex, 1, FitPars, GrandMeanConIndex, fullfile(SavePath,'ResultsFromGrandGrandMeanTemplate.csv'));


