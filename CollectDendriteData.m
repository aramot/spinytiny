function DendOutput = CollectDendriteData(varargin)

cd('C:\Users\Komiyama\Desktop\Output Data')

DendOutput = repmat({cell(1,14)},length(varargin),1);

for sample = 1:length(varargin)
    animal = varargin{sample};
    load([animal, '_Correlations'])
    load([animal, '_SpineCorrelationTimecourse'])

    sessions = eval(['~cell2mat(cellfun(@isempty, ' ,animal, '_Correlations, ''uni'', false))']);

    numspines = eval([animal, '_SpineCorrelationTimecourse.NumberofImagedSpines']);

    for i = find(sessions)
        corrheatmap = eval([animal, '_Correlations{', num2str(i), '}.SpineCorrelations']);
        DendTaskCorr{i} = corrheatmap(9+numspines(i)+1:end,1:9);
    end

    DendOutput{sample}(sessions) = cellfun(@(x) x(:,2),DendTaskCorr(logical(sessions)), 'uni', false);
    
    clear([animal, '_Correlations'])
    clear([animal, '_SpineCorrelationTimecourse'])
end