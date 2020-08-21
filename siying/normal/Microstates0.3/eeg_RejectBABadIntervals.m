%eeg_RejectBABadIntervals() - Removes periods marked as "Bad Interval" in BV
%                             files from the data
%
% Usage:
%   >> EEG = eeg_RejectBABadIntervals( EEG)
%
% Where EEG is an eeglab EEG structure
%
% The function assumes that bad intervals are indivated by urevents with
% the value "Bad Intervals".
%
% For removal of the bad intervals, the function eeg_eegrej() is used.
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
function EEG = eeg_RejectBABadIntervals(EEG)
    regions = [];
    for i = 1:numel(EEG.urevent)
        if strcmp(EEG.urevent(i).value,'Bad Interval')
            regions = [regions; EEG.urevent(i).latency EEG.urevent(i).latency + EEG.urevent(i).duration - 1];
        end
    end
    EEG = eeg_eegrej( EEG, regions );
end
    




