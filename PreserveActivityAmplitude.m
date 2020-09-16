function ModifiedTrace = PreserveActivityAmplitude(raw,binary)

data_size = size(raw);
[val, biggest_dim] = max(data_size);
[val, smallest_dim] = min(data_size);

tracelength = data_size(biggest_dim);
numtraces = data_size(smallest_dim);

raw = reshape(raw,numtraces, tracelength);
binary = reshape(binary,numtraces, tracelength);

ModifiedTrace = nan(numtraces,tracelength);

for trace = 1:numtraces
    binary(trace,[1 end]) = 0;
    bounds = find(diff([Inf, binary(trace,:), Inf]~=0));
    bin_divided = mat2cell(binary(trace,:)', diff(bounds));
    raw_divided = mat2cell(raw(trace,:)', diff(bounds));
    active_periods = cellfun(@any, bin_divided);
    all_amplitudes = cellfun(@(x) prctile(x,90), raw_divided(active_periods), 'uni', false);
    all_amps_with_duration = cellfun(@(x,y) y*ones(length(x),1), bin_divided(active_periods), all_amplitudes, 'uni', false);
    newtrace = bin_divided; 
    newtrace(active_periods) = all_amps_with_duration;
    ModifiedTrace(trace,:) = cell2mat(newtrace);
end


