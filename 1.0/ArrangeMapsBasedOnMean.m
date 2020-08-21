function SortedMaps = ArrangeMapsBasedOnMean(in, MeanMap,RespectPolarity)

    [nSubjects,nMaps,nChannels] = size(in);

    hndl = waitbar(0,sprintf('Sorting %i maps of %i subjects, please wait...',nMaps,nSubjects));

    in = NormDim(in,3);
    if nargin < 2
        MeanMap = [];
    end

    if nargin < 3
        RespectPolarity = false;
    end

    SortedMaps = nan(size(in));


    for n = 1:nSubjects
		MapsToSort = in(n,:,:);
		WorkToBeDone = true;
		while WorkToBeDone
		    WorkToBeDone = false;
            MapFit = mean(MapsToSort.*reshape(MeanMap,[1,nMaps,nChannels]),3);
		    if ~RespectPolarity
		        MapFit = abs(MapFit);
    		end
			[~,Idx] = sort(MapFit(:));
            for i = 1:numel(Idx)
			    SwappedMaps = SwapMaps(MapsToSort,MeanMap,Idx(i),RespectPolarity);
                if ~isempty(SwappedMaps)
		        	MapsToSort(1,:,:) = SwappedMaps;
                    WorkToBeDone = true;
		        	break;
                end
            end
		end
		SortedMaps(n,:,:) = MapsToSort;
    end
    close(hndl);
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



