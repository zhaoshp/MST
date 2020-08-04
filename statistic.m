clear;clc;


StudyFolder = 'E:\zhaoshp\EEG\features_2';
type='REC';
FilesALL = dir([StudyFolder,'\*','tp1','*']);

x_GEVtotal=[];
x_Gfp=[];
x_Occurence=[];
x_Duration=[];
x_Coverage=[];
x_GEV=[];
x_MspatCorr=[];
x_TP=[];

for issub = 1:length(FilesALL) 
    Subfolder = [StudyFolder '\' FilesALL(issub).name];
    namelist=dir([Subfolder,'\*',type,'*.','mat']);

    len = length(namelist);
    
    for k=1:len
        suf = namelist(k).name;
        load([Subfolder '\' suf]);
%        1.GEVtotal 2.Gfp 3.Occurrence 4.Duration 5.Coverage 6.GEV
%        7.Mspatcorr 8.TP
        x_GEVtotal=[x_GEVtotal results.GEVtotal];
        x_Gfp=[x_Gfp results.Gfp];
        x_Occurence=[x_Occurence results.Occurence];
        x_Duration=[x_Duration results.Duration];
        x_Coverage=[x_Coverage results.Coverage];
        x_GEV=[x_GEV results.GEV];
        x_MspatCorr=[x_MspatCorr results.MspatCorr];
        x_TP=[x_TP results.TP];
        

    end
end
y_GEVtotal=[];
y_Gfp=[];
y_Occurence=[];
y_Duration=[];
y_Coverage=[];
y_GEV=[];
y_MspatCorr=[];
y_TP=[];

FilesALL = dir([StudyFolder,'\*','tp2','*']);
for issub = 1:length(FilesALL) 
    Subfolder = [StudyFolder '\' FilesALL(issub).name];
    namelist=dir([Subfolder,'\*',type,'*.','mat']);

    len = length(namelist);
    
    for k=1:len
        suf = namelist(k).name;
        load([Subfolder '\' suf]);
%        1.GEVtotal 2.Gfp 3.Occurrence 4.Duration 5.Coverage 6.GEV
%        7.Mspatcorr 8.TP
        y_GEVtotal=[y_GEVtotal results.GEVtotal];
        y_Gfp=[y_Gfp results.Gfp];
        y_Occurence=[y_Occurence results.Occurence];
        y_Duration=[y_Duration results.Duration];
        y_Coverage=[y_Coverage results.Coverage];
        y_GEV=[y_GEV results.GEV];
        y_MspatCorr=[y_MspatCorr results.MspatCorr];
        y_TP=[y_TP results.TP];
        

    end
end

num=length(x_GEV);

H_Gfp=[];
H_Occurence=[];
H_Duration=[];
H_Coverage=[];
H_GEV=[];
H_MspatCorr=[];
P_Gfp=[];
P_Occurence=[];
P_Duration=[];
P_Coverage=[];
P_GEV=[];
P_MspatCorr=[];

% for i=1:num
%     1.Gfp 2.Occurence 3.Duration 4.Coverage 5.GEV 6.Mspatcorr
%     
% end
for i=1:4
    
%   p=anova1([x_temp(:,j) y_temp(:,j)]);
    [H_temp,P_temp]=ttest(x_Gfp(i:4:num),y_Gfp(i:4:num));
    H_Gfp(i)=H_temp;
    P_Gfp(i)=P_temp;
    
    [H_temp,P_temp]=ttest(x_Occurence(i:4:num),y_Occurence(i:4:num));
    H_Occurence(i)=H_temp;
    P_Occurence(i)=P_temp;
    
    [H_temp,P_temp]=ttest(x_Duration(i:4:num),y_Duration(i:4:num));
    H_Duration(i)=H_temp;
    P_Duration(i)=P_temp;
    
    [H_temp,P_temp]=ttest(x_Coverage(i:4:num),y_Coverage(i:4:num));
    H_Coverage(i)=H_temp;
    P_Coverage(i)=P_temp;
    
    [H_temp,P_temp]=ttest(x_GEV(i:4:num),y_GEV(i:4:num));
    H_GEV(i)=H_temp;
    P_GEV(i)=P_temp;
    
    [H_temp,P_temp]=ttest(x_MspatCorr(i:4:num),y_MspatCorr(i:4:num));
    H_MspatCorr(i)=H_temp;
    P_MspatCorr(i)=P_temp;
        
end



