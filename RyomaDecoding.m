function [CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV,  CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV_pval, ...
          CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV, CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV_pval, ...
          Mdl_readyperiod_dQlrb_all, ...
          parameters] = RyomaDecoding(Speed_frame, NeuralActivity)
% Speed_frame = wheel_speed_frame
% NeuralActivity = zscore(Data.caEvents(idx_active,:),0,2)'
% [CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV,  CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV_pval, ...
%           CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV, CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV_pval, ...
%           Mdl_readyperiod_dQlrb_all, ...
%           parameters] =Decoding_WheelSpeed_NeuralEnsemble(Speed_frame, NeuralActivity)


%%
% using Ryoma's code first
warning off
dQlrb_wo_missalarm = Speed_frame;  
SR_ansstart4reg_2s = full(NeuralActivity); % frame x N; 
clear NeuralActivity Speed_frame
total_cell = size(SR_ansstart4reg_2s,2);

%fixed parameters
kfold4prediction = 10;

kfold4lambda = 10;

Lambda = [0,logspace(-5,1,20)];

cellnum4predict = 5;

CellSet_num = ceil(total_cell/cellnum4predict); % total_cell-1; %

CellSet_id = crossvalind('Kfold',total_cell,CellSet_num);

CellSet_100id = NaN(cellnum4predict,CellSet_num);

for i = 1:CellSet_num

    CellSet_100id(:,i) = [find(CellSet_id==i);randsample(find(CellSet_id~=i),cellnum4predict - sum(CellSet_id==i))];

end

% CellSet_100id = combnk(1:total_cell, cellnum4predict)';
% CellSet_num = size(CellSet_100id,2);

parameters.kfold4prediction = kfold4prediction;
parameters.kfold4lambda     = kfold4lambda;
parameters.Lambda           = Lambda;
parameters.cellnum4predict  = cellnum4predict;
parameters.CellSet_num      = CellSet_num;
parameters.CellSet_100id    = CellSet_100id;


%devide cells into different sets for modeling
 
% dQlrb_wo_missalarm is the Y

CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV = NaN(size(SR_ansstart4reg_2s,3),size(SR_ansstart4reg_2s,3),CellSet_num);
% confusion matrix 
CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV = NaN(size(SR_ansstart4reg_2s,3),size(SR_ansstart4reg_2s,3),CellSet_num);

CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV_pval = NaN(size(SR_ansstart4reg_2s,3),size(SR_ansstart4reg_2s,3),CellSet_num);

CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV_pval = NaN(size(SR_ansstart4reg_2s,3),size(SR_ansstart4reg_2s,3),CellSet_num);

Mdl_readyperiod_dQlrb_all = cell(size(SR_ansstart4reg_2s,3),CellSet_num);

for decoding_id = 1:CellSet_num

    for window_id = 1:size(SR_ansstart4reg_2s,3)

        Mdl_readyperiod_dQlrb_CV = cell(kfold4prediction,1);

        Beta_readyperiod_dQlrb_CV = NaN(cellnum4predict,kfold4prediction);

        Bias_readyperiod_dQlrb_CV = NaN(kfold4prediction,1);

        train_test_ind = crossvalind('Kfold',dQlrb_wo_missalarm,kfold4prediction);

        temp_minMESind = cell(kfold4prediction,1);

        temp_pridictions = cell(kfold4prediction,1);

        temp_data = cell(kfold4prediction,1);

        temp_model = cell(kfold4prediction,1);

        parfor cv_ind = 1:kfold4prediction

            [~,temp_minMESind{cv_ind}] = min(kfoldLoss(fitrlinear(...
                SR_ansstart4reg_2s(train_test_ind ~= cv_ind, ...
                                   CellSet_100id(:,decoding_id),window_id)', ...
                                   dQlrb_wo_missalarm(train_test_ind ~= cv_ind), ...
                'ObservationsIn','columns', ...
                                   'KFold',kfold4lambda,...
                                   'Lambda',Lambda, ...
                                   'Learner','leastsquares',...
                                   'Regularization','lasso')));

            temp_model{cv_ind} = selectModels(fitrlinear(...
                SR_ansstart4reg_2s(train_test_ind ~= cv_ind, CellSet_100id(:,decoding_id), window_id)', ...
                dQlrb_wo_missalarm(train_test_ind ~= cv_ind),...
                'ObservationsIn','columns','Lambda',Lambda,'Learner','leastsquares',...
                'Regularization','lasso'),temp_minMESind{cv_ind});

            Mdl_readyperiod_dQlrb_CV{cv_ind} = struct(temp_model{cv_ind});

            Beta_readyperiod_dQlrb_CV(:,cv_ind) = Mdl_readyperiod_dQlrb_CV{cv_ind}.Beta;

            Bias_readyperiod_dQlrb_CV(cv_ind) = Mdl_readyperiod_dQlrb_CV{cv_ind}.Bias;

            temp_pridictions{cv_ind} = predict(temp_model{cv_ind}, ...
                SR_ansstart4reg_2s(train_test_ind == cv_ind,CellSet_100id(:,decoding_id),window_id));

            temp_data{cv_ind} = dQlrb_wo_missalarm(train_test_ind == cv_ind);

        end

        temp_pridictions = cell2mat(temp_pridictions);
            diff = cellfun(@(x) x-max(cell2mat(cellfun(@length, temp_data, 'uni', false))), cellfun(@length, temp_data, 'uni', false), 'uni', false);
            temp_data = cellfun(@(x,y) [x(1:end), zeros(1,abs(y))],temp_data, diff, 'uni', false);
        temp_data = cell2mat(temp_data);

 

        temp_pridictions_ansstart4reg_2s = cell(kfold4prediction,1);

        for cv_ind = 1:kfold4prediction

            for t_ind = 1:size(SR_ansstart4reg_2s,3)

                temp_pridictions_ansstart4reg_2s{cv_ind} = [temp_pridictions_ansstart4reg_2s{cv_ind}, predict(temp_model{cv_ind},SR_ansstart4reg_2s(train_test_ind == cv_ind,CellSet_100id(:,decoding_id),t_ind))];

            end

        end
        
        diff = cellfun(@(x) x-max(cell2mat(cellfun(@length, temp_pridictions_ansstart4reg_2s, 'uni', false))), cellfun(@length, temp_pridictions_ansstart4reg_2s, 'uni', false), 'uni', false);
        temp_pridictions_ansstart4reg_2s = cellfun(@(x,y) [x(1:end)', zeros(1,abs(y))],temp_pridictions_ansstart4reg_2s, diff, 'uni', false);
        temp_pridictions_ansstart4reg_2s = cell2mat(temp_pridictions_ansstart4reg_2s);

       

        [CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV(:,window_id,decoding_id),...
            CorrPearson_readyperiod_ansstart4reg_2s_dQlrb_CV_pval(:,window_id,decoding_id)] = ...
            corr(temp_pridictions_ansstart4reg_2s',temp_data','Type','Pearson','Rows','complete');

        [CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV(:,window_id,decoding_id),...
            CorrSpearman_readyperiod_ansstart4reg_2s_dQlrb_CV_pval(:,window_id,decoding_id)] = ...
            corr(temp_pridictions_ansstart4reg_2s,temp_data,'Type','Spearman','Rows','complete');   

 

        [~,minMESind] = min(kfoldLoss(fitrlinear(SR_ansstart4reg_2s(:,CellSet_100id(:,decoding_id),window_id)',dQlrb_wo_missalarm,'ObservationsIn','columns','KFold',kfold4lambda,'Lambda',Lambda,'Learner','leastsquares','Regularization','lasso')));

        Mdl_readyperiod_dQlrb_all{window_id,decoding_id} = struct(selectModels(fitrlinear(SR_ansstart4reg_2s(:,CellSet_100id(:,decoding_id),window_id)',dQlrb_wo_missalarm,'ObservationsIn','columns','Lambda',Lambda,'Learner','leastsquares','Regularization','lasso'),minMESind));

    end

end


disp('Done')
warning on   