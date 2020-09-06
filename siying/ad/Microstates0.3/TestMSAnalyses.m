%% Demo script for microstate analyses in EEGLAB
%
% %Author: Thomas Koenig, University of Bern, Switzerland, 2016
%  
%   Copyright (C) 2016 Thomas Koenig, University of Bern, Switzerland, 2016
%   thomas.koenig@puk.unibe.ch
%  
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%  
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%  
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
% ---------------------------------

% This is a sample script that you will have to adapt to meet your specific
% needs.

%% Read the data
% This is for vision analyzer data and may need adjustments
clear all
close all
clc

eeglabpath = fileparts(which('eeglab.m'));                  % Getting eeglab path
DipFitPath = fullfile(eeglabpath,'plugins','dipfit2.3');  % Crafting DipFit Path


Group1Dir = uigetdir([],'Path to the data of group 1 (Vision Analyzer data)');  %%%% get the directory name of group 1 via directory dialog box
Group2Dir = uigetdir([],'Path to the data of group 2 (Vision Analyzer data)');  %%%% get the directory name of group 2 via directory dialog box 


SavePath   = uigetdir([],'Path to store the results');  %%%% get the directory name of saving-results path via directory dialog box

eeglab

Group1Index = [];
Group2Index = [];


DirGroup1 = dir(fullfile(Group1Dir,'*.vhdr'));
DirGroup2 = dir(fullfile(Group2Dir,'*.vhdr'));

FileNamesGroup1 = {DirGroup1.name};
FileNamesGroup2 = {DirGroup2.name};

% Read the data from group 1
for f = 1:numel(FileNamesGroup1)
    EEG = pop_fileio(fullfile(Group1Dir,FileNamesGroup1{f}));   % Basic file read
    EEG = eeg_RejectBABadIntervals( EEG);   % Get rid of bad intervals
    setname = strrep(FileNamesGroup1{f},'.vhdr',''); % Set a useful name of the dataset (i.e, remove the string '.vhdr')
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',FileNamesGroup1{f},'gui','off'); % And make this a new set
    EEG = pop_chanedit(EEG, 'lookup',fullfile(DipFitPath,'standard_BESA','standard-10-5-cap385.elp')); % Add the channel positions
    EEG = pop_reref( EEG, []); % Make things average reference
    EEG = pop_eegfiltnew(EEG, 2, 20, 424, 0, [], 0); % And bandpass-filter 2-20Hz
    EEG.group = 'Group1'; % Set the group (will appear in the statistics output)
    ALLEEG = eeg_store(ALLEEG, EEG, CURRENTSET); % Store the thing
    Group1Index = [Group1Index CURRENTSET]; % And keep track of the groups
end
% Now the same for group 2
for f = 1:numel(FileNamesGroup2)
    EEG = pop_fileio(fullfile(Group1Dir,FileNamesGroup2{f}));
    EEG = eeg_RejectBABadIntervals( EEG);
    setname = strrep(FileNamesGroup1{f},'.vhdr','');
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',FileNamesGroup1{f},'gui','off');
    EEG = pop_chanedit(EEG, 'lookup',fullfile(DipFitPath,'standard_BESA','standard-10-5-cap385.elp'));    
    EEG = pop_reref( EEG, []);
    EEG = pop_eegfiltnew(EEG, 2, 20, 424, 0, [], 0);
    EEG.group = 'Group2';
    ALLEEG = eeg_store(ALLEEG, EEG, CURRENTSET);
    Group2Index = [Group2Index CURRENTSET];
end

AllSubjects = [Group1Index Group2Index];

eeglab redraw
%% Cluster the stuff
% Define the parameters for clustering
ClustPars = struct('MinClasses',3,'MaxClasses',6,'GFPPeaks',true,'IgnorePolarity',true,'MaxMaps',inf,'Restarts',20', 'UseAAHC',true);

% Loop across all subjects to identify the individual clusters
for i = 1:numel(AllSubjects ) 
    tmpEEG = eeg_retrieve(ALLEEG,AllSubjects (i)); % the EEG we want to work with
    fprintf(1,'Clustering dataset %s (%i/%i)\n',tmpEEG.setname,i,numel(AllSubjects )); % Some info for the impatient user
    tmpEEG = pop_FindMSTemplates(tmpEEG, ClustPars); % This is the actual clustering within subjects
    ALLEEG = eeg_store(ALLEEG, tmpEEG, AllSubjects (i)); % Done, we just need to store this
end

eeglab redraw

%% Now we combine the microstate maps across subjects and edit the mean
% The mean of group1
EEG = pop_CombMSTemplates(ALLEEG, Group1Index, 0, 0, 'GrandMean Group1');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % and store it
GrandMeanG1Index = CURRENTSET; % And keep track of it

% Same for group 2
EEG = pop_CombMSTemplates(ALLEEG, Group2Index, 0, 0, 'GrandMean Group2');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % , store it
GrandMeanG2Index = CURRENTSET; % and keep track of it

% Now we want the grand-grand mean, based on the two group means
EEG = pop_CombMSTemplates(ALLEEG, [GrandMeanG1Index GrandMeanG2Index], 1, 0, 'GrandGrandMean');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG] = pop_ShowIndMSMaps(EEG, 4, 1, ALLEEG); % Here, we go interactive to allow the user to put the classes in the canonical order
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % , we store it
GrandGrandMeanIndex = CURRENTSET; % and keep track of it

eeglab redraw
%% And we sort things out over means and subjects
% First, the sequence of the two group means has be adjusted based on the
% grand grand mean
ALLEEG = pop_SortMSTemplates(ALLEEG, [GrandMeanG1Index GrandMeanG2Index], 1, GrandGrandMeanIndex);

% Then, we sort the individuals based on their group means
ALLEEG = pop_SortMSTemplates(ALLEEG, Group1Index, 0, GrandMeanG1Index); % Group 1
ALLEEG = pop_SortMSTemplates(ALLEEG, Group2Index, 0, GrandMeanG2Index); % Group 2

eeglab redraw
%% eventually save things
for f = 1:numel(ALLEEG)
    EEG = eeg_retrieve(ALLEEG,f);
    fname = [EEG.setname,'.vhdr'];
    pop_saveset( EEG, 'filename',fname,'filepath',SavePath);
end

%% Visualize some stuff to see if the fitting parameters appear reasonable
% These are the paramters for the continuous fitting
% FitPars = struct('nClasses',4,'lambda',1,'b',30,'PeakFit',false, 'BControl',true);

% These are the paramters for the fitting based on GFP peaks only
 FitPars = struct('nClasses',4,'lambda',1,'b',30,'PeakFit',true, 'BControl',true);


% Just a look at the first EEG
EEG = eeg_retrieve(ALLEEG,1); 
pop_ShowIndMSDyn([],EEG,0,FitPars);
pop_ShowIndMSMaps(EEG,FitPars.nClasses);

%% Here comes the stats part

% Using the individual templates
pop_QuantMSTemplates(ALLEEG, AllSubjects, 0, FitPars, []                   , fullfile(SavePath,'ResultsFromIndividualTemplates.csv'));

% And using the grand grand mean template
pop_QuantMSTemplates(ALLEEG, AllSubjects, 1, FitPars, GrandGrandMeanIndex, fullfile(SavePath,'ResultsFromGrandGrandMeanTemplate.csv'));


%% Eventually export the individual microstate maps to do statistics in Ragu

nMaps = 4;

Grouping = nan(numel(AllSubjects),1);
Grouping(Group1Index) = 1;
Grouping(Group2Index) = 2;

rd = SaveMSMapsForRagu(ALLEEG(AllSubjects),nMaps,Grouping);

save(fullfile(SavePath,'IndividualMaps.mat'),'rd');