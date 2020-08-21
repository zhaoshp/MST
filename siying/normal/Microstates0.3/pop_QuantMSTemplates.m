%pop_QuantMSTemplates() quantifies the presence of microstates in EEG data
%
% Usage:
%   >> com = pop_QuantMSTemplates(ALLEEG, CURRENTSET, UseMeanTmpl, FitParameters, MeanSet, FileName)
%
% EEG lab specific:
%
%   "ALLEEG" 
%   -> ALLEEG structure with all the EEGs that may be analysed
%
%   "CURRENTSET" 
%   -> Index of selected EEGs. If more than one EEG is selected, the analysis
%      will be limited to those, if not, the user is asked
%
% Graphical interface / input parameters
%
%   UseMeanTmpl
%   -> True if a mean cluster center is to be used to quantify the EEG
%   data, false if the template from the data itself is to be used
%
%   FitParameters 
%   -> A struct with the following parameters:
%      - nClasses: The number of classes to fit
%      - PeakFit : Whether to fit only the GFP peaks and interpolate in
%        between (true), or fit to the entire data (false)
%      - b       : Window size for label smoothing (0 for none)
%      - lambda  : Penalty function for non-smoothness
%
%   "Name of Mean" (only for the GUI)
%   -> EEG dataset containing the mean clusters to be used if UseMeanTmpl
%   is true, else not relevant
%
%   Meanset
%   -> Index of the ALLEEG dataset containing the mean clusters to be used if UseMeanTmpl
%   is true, else not relevant
%   Filename
%   -> Name of the file to store the output. You can store CSV files of
%   Matlab files
%
% Output:
%
%   "com"
%   -> Command necessary to replicate the computation
%              %
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

function com = pop_QuantMSTemplates(ALLEEG, CURRENTSET, UseMeanTmpl, FitParameters, MeanSet, FileName)

    if nargin < 2,  CURRENTSET    = [];     end   
    if nargin < 3,  UseMeanTmpl   = false;  end
    if nargin < 4,  FitParameters = [];     end 
    if nargin < 5,  MeanSet       = [];     end 

    com = '';
    if nargin < 3
        ButtonName = questdlg('What type of templates do  you want to use?', ...
                         'Microstate statistics', ...
                         'Sorted individual maps', 'Averaged maps', 'Sorted individual maps');
        switch ButtonName,
            case 'Individual maps',
                UseMeanTmpl = false;
            case 'Averaged maps',
                UseMeanTmpl = true;
        end % switch
    end 
    
    nonempty = find(cellfun(@(x) isfield(x,'msinfo'), num2cell(ALLEEG)));
    HasChildren = cellfun(@(x) isfield(x,'children'), {ALLEEG.msinfo});
    nonemptyInd  = nonempty(~HasChildren);
    nonemptyMean = nonempty(HasChildren);
    
    AvailableMeans = {ALLEEG(nonemptyMean).setname};
    AvailableSets  = {ALLEEG(nonemptyInd).setname};
    
    if numel(CURRENTSET) > 1
        SelectedSet = CURRENTSET;
    
        if UseMeanTmpl == true && isempty(MeanSet) 
            disp('UseMeanTemplate')
            res = inputgui( 'geometry', {1 1}, 'geomvert', [1 1], 'uilist', { ...
                { 'Style', 'text', 'string', 'Name of mean', 'fontweight', 'bold'  } ...
                 { 'Style', 'listbox', 'string', AvailableMeans, 'tag','SelectSets'}});
     
            if isempty(res)
                return
            end
            MeanSet = nonemptyMean(res{1});
        end
    else
        if UseMeanTmpl == true && isempty(MeanSet)
            res = inputgui( 'geometry', {1 1 1 1 1 1}, 'geomvert', [1 1 4 1 1 4], 'uilist', { ...
                { 'Style', 'text', 'string', 'EEGs to analyze', 'fontweight', 'bold' } ...    
                { 'Style', 'text', 'string', 'Use ctrlshift for multiple selection'} ...
                { 'Style', 'listbox', 'string', AvailableSets, 'tag','SelectSets' ,'Min', 0, 'Max',2} ...
                { 'Style', 'text', 'string', ''} ...
                { 'Style', 'text', 'string', 'Name of mean', 'fontweight', 'bold'  } ...
                { 'Style', 'listbox', 'string', AvailableMeans, 'tag','SelectSets'}});
     
            if isempty(res)
                return
            end
            SelectedSet = nonemptyInd(res{1});
            MeanSet     = nonemptyMean(res{2});
        else
            if isempty(CURRENTSET)
               res = inputgui( 'geometry', {1 1 1}, 'geomvert', [1 1 4], 'uilist', { ...
                    { 'Style', 'text', 'string', 'EEGs to analyze', 'fontweight', 'bold' } ...    
                    { 'Style', 'text', 'string', 'Use ctrlshift for multiple selection'} ...
                    { 'Style', 'listbox', 'string', AvailableSets, 'tag','SelectSets' ,'Min', 0, 'Max',2} ...
                    });
     
                if isempty(res)
                    return
                end
                SelectedSet = nonemptyInd(res{1});
            else
                SelectedSet = CURRENTSET;
            end
        end
    end
    
    AllSets = [SelectedSet MeanSet];
    MinClasses = max(cellfun(@(x) ALLEEG(x).msinfo.ClustPar.MinClasses,num2cell(AllSets)));
    MaxClasses = min(cellfun(@(x) ALLEEG(x).msinfo.ClustPar.MaxClasses,num2cell(AllSets)));
    
    if UseMeanTmpl == false
        if isfield(ALLEEG(SelectedSet(1)).msinfo,'FitPar');     par = ALLEEG(SelectedSet(1)).msinfo.FitPar;
        else par = [];
        end
    else
        if isfield(ALLEEG(MeanSet).msinfo,'FitPar');            par = ALLEEG(MeanSet).msinfo.FitPar;
        else par = [];
        end
    end
    
    [par,paramsComplete] = UpdateFitParameters(FitParameters,par,{'nClasses','lambda','PeakFit','b', 'BControl'});
 
    if ~paramsComplete
        par = SetFittingParameters(MinClasses:MaxClasses,par);
    end
    
%    MSStats = table();
    
    h = waitbar(0);
    set(h,'Name','Quantifying microstates, please wait...');
    set(findall(h,'type','text'),'Interpreter','none');

%    MSStats(numel(SelectedSet)).DataSet = '';
    
    for s = 1:numel(SelectedSet)
        sIdx = SelectedSet(s);
        waitbar((s-1) / numel(SelectedSet),h,sprintf('Working on %s',ALLEEG(sIdx).setname),'Interpreter','none');
        DataInfo.subject   = ALLEEG(sIdx).subject;
        DataInfo.group     = ALLEEG(sIdx).group;
        DataInfo.condition = ALLEEG(sIdx).condition;
        DataInfo.setname   = ALLEEG(sIdx).setname;
        
        if UseMeanTmpl == false
            Maps = ALLEEG(sIdx).msinfo.MSMaps(par.nClasses).Maps;
            ALLEEG(sIdx).msinfo.FitPar = par;
            [MSClass,~,ExpVar] = AssignMStates(ALLEEG(sIdx),Maps,par,ALLEEG(sIdx).msinfo.ClustPar.IgnorePolarity);
            if ~isempty(MSClass)
 %              MSStats = [MSStats; QuantifyMSDynamics(MSClass,ALLEEG(sIdx).msinfo,ALLEEG(sIdx).srate, DataInfo, '<<own>>')];
                MSStats(s) = QuantifyMSDynamics(MSClass,ALLEEG(sIdx).msinfo,ALLEEG(sIdx).srate, DataInfo, '<<own>>',ExpVar);
            end
        else
            Maps = ALLEEG(MeanSet).msinfo.MSMaps(par.nClasses).Maps;
            ALLEEG(sIdx).msinfo.FitPar = par;
            [MSClass,~,ExpVar] = AssignMStates(ALLEEG(sIdx),Maps,par, ALLEEG(MeanSet).msinfo.ClustPar.IgnorePolarity, ALLEEG(MeanSet).chanlocs);
            if ~isempty(MSClass)
%                MSStats = [MSStats; QuantifyMSDynamics(MSClass,ALLEEG(sIdx).msinfo,ALLEEG(sIdx).srate, DataInfo, ALLEEG(MeanSet).setname)]; 
                MSStats(s) = QuantifyMSDynamics(MSClass,ALLEEG(sIdx).msinfo,ALLEEG(sIdx).srate, DataInfo, ALLEEG(MeanSet).setname, ExpVar);
            end
        end
    end
    close(h);
    idx = 1;
    if nargin < 6
        [FName,PName,idx] = uiputfile({'*.csv','Comma separated file';'*.csv','Semicolon separated file';'*.txt','Tab delimited file';'*.mat','Matlab Table'},'Save microstate statistics');
        FileName = fullfile(PName,FName);
    else
        if ~isempty(strfind(FileName,'.mat'))
            idx = 2;
        end
    end

%       writetable(MSStats,FileName);

    switch idx
        case 1
            SaveStructToTable(MSStats,FileName,',');
        case 2
            SaveStructToTable(MSStats,FileName,';');
        case 3
            SaveStructToTable(MSStats,FileName,sprintf('\t'));

        case 4
            save(FileName,'MSStats');
    end
    
    txt = sprintf('%i ',SelectedSet);
    txt(end) = [];

    com = sprintf('com = pop_QuantMSTemplates(%s, [%s], %i, %s, %i, ''%s'');', inputname(1), txt, UseMeanTmpl, struct2String(par), MeanSet, FileName);
end
