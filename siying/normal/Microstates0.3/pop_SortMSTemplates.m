%pop_SortMSTemplates() Reorder microstate maps based on a mean template
%
% Usage: >> [ALLEEG,com] = pop_SortMSTemplates(ALLEEG,CURRENTSET, DoMeans, TemplateSet)
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
%   "Name of mean" / TemplateSet
%   -> Index of the ALLEEG element with the dataset used as a template for sorting
%
% Output:
%
%   "ALLEEG" 
%   -> ALLEEG structure with all the updated EEGs
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
%
function [ALLEEG,com] = pop_SortMSTemplates(ALLEEG,CURRENTSET, DoMeans, TemplateSet)

    com = '';
    
%    if numel(EEG) > 1
%        errordlg2('pop_findMSTemplates() currently supports only a single EEG as input');
%        return;
%    end
    
    if nargin < 3;  DoMeans = false;            end
    
    nonempty = find(cellfun(@(x) isfield(x,'msinfo'), num2cell(ALLEEG)));
    HasChildren = cellfun(@(x) isfield(x,'children'), {ALLEEG.msinfo});
    nonemptyInd  = nonempty(~HasChildren);
    nonemptyMean = nonempty(HasChildren);
    
    if numel(nonemptyMean) < 1
        errordlg2('No mean templates found','Sort microstate classes');
        return;
    end
    
    if nargin < 4;  TemplateSet = nonemptyMean(1); end
    MeanIndex = find(nonemptyMean == TemplateSet,1);

    
    if numel(CURRENTSET) == 1 
        if DoMeans == true
            AvailableSets = {ALLEEG(nonemptyMean).setname};
        else
            AvailableSets = {ALLEEG(nonemptyInd).setname};
        end
  
        res = inputgui( 'geometry', {1 1 1 1 1}, 'geomvert', [1 1 4 1 1], 'uilist', { ...
            { 'Style', 'text', 'string', 'Choose sets for sorting'} ...
            { 'Style', 'text', 'string', 'Use ctrlshift for multiple selection'} ...
            { 'Style', 'listbox', 'string', AvailableSets, 'tag','SelectSets' ,'Min', 0, 'Max',2} ...
            { 'Style', 'text', 'string', 'Name of mean', 'fontweight', 'bold'  } ...
            { 'Style', 'popupmenu', 'string', {ALLEEG(nonemptyMean).setname},'tag','MeanName','Value',MeanIndex} ...
            });
     
        if isempty(res); return; end
        TemplateSet = nonemptyMean(res{2});
        if DoMeans == true
            SelectedSet = nonemptyMean(res{1});
        else
            SelectedSet = nonemptyInd(res{1});
        end
    else
        if nargin < 4
            res = inputgui( 'geometry', {1 1}, 'geomvert', [1 1], 'uilist', { ...
                { 'Style', 'text', 'string', 'Name of mean', 'fontweight', 'bold'  } ...
                { 'Style', 'popupmenu', 'string', {ALLEEG(nonemptyMean).setname},'tag','MeanName' ,'Value',MeanIndex } ...
                });
        
            if isempty(res); return; end
            TemplateSet = nonemptyMean(res{1});
        end    
        SelectedSet = CURRENTSET;
    end

    if numel(SelectedSet) < 2
        errordlg2('You must select at least two sets of microstate maps','Sort microstate classes');
        return
    end

    MinClasses     = ALLEEG(TemplateSet).msinfo.ClustPar.MinClasses;
    MaxClasses     = ALLEEG(TemplateSet).msinfo.ClustPar.MaxClasses;
    IgnorePolarity = ALLEEG(TemplateSet).msinfo.ClustPar.IgnorePolarity;
    GFPPeaks       = ALLEEG(TemplateSet).msinfo.ClustPar.GFPPeaks;
    
    for index = 1:length(SelectedSet)
        sIndex = SelectedSet(index);
        if ~isfield(ALLEEG(sIndex),'msinfo')
            errordlg2(sprintf('Microstate info not found in datset %s',ALLEEG(sIndex).setname),'Sort microstate classes'); 
            return;
        end
    
        if  MinClasses     ~= ALLEEG(sIndex).msinfo.ClustPar.MinClasses || ...
            MaxClasses     ~= ALLEEG(sIndex).msinfo.ClustPar.MaxClasses || ...
            IgnorePolarity ~= ALLEEG(sIndex).msinfo.ClustPar.IgnorePolarity || ...
            GFPPeaks       ~= ALLEEG(sIndex).msinfo.ClustPar.GFPPeaks;
                errordlg2('Microstate parameters differ between datasets','Sort microstate classes');
                return;
        end
    end

    for n = MinClasses:MaxClasses
        MapsToSort = nan(numel(SelectedSet),n,numel(ALLEEG(TemplateSet).chanlocs));
        % Here we go to the common set of channels
        for index = 1:length(SelectedSet)
            sIndex = SelectedSet(index);

            dummy.data     = ALLEEG(sIndex).msinfo.MSMaps(n).Maps;
            dummy.chanlocs = ALLEEG(sIndex).chanlocs;
 
            out = pop_interp(dummy,ALLEEG(TemplateSet).chanlocs,'spherical');
        
            MapsToSort(index,:,:) = out.data;
        end
        % We sort out the stuff
        BestSortedMaps = ArrangeMapsBasedOnMean(MapsToSort,ALLEEG(TemplateSet).msinfo.MSMaps(n).Maps,~IgnorePolarity);

        %   And we go back to the original channel order
         for index = 1:length(SelectedSet)
            sIndex = SelectedSet(index);

            dummy.data = squeeze(BestSortedMaps(index,:,:));
            dummy.chanlocs = ALLEEG(TemplateSet).chanlocs;
         
            out = pop_interp(dummy,ALLEEG(sIndex).chanlocs,'spherical');
         
            ALLEEG(sIndex).msinfo.MSMaps(n).Maps = out.data;
            ALLEEG(sIndex).msinfo.MSMaps(n).ColorMap = ALLEEG(TemplateSet).msinfo.MSMaps(n).ColorMap;
            ALLEEG(sIndex).msinfo.MSMaps(n).SortMode = 'template based';
            ALLEEG(sIndex).msinfo.MSMaps(n).SortedBy = [ALLEEG(TemplateSet).msinfo.MSMaps(n).SortedBy '->' ALLEEG(TemplateSet).setname];
         end
    end
    
    txt = sprintf('%i ',SelectedSet);
    txt(end) = [];
    
    com = sprintf('[%s com] = pop_SortMSTemplates(%s, [%s], %i, %i);', inputname(1),inputname(1), txt, DoMeans, TemplateSet); 
end
