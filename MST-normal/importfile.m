function ResultsFromGrandGrandMeanTemplate1 = importfile1(filename, startRow, endRow)
%IMPORTFILE1 将文本文件中的数值数据作为矩阵导入。
%   RESULTSFROMGRANDGRANDMEANTEMPLATE1 = IMPORTFILE1(FILENAME) 读取文本文件
%   FILENAME 中默认选定范围的数据。
%
%   RESULTSFROMGRANDGRANDMEANTEMPLATE1 = IMPORTFILE1(FILENAME, STARTROW,
%   ENDROW) 读取文本文件 FILENAME 的 STARTROW 行到 ENDROW 行中的数据。
%
% Example:
%   ResultsFromGrandGrandMeanTemplate1 = importfile1('ResultsFromGrandGrandMeanTemplate.csv', 2, 16);
%
%    另请参阅 TEXTSCAN。

% 由 MATLAB 自动生成于 2020/08/21 16:05:17

%% 初始化变量。
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% 将数据列作为文本读取:
% 有关详细信息，请参阅 TEXTSCAN 文档。
formatSpec = '%*s%*s%*s%*s%*s%s%*s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%*s%s%s%s%s%*s%s%s%s%s%*s%s%s%s%s%[^\n\r]';

%% 打开文本文件。
fileID = fopen(filename,'r');

%% 根据格式读取数据列。
% 该调用基于生成此代码所用的文件的结构。如果其他文件出现错误，请尝试通过导入工具重新生成代码。
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% 关闭文本文件。
fclose(fileID);

%% 将包含数值文本的列内容转换为数值。
% 将非数值文本替换为 NaN。
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]
    % 将输入元胞数组中的文本转换为数值。已将非数值文本替换为 NaN。
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % 创建正则表达式以检测并删除非数值前缀和后缀。
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % 在非千位位置中检测到逗号。
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % 将数值文本转换为数值。
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% 创建输出变量
ResultsFromGrandGrandMeanTemplate1 = table;
ResultsFromGrandGrandMeanTemplate1.ExpVar = cell2mat(raw(:, 1));
ResultsFromGrandGrandMeanTemplate1.TotalTime = cell2mat(raw(:, 2));
ResultsFromGrandGrandMeanTemplate1.Duration_1 = cell2mat(raw(:, 3));
ResultsFromGrandGrandMeanTemplate1.Duration_2 = cell2mat(raw(:, 4));
ResultsFromGrandGrandMeanTemplate1.Duration_3 = cell2mat(raw(:, 5));
ResultsFromGrandGrandMeanTemplate1.Duration_4 = cell2mat(raw(:, 6));
ResultsFromGrandGrandMeanTemplate1.MeanDuration = cell2mat(raw(:, 7));
ResultsFromGrandGrandMeanTemplate1.Occurrence_1 = cell2mat(raw(:, 8));
ResultsFromGrandGrandMeanTemplate1.Occurrence_2 = cell2mat(raw(:, 9));
ResultsFromGrandGrandMeanTemplate1.Occurrence_3 = cell2mat(raw(:, 10));
ResultsFromGrandGrandMeanTemplate1.Occurrence_4 = cell2mat(raw(:, 11));
ResultsFromGrandGrandMeanTemplate1.MeanOccurrence = cell2mat(raw(:, 12));
ResultsFromGrandGrandMeanTemplate1.Contribution_1 = cell2mat(raw(:, 13));
ResultsFromGrandGrandMeanTemplate1.Contribution_2 = cell2mat(raw(:, 14));
ResultsFromGrandGrandMeanTemplate1.Contribution_3 = cell2mat(raw(:, 15));
ResultsFromGrandGrandMeanTemplate1.Contribution_4 = cell2mat(raw(:, 16));
ResultsFromGrandGrandMeanTemplate1.OrgTM_12 = cell2mat(raw(:, 17));
ResultsFromGrandGrandMeanTemplate1.OrgTM_13 = cell2mat(raw(:, 18));
ResultsFromGrandGrandMeanTemplate1.OrgTM_14 = cell2mat(raw(:, 19));
ResultsFromGrandGrandMeanTemplate1.OrgTM_21 = cell2mat(raw(:, 20));
ResultsFromGrandGrandMeanTemplate1.OrgTM_23 = cell2mat(raw(:, 21));
ResultsFromGrandGrandMeanTemplate1.OrgTM_24 = cell2mat(raw(:, 22));
ResultsFromGrandGrandMeanTemplate1.OrgTM_31 = cell2mat(raw(:, 23));
ResultsFromGrandGrandMeanTemplate1.OrgTM_32 = cell2mat(raw(:, 24));
ResultsFromGrandGrandMeanTemplate1.OrgTM_34 = cell2mat(raw(:, 25));
ResultsFromGrandGrandMeanTemplate1.OrgTM_41 = cell2mat(raw(:, 26));
ResultsFromGrandGrandMeanTemplate1.OrgTM_42 = cell2mat(raw(:, 27));
ResultsFromGrandGrandMeanTemplate1.OrgTM_43 = cell2mat(raw(:, 28));

