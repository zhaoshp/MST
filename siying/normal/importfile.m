function ResultsFromGrandGrandMeanTemplate1 = importfile1(filename, startRow, endRow)
%IMPORTFILE1 ���ı��ļ��е���ֵ������Ϊ�����롣
%   RESULTSFROMGRANDGRANDMEANTEMPLATE1 = IMPORTFILE1(FILENAME) ��ȡ�ı��ļ�
%   FILENAME ��Ĭ��ѡ����Χ�����ݡ�
%
%   RESULTSFROMGRANDGRANDMEANTEMPLATE1 = IMPORTFILE1(FILENAME, STARTROW,
%   ENDROW) ��ȡ�ı��ļ� FILENAME �� STARTROW �е� ENDROW ���е����ݡ�
%
% Example:
%   ResultsFromGrandGrandMeanTemplate1 = importfile1('ResultsFromGrandGrandMeanTemplate.csv', 2, 16);
%
%    ������� TEXTSCAN��

% �� MATLAB �Զ������� 2020/08/21 16:05:17

%% ��ʼ��������
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% ����������Ϊ�ı���ȡ:
% �й���ϸ��Ϣ������� TEXTSCAN �ĵ���
formatSpec = '%*s%*s%*s%*s%*s%s%*s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%*s%s%s%s%s%*s%s%s%s%s%*s%s%s%s%s%[^\n\r]';

%% ���ı��ļ���
fileID = fopen(filename,'r');

%% ���ݸ�ʽ��ȡ�����С�
% �õ��û������ɴ˴������õ��ļ��Ľṹ����������ļ����ִ����볢��ͨ�����빤���������ɴ��롣
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% �ر��ı��ļ���
fclose(fileID);

%% ��������ֵ�ı���������ת��Ϊ��ֵ��
% ������ֵ�ı��滻Ϊ NaN��
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]
    % ������Ԫ�������е��ı�ת��Ϊ��ֵ���ѽ�����ֵ�ı��滻Ϊ NaN��
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % ����������ʽ�Լ�Ⲣɾ������ֵǰ׺�ͺ�׺��
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % �ڷ�ǧλλ���м�⵽���š�
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % ����ֵ�ı�ת��Ϊ��ֵ��
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


%% �����������
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

