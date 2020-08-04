clear;clc;

input_files='H:\ADstudy\EEG\R_MCI_results.mat';
output_dir = 'H:\ADstudy\EEG\';
file_name = 'AD_tp1_results.mat';
file_name2='MCI_results.mat';

load(input_files);
% 1£ºREC   2:REO
results=temp;


% temp=[];
% index = [4,5,8,9,12,13,22,23,29,30,31,32,44,45,60,61,63,64,69,70,71,72,84,85,88,89,92,93,100,101,109,109];
% for i=1:length(index)
%     temp=[temp results(index(i)*2-1)];
%     temp=[temp results(index(i)*2)];
% end
% index = [15,16,17,24,25,26,27,33,34,35,36,40,41,42,43,46,47,50,51,52,53,57,58,66,67,77,78,80,81,94,95,106,107,111];
% for i=1:length(index)
%     temp=[temp results(index(i)*2-1)];
%     temp=[temp results(index(i)*2)];
% end
%tp1 REC
temp1=results(1:4:length(results));
%tp1 REO
temp2=results(2:4:length(results));
%tp2 REC
temp3=results(3:4:length(results));
%tp2 REO
temp4=results(4:4:length(results));
%tp1
temp5=[];
%tp2
temp6=[];
for i=1:4:length(results)
    temp5=[temp5 results(i) results(i+1)];
    temp6=[temp6 results(i+2) results(i+3)];
end
temp=temp1;
save('H:\ADstudy\EEG\MCI_tp1_REC_results.mat','temp');
temp=temp2;
save('H:\ADstudy\EEG\MCI_tp1_REO_results.mat','temp');
temp=temp3;
save('H:\ADstudy\EEG\MCI_tp2_REC_results.mat','temp');
temp=temp4;
save('H:\ADstudy\EEG\MCI_tp2_REO_results.mat','temp');
temp=temp5;
save('H:\ADstudy\EEG\MCI_tp1_results.mat','temp');
temp=temp6;
save('H:\ADstudy\EEG\MCI_tp2_results.mat','temp');
% save([output_dir,file_name],'temp');