clc, clear, close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% User define Variable (Change this part if necessary)  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Brain section number             %%%%%%%%%%%%%%%%%%%
animal_num = 2;  %% For the second brain, change it to 2

%%% Input folder name and output stack name    %%%%%%%%%
%%% For Windows System, you may need to change "/" to "\" manually
cd('E:')
folder_pre = ['E:', filesep, 'CavCre',num2str(animal_num),'.'];
folder_post = '.vsi.Collection';
layer_name = [filesep,'Layer'];
file_name = [filesep, 'Layer.btf'];

output_name = 'stack';

%%% Loop info %%% 
max_collection = 8;  %%% Loop from 2.1 to 2.8
max_layer = 0;       %%% Don't need to care!
min_layer = 0;       %%% Start the loop from 0 to max_layer

height = 1800;    
width = 1200;

rotate_clock_wise_90 = 1;   %%% Clock wise rotate 90 degree; 0 to turn off
flip_ud = 1;                %%% Top - Down flip; 0 to turn off
flip_lr = 0;                %%% Left - right flip ; 1 to turn on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compression and Save to stack    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_dir = [folder_pre,num2str(1),folder_post ...
        ,layer_name,num2str(0),file_name];

img = imread(f_dir);
img_r = imresize(img,[height, width]);

if rotate_clock_wise_90 == 1
    img_r = permute(img_r,[2,1,3]);
end

if flip_ud == 1
    img_r = flipdim(img_r, 1);
end

if flip_lr == 1
    img_r = flipdim(img_r, 2);
end

imwrite(img_r,[output_name,num2str(animal_num),'.tif'],...
        'Compression','packbits');

for i = 1:max_collection
    max_layer = size(fastdir([folder_pre, num2str(i), folder_post], 'Layer'),1)-1;

    for j = min_layer : max_layer
        if i == 0 && j == 0
            continue
        else
            f_dir = [folder_pre,num2str(i)  ...
                    ,folder_post,layer_name,num2str(j),file_name];
           
            img = imread(f_dir);
            img_r = imresize(img, [height, width]);
        
            if rotate_clock_wise_90 == 1
                img_r = permute(img_r,[2,1,3]);
            end
            
            if flip_ud == 1
                img_r = flipdim(img_r, 1);
            end

            if flip_lr == 1
                img_r = flipdim(img_r, 2);
            end
            
            imwrite(img_r, [output_name,num2str(animal_num), ...
                '.tif'], 'WriteMode', 'append', ...
                'Compression','packbits');
        end
    end
end
