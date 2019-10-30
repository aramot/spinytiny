function patch_binary_periods(data, varargin)

p = inputParser;

defaultdatamax = 2;
defaultdatamin = -1;
defaultpatchcolor = 'black';

addRequired(p, 'data')
if ~islogical(data)
    data = logical(data);
end

addParameter(p, 'datamax', defaultdatamax, @isnumeric)
addParameter(p, 'datamin', defaultdatamin, @isnumeric)
addParameter(p, 'patchcolor', defaultpatchcolor)
parse(p, data, varargin{:})

datamax = p.Results.datamax;
datamin = p.Results.datamin;
patchcolor = p.Results.patchcolor;

data = reshape(data, length(data),1);

bound = find(diff([Inf; data; Inf])~=0);

firstpos = find(cellfun(@any, mat2cell(data,diff(bound))),1,'first');

v = [];
f = 0;
count = 1;

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Color Information %%
%%%%%%%%%%%%%%%%%%%%%%%%

lgray = [0.50 0.51 0.52];       brown = [0.28 0.22 0.14];
gray = [0.50 0.51 0.52];        lbrown = [0.59 0.45 0.28];
yellow = [1.00 0.76 0.05];      orange = [0.95 0.40 0.13];
lgreen = [0.45 0.8 0.35];       green = [0.00 0.43 0.23];
lblue = [0.30 0.65 0.94];       blue = [0.00 0.33 0.65];
magenta = [0.93 0.22 0.55];     purple = [0.57 0.15 0.56];
pink = [0.9 0.6 0.6];           lpurple  = [0.7 0.15 1];
red = [0.85 0.11 0.14];         black = [0.1 0.1 0.15];
dred = [0.6 0 0];               dorange = [0.8 0.3 0.03];
bgreen = [0 0.6 0.7];
colorj = {red,lblue,green,lgreen,gray, lgray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown, black};
rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 

eval(['patchcolor = ' patchcolor, ';'])


for i = firstpos:2:length(bound)
    try
        v = [v; bound(i), datamin; bound(i+1), datamin; bound(i+1), datamax; bound(i), datamax];
        f(count,1:4) = 4*(count-1)+1:4*(count-1)+4;
        count = count+1;
    catch
    end
end
quilt = patch('Faces', f, 'Vertices', v, 'Facecolor', patchcolor, 'FaceAlpha', 0.5, 'EdgeColor', 'none');

uistack(quilt, 'bottom')
