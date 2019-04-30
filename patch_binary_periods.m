function patch_binary_periods(data, varargin)

p = inputParser;

defaultdatamax = 10;
defaultdatamin = -2;
defaultpatchcolor = 'k';

addRequired(p, 'data', @islogical)

addParameter(p, 'datamax', defaultdatamax, @isnumeric)
addParameter(p, 'datamin', defaultdatamin, @isnumeric)
addParameter(p, 'patchcolor', defaultpatchcolor, @ischar)
parse(p, data, varargin{:})

datamax = p.Results.datamax;
datamin = p.Results.datamin;
patchcolor = p.Results.patchcolor;

if size(data,1)>size(data,2)
    bound = find(diff([Inf; data; Inf])~=0);
else
    bound = find(diff([Inf, data, Inf])~=0);
end

v = [];
f = 0;
count = 1;
for i = 2:2:length(bound)
try
    v = [v; bound(i), datamin; bound(i+1), datamin; bound(i+1), datamax; bound(i), datamax];
    f(count,1:4) = 4*(count-1)+1:4*(count-1)+4;
    count = count+1;
catch
end
end
quilt = patch('Faces', f, 'Vertices', v, 'Facecolor', patchcolor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

uistack(quilt, 'bottom')
