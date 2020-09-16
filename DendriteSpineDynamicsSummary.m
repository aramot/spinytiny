
clear

global gui_KomiyamaLabHub
experimentnames = gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox.String(gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox.Value);

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
end


for i = 1:length(experimentnames)
    targetfile = [experimentnames{i}, '_SpineDynamicsSummary'];
    load(targetfile)
    eval(['currentdata = ',targetfile, ';'])
    NumFields{i} = length(currentdata.SpineDynamics);
    SpineDynamics{i} = currentdata.SpineDynamics;
    DendriteDynamics{i} =  currentdata.DendriteDynamics;
    AllDendriteDistances{i} = currentdata.AllDendriteDistances;
    SpineDendriteGrouping{i} = currentdata.SpineDendriteGrouping;
    AllMovementSpines{i} = currentdata.AllMovementSpines;
    NewSpines{i} = currentdata.NewSpines';
    NewSpinesbyDendrite{i} = currentdata.NewSpinesbyDendrite;
    MiddleSessionNewSpines{i} = currentdata.MiddleSessionNewSpines;
    LateSessionNewSpines{i} = currentdata.LateSessionNewSpines;
    PersistentNewSpines{i} = cell2mat(currentdata.PersistentNewSpines');
    ClusteredNewSpines{i} = cell2mat(currentdata.ClusteredNewSpines(~cell2mat(cellfun(@isempty, currentdata.ClusteredNewSpines, 'uni', false))));
    ClusteredNewSpinesbyDendrite{i} = currentdata.ClusteredNewSpinesbyDendrite;
    ElimSpines{i} = currentdata.ElimSpines';
    ElimSpinesbyDendrite{i} = currentdata.ElimSpinesbyDendrite;
    AntiClusteredElimSpinesbyDendrite{i} = currentdata.AntiClusteredElimSpinesbyDendrite;
    ListofDendsThatAreEarlyMoveRelated{i} = currentdata.ListofDendsThatAreEarlyMoveRelated;
    ListofDendsThatAreLateMoveRelated{i} = currentdata.ListofDendsThatAreLateMoveRelated;
end

AllDendriteLengths = [];
for animal = 1:length(experimentnames)
    for field = 1:length(SpineDendriteGrouping{animal})
        for d = 1:length(SpineDendriteGrouping{animal}{field})
            spinesfromparentdend = SpineDendriteGrouping{animal}{field}{d};
            DendDistances = AllDendriteDistances{animal}{field}(spinesfromparentdend(1):spinesfromparentdend(end),spinesfromparentdend(1):spinesfromparentdend(end));
            [dendlength, longeststretch] = nanmax(nanmax(DendDistances,[],2));
            AllDendriteLengths = [AllDendriteLengths; dendlength];
        end
    end
end

LateDendMR = vertcat(ListofDendsThatAreLateMoveRelated{:});
EarlyDendMR = vertcat(ListofDendsThatAreEarlyMoveRelated{:});
a = horzcat(NewSpinesbyDendrite{:});
b = horzcat(a{:});
%%% Make sure to choose between normalizing by spine number vs. length
%%% Normalize by Spine Number
% NSbyDend = cellfun(@(x) sum(x)./length(x), b);    
%%% Normalize by Dendritic Length
NSbyDend = cellfun(@(x) sum(x), b);

ranksum(NSbyDend(~LateDendMR), NSbyDend(LateDendMR))
