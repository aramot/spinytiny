function behavior_trials = parse_behavior_bitcode(xsg_trace,xsg_sample_rate,Session)
% seperated from AP_ReadBitCode

if(nargin<2)
    xsg_sample_rate = 10000;
end

ThresholdValue = 2;

num_bits = 12;

BinaryThreshold = xsg_trace>ThresholdValue;
ShiftBinaryThreshold = [NaN; BinaryThreshold(1:end-1)];
% Get raw times for rising edge of signals
rising_bitcode = find(BinaryThreshold==1 & ShiftBinaryThreshold==0);

% hf=gcf;
% d=diff(rising_bitcode);
% figure;hist(d(d<1000),1000);
% figure(hf);

% Set up the possible bits, 12 values, most significant first
bit_values = [num_bits-1:-1:0];
bit_values = 2.^bit_values;

% Find the sync bitcodes: anything where the difference is larger than the
% length of the bitcode (16 ms - set as 20 ms to be safe)
bitcode_time_samples = 200*(xsg_sample_rate/1000);
bitcode_sync = find(diff(rising_bitcode) > bitcode_time_samples);
% Assume that the first rising edge is a sync signal
if isempty(rising_bitcode)
    
    behavior_trials = [];
    
else
    
    bitcode_sync = rising_bitcode([1;bitcode_sync + 1]);
    
    behavior_trials = struct('xsg_sec',cell(length(bitcode_sync),1),...
                             'xsg_sample',cell(length(bitcode_sync),1),...
                             'behavior_trial_num',cell(length(bitcode_sync),1));
    
    % for each bitcode sync, check each bit and record as hi or low
    for curr_bitcode_sync = 1:length(bitcode_sync)
        curr_bitcode = zeros(1,num_bits);
        for curr_bit = 1:num_bits
            % boundaries for bits: between the half of each break
            % (bitcode_sync+5ms+2.5ms = 7.5ms) 2016 Aki
%             bit_boundary_min = bitcode_sync(curr_bitcode_sync) + 7.5*(xsg_sample_rate/1000) + ...
%                 (curr_bit-1)*10.3*(xsg_sample_rate/1000);
%             bit_boundary_max = bitcode_sync(curr_bitcode_sync) + 7.5*(xsg_sample_rate/1000) + ...
%                 (curr_bit)*10.3*(xsg_sample_rate/1000);
            % This should have been 5 ms? 5/1/2018 Aki
            bit_boundary_min = bitcode_sync(curr_bitcode_sync) + ...
                (curr_bit-0.5)*10.3*(xsg_sample_rate/1000);
            bit_boundary_max = bitcode_sync(curr_bitcode_sync) + ...
                (curr_bit+0.5)*10.3*(xsg_sample_rate/1000);
            if any(rising_bitcode > bit_boundary_min & rising_bitcode < bit_boundary_max)
                curr_bitcode(curr_bit) = 1;
                % uncomment this part to report if the window is centered.
                % ideally, they all should be 5050 if completely centered.
                % this reports if the bit is there, how the window is
                % centered. If there are many bits right at the edge, 
                % adjust the parameters above. 5/1/2018 Aki
                i = find(rising_bitcode > bit_boundary_min & rising_bitcode < bit_boundary_max);
                disp([rising_bitcode(i)-bit_boundary_min bit_boundary_max-rising_bitcode(i)]);
            end
        end
        curr_bitcode_trial = sum(curr_bitcode.*bit_values);
        behavior_trials(curr_bitcode_sync).behavior_trial_num = curr_bitcode_trial;
        
        behavior_trials(curr_bitcode_sync).xsg_sample = bitcode_sync(curr_bitcode_sync);
        behavior_trials(curr_bitcode_sync).xsg_sec = bitcode_sync(curr_bitcode_sync)/xsg_sample_rate;
        

        % Catch the rare instance of the xsg file cutting out before the end of the bitcode 
        if bit_boundary_max > length(BinaryThreshold)
            behavior_trials(curr_bitcode_sync) = [];
        end 
    end
    
    % Check here if anything fishy is going on, and warn user
    if any(diff([behavior_trials.behavior_trial_num])~=1) % changed it so that it can detect anything other than increment by 1
        disp(['TRIAL NUMBER WARNING: Nonconsecutive trials']);
        hf=gcf;
        d=diff(rising_bitcode);
        figure;
        subplot(2,1,1);hist(d(d<1000),1000);
        subplot(2,1,2);plot([behavior_trials.behavior_trial_num],'.');
        title(['Bitcode from session ', num2str(Session)])
        figure(hf);
    end
    
    
end