%pop_CombMSTemplates() interactively averages microstate across EEGs
%
% This is not a simple averaging, but a permute and average loop that
% optimizes the order of microstate classes in the individual datasets for
% maximal communality before averaging!
%
% Usage: >> [EEGOUT,com] = pop_CombMSTemplates(ALLEEG, CURRENTSET, DoMeans, ShowWhenDone, MeanSetName)
%
% EEG lab specific:
%
%   "ALLEEG" 
%   -> ALLEEG structure with all the EEGs that may be analysed
%
%   "CURRENTSET" 
%   -> Index of selected EEGs. If more than one EEG is selected, the analysis
%      will be limited to those, if not, the user is asked.
%
%   "DoMeans"
%   -> True if you want to grand-average microstate maps already averaged
%   over datasets, false otherwise. Default is false (no GUI based choice).
%
%   "Show maps when done" / ShowWhenDone
%   -> Show maps when done
%
%   "Name of mean" / MeanSetName
%   -> Name of the new dataset returned by EEGOUT
%
% Output:
%
%   "EEGOUT" 
%   -> EEG structure with the EEG containing the new cluster centers
%
%   "com"
%   -> Command necessary to replicate the computation
%
% Author: Thomas Koenig, University of Bern, Switzerland, 2016
%
% Copyright (C) 2016 Thomas Koenig, University of Bern, Switzerland, 2016
% thomas.koenig@puk.unibe.ch
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEGOUT,com] = pop_CombMSTemplates(ALLEEG, CURRENTSET, DoMeans, ShowWhenDone, MeanSetName)

    if nargin < 3;  DoMeans = false;            end
    if nargin < 4;  ShowWhenDone = false;       end
    if nargin < 5;  MeanSetName = 'GrandMean';  end

    com = '';

    % find the list of all channels, and make sure we have the individual
    % maps with sufficiently identical parameters
    % -------------------------------------------
    if numel(CURRENTSET) == 1 
        nonempty = find(cellfun(@(x) isfield(x,'msinfo'), num2cell(ALLEEG)));
        HasChildren = cellfun(@(x) isfield(x,'children'), {ALLEEG.msinfo});
        if DoMeans == true
            nonempty(~HasChildren) = [];
        else
            nonempty(HasChildren) = [];
        end
        AvailableSets = {ALLEEG(nonempty).setname};
            
        res = inputgui( 'geometry', {1 1 1 1 1 1}, 'geomvert', [1 1 4 1 1 1], 'uilist', { ...
            { 'Style', 'text', 'string', 'Choose sets for averaging'} ...
            { 'Style', 'text', 'string', 'Use ctrlshift for multiple selection'} ...
            { 'Style', 'listbox', 'string', AvailableSets, 'tag','SelectSets' ,'Min', 0, 'Max',2} ...
            { 'Style', 'text', 'string', 'Name of mean', 'fontweight', 'bold'  } ...
            { 'Style', 'edit', 'string', MeanSetName,'tag','MeanName' } ...
            { 'Style', 'checkbox', 'string' 'Show maps when done' 'tag' 'Show_Maps'    ,'Value', ShowWhenDone }});
     
        if isempty(res); return; end
        MeanSetName = res{2};
        SelectedSet = nonempty(res{1});
        ShowWhenDone = res{3};
    else
        if nargin < 5
            res = inputgui( 'geometry', {1 1 1}, 'geomvert', [1 1 1], 'uilist', { ...
                { 'Style', 'text', 'string', 'Name of mean', 'fontweight', 'bold'  } ...
                { 'Style', 'edit', 'string', MeanSetName,'tag','MeanName' } ...
                { 'Style', 'checkbox', 'string' 'Show maps when done' 'tag' 'Show_Maps'    ,'Value', ShowWhenDone }});
        
            if isempty(res); return; end
    
            MeanSetName = res{1};
            ShowWhenDone = res{2};
        end    
        SelectedSet = CURRENTSET;
    end

    if numel(SelectedSet) < 2
        errordlg2('You must select at least two sets of microstate maps','Combine microstate maps');
        return;
    end

    if ~isfield(ALLEEG(SelectedSet(1)),'msinfo')
        errordlg2(sprintf('Microstate info not found in dataset %',ALLEEG(SelectedSet(1)).setname), 'Combine microstate maps');
        return;
    end

    MinClasses     = ALLEEG(SelectedSet(1)).msinfo.ClustPar.MinClasses;
    MaxClasses     = ALLEEG(SelectedSet(1)).msinfo.ClustPar.MaxClasses;
    IgnorePolarity = ALLEEG(SelectedSet(1)).msinfo.ClustPar.IgnorePolarity;
    GFPPeaks       = ALLEEG(SelectedSet(1)).msinfo.ClustPar.GFPPeaks;
    
    allchans  = { };
    children  = cell(length(SelectedSet),1);
    keepindex = 0;

    for index = 1:length(SelectedSet)
        if ~isfield(ALLEEG(SelectedSet(index)),'msinfo')
            errordlg2(sprintf('Microstate info not found in dataset %',ALLEEG(SelectedSet(index)).setname), 'Combine microstate maps'); 
            return;
        end
    
        if  MinClasses     ~= ALLEEG(SelectedSet(index)).msinfo.ClustPar.MinClasses || ...
            MaxClasses     ~= ALLEEG(SelectedSet(index)).msinfo.ClustPar.MaxClasses || ...
            IgnorePolarity ~= ALLEEG(SelectedSet(index)).msinfo.ClustPar.IgnorePolarity || ...
            GFPPeaks       ~= ALLEEG(SelectedSet(index)).msinfo.ClustPar.GFPPeaks;
            errordlg2('Microstate parameters differ between datasets','Combine microstate maps');
            return;
        end
    
        children(index) = {ALLEEG(SelectedSet(index)).setname};
        tmpchanlocs = ALLEEG(SelectedSet(index)).chanlocs;
        tmpchans = { tmpchanlocs.labels };
        allchans = unique_bc([ allchans {tmpchanlocs.labels}]);

        if length(allchans) == length(tmpchans)
            keepindex = index;
        end;
    end;
    if keepindex
        tmpchanlocs = ALLEEG(SelectedSet(keepindex)).chanlocs; 
    %    allchans = { tmpchanlocs.labels }; 
    end;

    % Ready to go, it seems. Now we create a matrix of subject x classes x
    % channels

    msinfo.children = children;
    msinfo.ClustPar   = ALLEEG(SelectedSet(1)).msinfo.ClustPar;
    for n = MinClasses:MaxClasses
        MapsToSort = nan(numel(SelectedSet),n,numel(tmpchanlocs));
        % Here we go to the common set of channels
        for index = 1:length(SelectedSet)
            dummy.data     = ALLEEG(SelectedSet(index)).msinfo.MSMaps(n).Maps;
            dummy.chanlocs = ALLEEG(SelectedSet(index)).chanlocs;
            out = pop_interp(dummy,tmpchanlocs,'spherical');
            MapsToSort(index,:,:) = out.data;
        end
    % We sort out the stuff
        BestMeanMap = PermutedMeanMaps(MapsToSort,~IgnorePolarity);
%       BestMeanMap = PermutedMeanMaps(MapsToSort,~IgnorePolarity,tmpchanlocs); % debugging only
        msinfo.MSMaps(n).Maps = BestMeanMap;
        msinfo.MSMaps(n).ColorMap = lines(n);
        msinfo.MSMaps(n).SortedBy = 'none';
        msinfo.MSMaps(n).SortMode = 'none';
    end
    
    EEGOUT = eeg_emptyset();
    EEGOUT.chanlocs = tmpchanlocs;
    EEGOUT.data = zeros(numel(EEGOUT.chanlocs),MaxClasses,MaxClasses);
    EEGOUT.msinfo = msinfo;
    
    for n = MinClasses:MaxClasses
        EEGOUT.data(:,1:n,n) = msinfo.MSMaps(n).Maps';
    end
    
    EEGOUT.setname     = MeanSetName;
    EEGOUT.nbchan      = size(EEGOUT.data,1);
    EEGOUT.trials      = size(EEGOUT.data,3);
    EEGOUT.pnts        = size(EEGOUT.data,2);
    EEGOUT.srate       = 1;
    EEGOUT.xmin        = 1;
    EEGOUT.times       = 1:EEGOUT.pnts;
    EEGOUT.xmax        = EEGOUT.times(end);

    txt = sprintf('%i ',SelectedSet);
    txt(end) = [];
    com = sprintf('[EEG, com] = pop_CombMSTemplates(%s, [%s], %i, %i, ''%s'');',inputname(1),txt,DoMeans,ShowWhenDone,MeanSetName);

    if ShowWhenDone == true
        pop_ShowIndMSMaps(EEGOUT);
    end
end

