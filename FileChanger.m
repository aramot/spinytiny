targdate = '160413';

cd('C:\Users\Komiyama\Desktop\Data Check\MotionCorrectionCheck\')

mkdir(targdate);

cd(['C:\Users\Komiyama\Desktop\Data Check\MotionCorrectionCheck\', targdate])

[fn, ffn, sortkeys] = fastdir(['Z:\People\Nathan\Data\NH006\', targdate], 'summary');

for i = 1:length(ffn)
    copyfile(ffn{i})
end

renamedate = '0331';
count = 1;
for i = 7:length(ffn)

    if ~isempty(strfind(ffn{i}, 'corrected'))
        movefile(fn{i}, sprintf('NH030_0331_001_%03d_corrected.tif', count));
        i
        both = 1;
    elseif ~isempty(strfind(ffn{i}, 'summary'))
        movefile(fn{i}, sprintf('NH030_0331_001_%03d_summary.mat', count));
        i
        both = both+1;
    end
    if both == 2
        count = count+1;
    end
end



