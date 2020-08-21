clc;clear;close all;
x_dir = 'E:\zhaoshp\EEG\pre\features2\result_pre';
filename=[x_dir,filesep,'ResultsFromGrandGrandMeanTemplate.csv'];
y_dir = 'E:\zhaoshp\EEG\post\features2\result_post';
filename2=[y_dir,filesep,'ResultsFromGrandGrandMeanTemplate.csv'];
group1=importfile(filename);%自动生成的导入csv文件固定行和列的函数
group1value=table2array(group1);
group2=importfile(filename2);%自动生成的导入csv文件固定行和列的函数
group2value=table2array(group2);
for i=1:size(group1,1)
    [H(i),P(i)]=ttest(group1value(:,i),group2value(:,i));
end
