function corrdata = ArrangeDendriteData(ZhongminsFile, DendOutput)

%%% Zhongmins file is the file that Zhongmin produced to organize her
%%% dendrite data, and contains indices valuable to this function
%%% DendOutput is the output of the function "CollectDendriteData"


animallist = {'NH051', 'NH052', 'NH053', 'NH054', 'ZL024', 'ZL025', 'ZL026', 'ZL027', 'ZL028', 'ZL029', 'ZL030', 'ZL031', 'ZL032', 'ZL033', 'ZL034', 'ZL035', 'ZL036', 'ZL037', 'ZL038', 'ZL039', 'ZL040', 'ZL041', 'ZL042', 'ZL043', 'ZL044', 'ZL045', 'ZL046', 'ZL047', 'ZL048'};

addresslist = [cell2mat(cellfun(@str2double, ZhongminsFile{5,1}{1,2}(:,2), 'uni', false)); cell2mat(cellfun(@str2double, ZhongminsFile{5,1}{1,1}(:,2), 'uni', false))];

fileslist = [ZhongminsFile{5}{2}(:,1); ZhongminsFile{5}{1}(:,1)];

corrEarly = nan(length(fileslist),1);
corrMid = nan(length(fileslist),1);
corrLate = nan(length(fileslist),1);

for i = 1:length(fileslist)
    currentfile = fileslist{i};
    animalsearch = regexp(currentfile, '[A-Z]{2}0\d+', 'match');
    currentanimal = animalsearch{1};
    animallocator = logical(cell2mat(cellfun(@(x) strcmpi(x,currentanimal), animallist, 'uni', false)));
    fieldsearch = regexp(currentfile, '_Field[\d+]', 'match');
    currentfield = str2num(fieldsearch{1}(end));
    dendsearch = regexp(currentfile, '_Dendrite#[\d]', 'match');
    currentdend = str2num(dendsearch{1}(end));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Determine sessions used (the first field is not always on the first
    %%% session, so these cannot be considered equivalent)
    sessionsimaged = ~cellfun(@isempty,DendOutput{animallocator});
    
    sessionsgrouping = find(diff([Inf, sessionsimaged, Inf])~=0);
    
    imagingblockslogical = mat2cell(sessionsimaged', diff(sessionsgrouping));
    
    imagingblocksbysessionnum = mat2cell([1:14]', diff(sessionsgrouping));
    
    trueimagingblocks = imagingblocksbysessionnum(cell2mat(cellfun(@(x) ~isempty(find(x,1)), imagingblockslogical,'uni', false)));
        
    earlysessions = cell2mat(trueimagingblocks(cell2mat(cellfun(@(x) sum((x>=0))==length(x) && sum((x<=5))==length(x), trueimagingblocks, 'uni', false))));
    if i >62 && length(trueimagingblocks)>2
        midsessions = cell2mat(trueimagingblocks(cell2mat(cellfun(@(x) sum((x>=6))==length(x) && sum((x<=10))==length(x), trueimagingblocks, 'uni', false))));
    end
    latesessions = cell2mat(trueimagingblocks(cell2mat(cellfun(@(x) sum((x>=11))==length(x) && sum((x<=14))==length(x), trueimagingblocks, 'uni', false))));
    
    if currentfield>length(earlysessions)
        currentfield = currentfield-(min(currentfield)-1);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if ~isempty(DendOutput{animallocator}{earlysessions(currentfield)})
        corrEarly(i,1) = DendOutput{animallocator}{earlysessions(currentfield)}(currentdend);
    else
        corrEarly(i,1) = NaN;
    end
    if i >62
        if currentfield<=length(midsessions)
            if ~isempty(DendOutput{find(animallocator)}{midsessions(currentfield)}) && length(DendOutput{find(animallocator)}{midsessions(currentfield)})>=currentdend
                corrMid(i,1) = DendOutput{find(animallocator)}{midsessions(currentfield)}(currentdend);
            else
                corrMid(i,1) = NaN;
            end
        else
        end
    else
        corrMid(i,1) = NaN;
    end
    if currentfield<=length(latesessions)
        if ~isempty(DendOutput{find(animallocator)}{latesessions(currentfield)}) && length(DendOutput{find(animallocator)}{latesessions(currentfield)})>= currentdend
            corrLate(i,1) = DendOutput{find(animallocator)}{latesessions(currentfield)}(currentdend);
        else
            corrLate(i,1) = NaN;
        end
    end
    
    %%% Find spine dynamics 
%     cd(['C:\Users\Komiyama\Desktop\Output Data', filesep, currentanimal, ' New Spine Analysis']);
%     fieldsource = fastdir(cd, ['Field ', num2str(currentfield)]);
%     load(fieldsource)
%     FieldChanges = diff(SpineRegistry.Data,1,2);
end

corrdata.corrEarly = corrEarly(addresslist);
corrdata.corrMid = corrMid(addresslist);
corrdata.corrLate = corrLate(addresslist);