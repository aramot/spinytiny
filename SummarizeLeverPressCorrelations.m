function [r_lever] = SummarizeLeverPressCorrelations(MovementMat, sessions)

global LeverTracePlots

ns = length(sessions);

unused_days = setdiff(sessions(1):sessions(end),sessions);

% % range = length(MovementMat{1});
% % 
% % cat_data = nan(range,totalmovementcount+length(unused_days));
% % minmovementsrequired = 1;
% % 
% % counter = sessions(1); %%% Start from the first day that was actually used, leave preceding days blank
% % for i = 1:length(sessions)
% %     currentsession = sessions(i);
% %     if size(MovementMat{currentsession},1) > minmovementsrequired
% %         cat_data(:,counter:counter+size(MovementMat{currentsession},1)-1) = MovementMat{currentsession}'; %%% Concatenate all movements performed by the animal over all sessions together in one matrix
% %         counter = counter + size(MovementMat{currentsession},1);
% %     else 
% %     end
% % end
% 
sessionswithanymovements = ~cellfun(@isempty, MovementMat);
NumberofMovementsfromEachSession = zeros(1,length(MovementMat));
NumberofMovementsfromEachSession(sessionswithanymovements) = cellfun(@(x) sum(~isnan(x(:,1))), MovementMat(sessionswithanymovements));
MinMovementNumberforConsideration = 10;
SessionsatCriterion = NumberofMovementsfromEachSession>=MinMovementNumberforConsideration;
totalnumberofmovements = sum(NumberofMovementsfromEachSession(SessionsatCriterion));
movementsduration = unique(cellfun(@length, MovementMat)); movementsduration = max(movementsduration);
cat_data = reshape(cell2mat(cellfun(@(x) x(~any(isnan(x),2),:)', MovementMat(SessionsatCriterion), 'uni', false)),movementsduration,totalnumberofmovements);

%%% Find the correlation  between individual movements
[r, ~] = corrcoef(cat_data, 'rows', 'pairwise'); %%% The size of 'r' in each dimension should correspond to the number of movements being tracked across all sessions
r(1:1+size(r,1):end) = NaN; %%% Set the diagonal == NaN;

%%% Find the median of each block of data correlations

r_lever = nan(sessions(end),sessions(end));

% counter1 = 1;
% for currentsession = 1:ns
%     session_row = sessions(currentsession);
%     temp1 = counter1:counter1+size(MovementMat{session_row},1)-1;   %%% List of movement numbers in this session
%     counter2 = counter1; %%% to step down the diagonal, make counter2 start where counter 1 does!
%         for trialnumber = currentsession:ns
%             session_column = sessions(trialnumber);
%             temp2 = counter2:counter2+size(MovementMat{session_column},1)-1;
%             r_lever(session_row,session_column) = nanmedian(reshape(r(temp1,temp2),1,numel(r(temp1,temp2)))); 
%             r_lever(session_column,session_row) = nanmedian(reshape(r(temp1,temp2),1,numel(r(temp1,temp2)))); %%% Accounts for the symmetry of heatmaps (only half needs to be calculated, the rest can just be filled in, as done here)
%             counter2 = counter2+size(MovementMat{session_column},1);
%         end
%     counter1 = counter1 + size(MovementMat{session_row},1);
% end

counter1 = 1;
cumulativemovements = zeros(1,length(sessions));
cumulativemovements(SessionsatCriterion) = cumsum(NumberofMovementsfromEachSession(SessionsatCriterion));
UsedSessions =  find(SessionsatCriterion);
for currentsession = UsedSessions
    session_row = currentsession;
    temp1 = counter1:cumulativemovements(currentsession);   %%% List of movement numbers in this session
    counter2 = counter1; %%% to step down the diagonal, make counter2 start where counter 1 does!
    address = find(UsedSessions==currentsession);
    for session_column = UsedSessions(address:end)
        temp2 = counter2:cumulativemovements(session_column);
        r_lever(session_row,session_column) = nanmedian(reshape(r(temp1,temp2),1,numel(r(temp1,temp2)))); 
        r_lever(session_column,session_row) = nanmedian(reshape(r(temp1,temp2),1,numel(r(temp1,temp2)))); %%% Accounts for the symmetry of heatmaps (only half needs to be calculated, the rest can just be filled in, as done here)
        counter2 = cumulativemovements(session_column)+1;
    end
    counter1 = counter1 + NumberofMovementsfromEachSession(currentsession);
end

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

LeverTracePlots.figure2 = figure('Position', scrsz); subplot(2,2,1); plot(diag(r_lever), 'k', 'Linewidth', 2);
hold on;
plot(diag(r_lever,1),'Color', [0.6 0.6 0.6], 'Linewidth', 2)
ylabel('Correlations')
xlabel('Session')
legend({'Within sessions', 'Across sessions'})

