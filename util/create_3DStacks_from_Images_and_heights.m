function create_3DStacks_from_Images_and_heights(folder_path,image_name_prefix)
    %This function creates 3D stacks using the a set of 2D images and the
    %height of the piezoelectric device in a txt file. 
    % This function is specific for the microscopy developed by Corkidi et
    % al. 2008 https://doi.org/10.1109/ISBI.2008.4540953
    % IMPORTANT: It is assumed that the 2D images and the heights files are
    % syncronized. This mean that image1 corresponds to height1
    
    %INPUTS:
    %folder_path: The path to the folder containing the 2d images and the
    %txt file with the height of each image
    %image_name_prefix -> sufix used to identify the images. The file name of
    %each image must be [image_name_prefix + 8 id numbers + .tif] 
    
    % OUTPUT:
    % A folder is created in the folder parent of folder_path name
    % "folder_name"+"_3D_Stacks" where folder_name is the name of folder
    % containing the images. The created folder will contain the 3D image
    % stacks in tif format with a file txt corresponding to the height of
    % each slice.
    
    %CLOSE ALL FIGURES
    close all;
    
    folder_output_stacks = get_folderpath_to_save_3Dstacks_and_create_it(folder_path);
    
    number_imgs = get_total_number_of_images(folder_path);
    
    z_pos = get_heights_for_each_image(folder_path);
    z_pos = z_pos(1:number_imgs);
    
    [loc_ini, loc_end, stack_n_slices, Make_stacks_bottom_to_top] = get_initial_andend_index_position_of_3D_stack(z_pos);

    tp = 1;
    for i=1:length(loc_ini)-1
    
        index_ini = loc_ini(i);
        index_end = loc_end(i);

        if ((index_end-index_ini) >  (stack_n_slices/2))
            %just to make sure we have enough images to create the 3D stack

            ID = ['TP' get_id_str(tp,4)];        
            
            current_stack_index = index_ini:index_end;
            
            current_stack_size = length(current_stack_index);
            
            index_z_pos = zeros(1,stack_n_slices);
            if (current_stack_size< stack_n_slices)
                %current stack have less images than the fixed number of
                %images for stack. Append the last image until reach the
                %stack size
                index_z_pos(1:current_stack_size) = current_stack_index;
                index_z_pos(current_stack_size+1:stack_n_slices) = index_end;
            elseif (current_stack_size>stack_n_slices)
                %we have more images in the current stack, remove the
                %remaining images
                index_z_pos(:) = current_stack_index(1:stack_n_slices);
            else
                %current stack size is the expected size
                index_z_pos(:) = current_stack_index;
            end
            %images begin at index 000000
            index_images = index_z_pos -1;

            stack_3D = read_camImage(index_images,folder_path, image_name_prefix);  
            stack_z_vals = z_pos( index_z_pos);
            
            if not(Make_stacks_bottom_to_top)
                %images going from top to bottom. Invert index
                stack_3D = stack_3D(:,:,end:-1:1);
                stack_z_vals = stack_z_vals(end:-1:1);
            end
            
            if (any(diff(stack_z_vals)<0))
                error('z_pos not decreasing values');
            end             
            
            %writing tif file
            current_stack_name = [image_name_prefix  '_' ID];
            write_tif(stack_3D, folder_output_stacks, current_stack_name)
            
            %writing z_pos for each slice
            csvwrite(fullfile(folder_output_stacks,[current_stack_name '.txt']), stack_z_vals);
            
            %saving current stack information
            info{tp}.lowerBoundZ = index_ini;
            info{tp}.higherBoundZ = index_end;
            info{tp}.zVal = stack_z_vals;
            info{tp}.current_name = current_stack_name;
            
            tp = tp + 1;
        end

    end

    name_variable = fullfile(folder_output_stacks,strcat(image_name_prefix,'_info.mat'));
    save(name_variable,'info');

end


function folder_path_stacks = get_folderpath_to_save_3Dstacks_and_create_it(folder_path)
    %this function gets the parent folder and the folder name where the
    %images will be created. It also creates the folder if it not exist
    [parent_folder, folder_name] = fileparts(folder_path);
    
    if isempty(folder_name)
        %file_path is ending with / or \ 
        %removing last character
        [parent_folder, folder_name] = fileparts(folder_path(1:end-1));
    end
    
    folder_path_stacks = fullfile(parent_folder,[folder_name '_3D_Stacks']);
    
    if not(exist(folder_path_stacks,'dir'))
        mkdir(folder_path_stacks);
    end
    
end

function number_imgs = get_total_number_of_images(folder_path)
    %This function obtains the total number of images inside folder_path
    number_imgs = length(dir(fullfile(folder_path,'*.tif')));
    if number_imgs==0
        number_imgs = length(dir(fullfile(folder_path,'*.TIF')));
    end    
end

function z_pos = get_heights_for_each_image(folder_path)
    %function to get the heigth/position in Z for each image

    path_file_heights = dir(fullfile(folder_path,'*.txt'));
    z_pos = 40*csvread(fullfile(folder_path,path_file_heights(1).name));    
end


function [loc_ini, loc_end, stack_n_slices,Make_stacks_bottom_to_top] = get_initial_andend_index_position_of_3D_stack(z_pos)
    %This function returns the index location of the stack
    Make_stacks_bottom_to_top = true;
    
    %getting position of local maximum
    [~,loc_maximum]=findpeaks(z_pos);
    
    %getting position of local minimum
    [~,loc_minimum]=findpeaks(-z_pos);
    
    %just to make sure that the first stack goes from a local minimum to a
    %local maximum
    min_val = min(loc_minimum);
    loc_maximum(loc_maximum<=min_val) = [];
    loc = sort([loc_minimum;loc_maximum]);
    loc = unique(loc);
    
    
    if (z_pos(loc(1)) > z_pos(loc(2)))
        error('Contact developer... z_pos must go from bottom to top');
    end

    if (Make_stacks_bottom_to_top)
        %selected images increase their values in z_pos
        loc_ini = loc(1:2:end); loc_end = loc(2:2:end);
    else
        %selected images decrease their values in z_pos
        loc_ini = loc(2:2:end); loc_end = loc(3:2:end);
    end

    loc_ini = loc_ini(3:end-1);
    loc_end = loc_end(3:end-1);   
    
    stacks_sizes = diff(loc)+1; 
    %remove smalls sizes
    stacks_sizes(stacks_sizes<3)=[];
    stack_n_slices = mode(stacks_sizes);    
end

function stack = read_camImage(index_,folder_path,file_ID)

    for i=1:length(index_)
        ID = get_id_str(index_(i),5);

        if exist(fullfile(folder_path,[file_ID  ID '.tif']),'file')
            I = imread(fullfile(folder_path,[file_ID  ID '.tif']))';
        else
            I = imread(fullfile(folder_path,[file_ID  ID '.TIF']))';
        end
        if i==1
            stack = zeros(size(I,1),size(I,2),length(index_),'uint8');
        end

        stack(:,:,i)= I;
    end

end