function [usesessions] = blacklist(animal)

switch(animal)
    case 'NH002'
        usesessions = 1:14;
    case 'NH003'
        usesessions = 1:9;
    case 'NH004'
        usesessions = 1:14;
    case 'NH005'
        usesessions = 1:14;
    case 'NH006'
        usesessions = 1:14;
    case 'NH007'
        usesessions = 1:14;
    case 'NH008'
        usesessions = [1:6,8:10];
    case 'NH009'
        usesessions = 1:14;
    case 'NH010'
        usesessions = 1:14;
    case 'NH015'
        usesessions = [1:7, 9:14];
    case 'NH017'
        usesessions = [1:12, 14];
    case 'NH020'
        usesessions = [1:13];
    case 'NH021'
        usesessions = 1:14;
    case 'NH022'
        usesessions = [1:14];
    case 'NH023'
        usesessions = 1:14;
    case 'NH024'
        usesessions = [1:6,8:11, 13];
    case 'NH025'
        usesessions = [1:5,7:14];
    case 'NH026'
        usesessions = [1:2,4,7:14];
    case 'NH027'
        usesessions = 1:14;
    case 'NH029'
        usesessions = 1:14;
    case 'NH030'
        usesessions = 1:14;
    case 'NH031'
        usesessions = [1:7,10:14];
    otherwise
        usesessions = 1:14;
        
end