function [r_lever] = SummarizeLeverPressCorrelations(MovementMat, sessions)

global LeverTracePlots

ns = length(sessions);

%%% Concatenate all the movement traces


total = 0;
for currentsession = 1:ns
    total = total+size(MovementMat{currentsession},1);
end

unused_days = setdiff(sessions(1):sessions(end),sessions);

cat_data = nan(3001,total+length(unused_days));

counter = sessions(1); %%% Start from the first day that was actually used, leave preceding days blank
for i = 1:length(sessions);
    currentsession = sessions(i);
    if size(MovementMat{currentsession},1)
        cat_data(:,counter:counter+size(MovementMat{currentsession},1)-1) = MovementMat{currentsession}';
        counter = counter + size(MovementMat{currentsession},1);
    else 
    end
end

%%% Find the correlation  between individual movements
[r, ~] = corrcoef(cat_data, 'rows', 'pairwise'); %%% The size of 'r' in each dimension should correspond to the number of movements being tracked across all sessions
r(1:1+size(r,1):end) = NaN; %%% Set the diagonal == NaN;

%%% Find the median of each block of data correlations

r_lever = nan(sessions(end),sessions(end));

counter1 = 1;
for currentsession = 1:ns
    session_row = sessions(currentsession);
    temp1 = counter1:counter1+size(MovementMat{session_row},1)-1;
    counter2 = counter1; %%% to step down the diagonal, make counter2 start where counter 1 does!
        for trialnumber = currentsession:ns
            session_column = sessions(trialnumber);
            temp2 = counter2:counter2+size(MovementMat{session_column},1)-1;
            r_lever(session_row,session_column) = nanmedian(reshape(r(temp1,temp2),1,numel(r(temp1,temp2)))); 
            r_lever(session_column,session_row) = nanmedian(reshape(r(temp1,temp2),1,numel(r(temp1,temp2)))); %%% Accounts for the symmetry of heatmaps (only half needs to be calculated, the rest can just be filled in, as done here)
            counter2 = counter2+size(MovementMat{session_column},1);
        end
    counter1 = counter1 + size(MovementMat{session_row},1);
end

r_lever(r_lever == 1) = nan;

if ns<5
    ns = 5;
end
subplot(2,ns, round(ns/2)+2:ns);

imagesc(r_lever);
set(gcf, 'ColorMap', hot)
set(gca, 'CLim', [min(min(r_lever)), max(max(r_lever))])
colorbar
ylabel('Session')
xlabel('Session')
title('Movement correlation over sessions')

scrsz = get(0, 'ScreenSize');

LeverTracePlots.figure2 = figure('Position', scrsz); subplot(2,2,1); plot(diag(r_lever), 'k');
hold on;
plot(diag(r_lever,1),'Color', [0.6 0.6 0.6])
ylabel('Correlations')
xlabel('Session')
legend({'Within sessions', 'Across sessions'})

