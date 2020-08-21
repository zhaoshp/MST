function[b_model,b_ind,b_loading,exp_var] = eeg_kMeans(eeg,n_mod,reruns,max_n,flags)
% EEG_MOD Create the EEG model I'm working with
%
% function[b_model,b_ind,b_loading,exp_var] = eeg_mod_r(eeg,n_mod,reruns,max_n)

% input arguments
% eeg = the input data (number of time instances * number of channels)
% n_mod = the number of microstate clusters that you want to extract
% reruns = the number of reiterations (use about 20)
% max_n = maximum number of eeg timepoints used for cluster indentification

% output arguments
% b_model = cluster centers (microstate topographies)
% b_ind = cluster assignment for each moment of time
% b_loading = Amplitude of the assigned cluster at each moment in time
% exp_var = explained variance of the model


if (size(n_mod,1) ~= 1)
	error('Second argument must be a scalar')
end

if (size(n_mod,2) ~= 1)
	error('Second argument must be a scalar')
end

[n_frame,n_chan] = size(eeg);

if nargin < 3
    reruns = 1;
end

if nargin < 4
    max_n = n_frame;
end

if isempty(max_n)
    max_n = n_frame;
end

if (max_n > n_frame)
    max_n = n_frame;
end

if isempty(strfind(flags,'p'))
    pmode = 0;
else
    pmode = 1;
end
eeg = NormDimL2(eeg,2) / sqrt(n_chan);

org_data = eeg;
best_fit = 0;

newRef = eye(n_chan);
if strfind(flags,'a')
    newRef = newRef -1/n_chan;
end
eeg = eeg*newRef;									% Average reference of data 

eeg = NormDim(eeg,2);

if strfind(flags,'b')
    h = waitbar(0,sprintf('Computing %i clusters, please wait...',n_mod));
else
    h = [];
    nSteps = 20;
    step = 0;
    fprintf(1, 'k-means clustering(k=%i): |',n_mod);
    strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '|   0%%']);
    tic
end


for run = 1:reruns
    if isempty(h)
        [step, strLength] = mywaitbar(run, reruns, step, nSteps, strLength);
    else
        t = sprintf('Run: %i / %i',run,reruns);
        set(h,'Name',t);
        waitbar(run/reruns,h);
    end
    if nargin > 3
        idx = randperm(n_frame);
        eeg = org_data(idx(1:max_n),:);
    end

    idx = randperm(max_n);
    model = eeg(idx(1:n_mod),:);
    model   = NormDim(model,2)*newRef;							% Average Reference, equal variance of model

    o_ind   = zeros(max_n,1);							% Some initialization
	ind     =  ones(max_n,1);
	count   = 0;

    while any(o_ind - ind)
        count   = count+1;
        o_ind   = ind;
        if pmode
            covm    = eeg * model';						% Get the unsigned covariance matrix
        else
            covm    = abs(eeg * model');						% Get the unsigned covariance matrix
        end
        [c,ind] =  max(covm,[],2);				            % Look for the best fit

        for i = 1:n_mod
            idx = find (ind == i);
            if pmode
                model(i,:) = mean(eeg(idx,:));
            else
                cvm = eeg(idx,:)' * eeg(idx,:);
                [v,d] = eigs(double(cvm),1);
                model(i,:) = v(:,1)';
            end
        end
		model   = NormDim(model,2)*newRef;						% Average Reference, equal variance of model
        covm    = eeg*model';							% Get the unsigned covariance 
        if pmode
            [c,ind] =  max(covm,[],2);				% Look for the best fit
        else
            [c,ind] =  max(abs(covm),[],2);				% Look for the best fit
        end
    end % while any
    covm    = org_data*model';							% Get the unsigned covariance 
    if pmode
        [loading,ind] =  max(covm,[],2);				% Look for the best fit
    else
        [loading,ind] =  max(abs(covm),[],2);				% Look for the best fit
    end
 
    tot_fit = sum(loading);
    if (tot_fit > best_fit)
        b_model   = model;
        b_ind     = ind;
        b_loading = loading/sqrt(n_chan);
        best_fit  = tot_fit;
        exp_var = sum(b_loading)/sum(std(eeg,1,2));
    end    
end % for run = 1:reruns

if isempty(h)
    mywaitbar(reruns, reruns, step, nSteps, strLength);
    fprintf('\n');
else
    close(h);
end