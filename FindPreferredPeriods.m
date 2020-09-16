function [pref_values, pref_std] = FindPreferredPeriods(activity, lever_feature_trace, all_binary_traces, chosen_lag)

if iscell(activity)
    for i = 1:length(activity)
        for sp = 1:size(activity{i},1)
            act_starts = find(diff([activity{i}(sp,1), activity{i}(sp,:)])>0)+chosen_lag;
            act_starts = act_starts(act_starts>0);
            act_starts = act_starts(act_starts<length(activity{i}(sp,:)));
            act_starts = act_starts(logical(all_binary_traces{i}(act_starts)));
            preferred_values = lever_feature_trace{i}(act_starts);
            pref_values{i}(sp) = nanmedian(preferred_values);
            pref_std{i}(sp) = nanstd(preferred_values);
        end
    end
else
    for sp = 1:size(activity,1)
        act_starts = find(diff([activity(sp,1), activity(sp,:)])>0)+chosen_lag;
        act_starts = act_starts(act_starts>0);
        act_starts = act_starts(act_starts<length(activity(sp,:)));
        act_starts = act_starts(all_binary_traces(act_starts));
        preferred_values = lever_feature_trace(act_starts);
        pref_values(sp) = nanmedian(preferred_values);
        pref_std(sp) = nanstd(preferred_values);
    end
end