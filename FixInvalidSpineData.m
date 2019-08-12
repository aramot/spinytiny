for a = 24:48    
    animal = ['ZL0', num2str(a)]
    
    %%%%%
    registryfilesource = ['C:\Users\Komiyama\Desktop\Output Data\', animal, ' New Spine Analysis'];
    activityfilessource = 'E:\ActivitySummary';
    %%%%%
    two directories 
    cd(registryfilesource)
    RegistryFiles = fastdir(cd, 'Spine Registry');

    for h = 1:length(RegistryFiles)
        cd(registryfilesource)
        load(RegistryFiles{h})

        Dates = sortrows(SpineRegistry.DatesAcquired)

        for i = 1:length(Dates)
            f(i) = figure;
            cd(activityfilessource)
            fname = [animal, '_', Dates{i}, '_Summary'];
            load([fname, '.mat'])
            eval(['data = ', fname])
            NaNspines = find(SpineRegistry.Data(:,i) ==0)
            sqrsize = ceil(sqrt(length(NaNspines)));
            for j = 1:length(NaNspines)
                subplot(sqrsize,sqrsize,j); hold on;
%                 plot(data.Processed_dFoF(NaNspines(j),:))
                datalength = length(data.Fluorescence_Measurement{NaNspines(j)});
                data.Fluorescence_Measurement{NaNspines(j)} = nan(1,datalength);
                data.dF_over_F{NaNspines(j)} = nan(1,datalength);
                data.Processed_dFoF(NaNspines(j),:) = nan(1,datalength);
                data.Processed_dFoF_DendriteSubtracted(NaNspines(j),:) = nan(1,datalength);
%                 plot(data.Processed_dFoF(NaNspines(j),:))
            end
            if ~isempty(NaNspines)
                eval([fname, ' = data;'])
                save(fname, fname)
            end
            clear(fname)
        end
        clear(RegistryFiles{h})
    end
end