function AlphaHistogram(varargin)

foldertouse = 'E:\ActivitySummary';
cd(foldertouse)


Alphas = [];
for i = 1:length(varargin)
    files = fastdir(cd, varargin{i}, {'ZSeries', 'Poly'});
    for f = 1:length(files)
        load(files{f})
        fname = files{f}(1:end-4);
        eval(['Alphas = [Alphas, cell2mat(cellfun(@(x) x(2,:),', fname, '.Alphas, ''uni'', false))];'])
        clear(fname)
    end
end

figure; histogram(Alphas)