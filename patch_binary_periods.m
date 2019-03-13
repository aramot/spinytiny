function patch_binary_periods(data)

bound = find(diff([Inf; data; Inf])~=0);

v = [];
f = 0;
count = 1;
for i = 2:2:length(bound)
try
v = [v; bound(i), -2; bound(i+1), -2; bound(i+1), 10; bound(i), 10];
f(count,1:4) = 4*(count-1)+1:4*(count-1)+4;
count = count+1;
catch
end
end
patch('Faces', f, 'Vertices', v, 'Facecolor', 'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none')
