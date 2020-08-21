function [MeanMap,SortedMaps,OldMapFit] = PermutedMeanMaps(in,RespectPolarity, Montage)

    if nargin < 3
        debug = false;
    else
        debug = true;
    end

    [nSubjects,nMaps,nChannels] = size(in);

    hndl = waitbar(0,sprintf('Sorting %i maps of %i subjects, please wait...',nMaps,nSubjects));

    in = NormDim(in,3);

    if nargin < 2;  RespectPolarity = false;    end

    MeanMap = nan(nMaps,nChannels);
    
    for i = 1:nMaps
        data = squeeze(in(:,i,:));
        [pc1,~] = eigs(data'*data,1);
        MeanMap(i,:) = NormDimL2(pc1',2);
    end
    
    SortedMaps = in;

    WorkToBeDone = true;

    SubjectIndex = repmat((1:nSubjects)',1,nMaps);
    MapIndex     = repmat((1:nMaps),nSubjects,1);

    SubjectIndex = SubjectIndex(:);
    MapIndex = MapIndex(:);

    cnt = 0;
    OldSubjectIndex = -1;
    OldBadGuy       = -1;
    OldSwappee      = -1;
    MeanMapFit      = -1;
    
    while WorkToBeDone
        cnt = cnt + 1;
        % See how the prototype fits
        MapFit = mean(SortedMaps.*repmat(reshape(MeanMap,[1,nMaps,nChannels]),[nSubjects,1,1]),3);

        if debug == true
            dbfh = figure(1000);
            spidx = 1;
            X = cell2mat({Montage.X});
            Y = cell2mat({Montage.Y});
            Z = cell2mat({Montage.Z});
            for s = 1:nSubjects
                for c = 1:nMaps
                    subplot(nSubjects+1,nMaps,spidx);
                    dspQMap(squeeze(SortedMaps(s,c,:)),[X;Y;Z],'Resolution',5);
                    spidx = spidx+1;
                end
            end
            for c = 1:nMaps
                subplot(nSubjects+1,nMaps,spidx);
                dspQMap(MeanMap(c,:),[X;Y;Z],'Resolution',5);
                spidx = spidx+1;
            end
        end
        
        if ~RespectPolarity;    MapFit = abs(MapFit);    end
        OldMapFit = MeanMapFit;
        MeanMapFit = mean(MapFit(:));
    
        waitbar(MeanMapFit,hndl);
        set(hndl,'Name',sprintf('Mean fit: %f\n',MeanMapFit));
            
        % Find the order of misfit
        [~,Idx] = sort(MapFit(:),'descend');
        WorkToBeDone = false;
        for i = 1:numel(Idx)
            % Do a single swap on the subject / map that fits worst and that
            % benefits from a swap, then stop
            [SwappedMaps, Swappee] = SwapMaps(SortedMaps(SubjectIndex(Idx(i)),:,:),MeanMap,MapIndex(Idx(i)),RespectPolarity);
            if ~isempty(SwappedMaps)
                if debug == true
                    [SubjectIndex(Idx(i)) MapIndex(Idx(i))]
                end
                WorkToBeDone = true;
                % No BackSwap
                if  SubjectIndex(Idx(i)) == OldSubjectIndex && ...
                    MapIndex(Idx(i))     == OldSwappee && ...
                    Swappee              == OldBadGuy
                    if (OldMapFit < MeanMapFit);
                        WorkToBeDone = false;
                    end
                else
                    SortedMaps(SubjectIndex(Idx(i)),:,:) = SwappedMaps;
                    OldSubjectIndex = SubjectIndex(Idx(i));
                    OldSwappee      = Swappee;
                    OldBadGuy       = MapIndex(Idx(i));
                    for k = 1:nMaps
                        data = squeeze(SortedMaps(:,k,:));
                        [pc1,~] = eigs(data'*data,1);
                        MeanMap(k,:) = NormDimL2(pc1',2);
                    end
%                    MeanMap = NormDimL2(MeanMap * (nSubjects -1) + SwappedMaps,2);
                    break;
                end
            end
        end
        if debug == true
            pause
        end
    end
    if debug == true
        disp('Done');
        pause
    end
    for s = 1:size(SortedMaps,1)
        SubMaps = squeeze(SortedMaps(s,:,:));
        for k = 1:size(SortedMaps,2)
            
            if MeanMap(k,:)*SubMaps(k,:)' < 0
                SortedMaps(s,k,:) = -SortedMaps(s,k,:);
            end
        end
    end
    
    OldMapFit = mean(MapFit(:));
    close(hndl);
    if debug == true
        close(dbfh)
    end
    
end

function [Result,MaxFit] = SwapMaps(MapsToSwap,MeanMap,TheBadGuy,RespectPolarity)

    [nMaps,nChannels] = size(MeanMap);
    SwapIndex = repmat(1:nMaps,[nMaps,1]);
    for i = 1:nMaps
        SwapIndex(i,i) = TheBadGuy;
        SwapIndex(i,TheBadGuy) = i;
    end

    MapsToSwap = squeeze(MapsToSwap);
    SwapMat = reshape(MapsToSwap(reshape(SwapIndex,nMaps*nMaps,1),:),[nMaps,nMaps,nChannels]);
    MapFit = mean(SwapMat.*repmat(reshape(MeanMap,[1,nMaps,nChannels]),[nMaps,1,1]),3);

    if ~RespectPolarity
        [~,MaxFit] = max(mean(abs(MapFit),2));
        pol = repmat(sign(MapFit(MaxFit,:))',1,nChannels);
    else
        [~,MaxFit] = max(mean(MapFit,2));
        pol = 1;
    end
    if MaxFit == TheBadGuy
        Result = [];
    else
        Result = squeeze(SwapMat(MaxFit,:,:)).*pol;
    end
end



