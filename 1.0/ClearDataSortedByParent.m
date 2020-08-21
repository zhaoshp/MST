%ClearDataSortedByParent() Attempts to clear previous sorting information
%
% Usage:
%   >> ALLEEG = ClearDataSortedByParent(ALLEEG, Children, ClassIndex)
%
% Inputs:
%
%   "ALLEEG" 
%   -> ALLEEG structure with all the EEGs that may be analysed
%
%   "Children"
%   -> Name of the datasets in the ALLEEG structure that should have the
%      sorting information cleared. If the dataset is not found, a warning
%      is issued.
%
%   "ClassIndex"
%   -> Array of numbers of microstate cluster sizes to be cleared (default = all)
%
% Output:
%
%   "ALLEEG" 
%   -> ALLEEG structure with all the updated EEGs
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
function ALLEEG = ClearDataSortedByParent(ALLEEG, Children, ClassIndex)
    
    if isempty(Children)
        return;
    end
    
    for c = 1:numel(Children)
        ToBeCleared = find(strcmp(Children{c},{ALLEEG.setname}));
        if isempty(ToBeCleared)
            fprintf(1,'Could not find %s for clearing sorting information\n',Children{c});
        end
    
        for i = 1:numel(ToBeCleared)
            sIdx = ToBeCleared(i);
            if nargin < 3
                ClassIndex = ALLEEG(sIdx).msinfo.ClustPar.MinClasses:ALLEEG(sIdx).msinfo.ClustPar.MaxClasses;
            end
            for n = 1:numel(ClassIndex)
                ALLEEG(sIdx).msinfo.MSMaps(ClassIndex(n)).SortedBy = [];
                ALLEEG(sIdx).msinfo.MSMaps(ClassIndex(n)).SortMode = 'none';
            end
            disp(['MS sorting info cleared from ' ALLEEG(sIdx).setname]);
            
            ALLEEG(sIdx).saved = 'no';
            
            if isfield(ALLEEG(sIdx).msinfo,'children')
                ALLEEG = ClearDataSortedByParent(ALLEEG,ALLEEG(sIdx).msinfo.children);
            end
        end    
    end
end