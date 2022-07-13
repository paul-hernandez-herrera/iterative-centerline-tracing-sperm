function [sub_volume, pos_min, pos_max] = get_subvolume(stack_3d, center_, crop_size)
    %function to construct a subvolume given the center and the crop_size
    
    if size(center_,1)==1
        x_min = get_minimum_crop_value(center_(1), crop_size);
        y_min = get_minimum_crop_value(center_(2), crop_size);
        z_min = get_minimum_crop_value(center_(3), crop_size);
        x_max = get_maximum_crop_value(center_(1), crop_size, size(stack_3d,1));
        y_max = get_maximum_crop_value(center_(2), crop_size, size(stack_3d,2));
        z_max = get_maximum_crop_value(center_(3), crop_size, size(stack_3d,3));
    
        sub_volume = stack_3d(x_min:x_max, y_min:y_max,z_min:z_max);
        pos_min = [x_min, y_min, z_min];
        pos_max = [x_max, y_max, z_max];
    else
        pos_min= [1,1,1];
        pos_max= size(stack_3d);
        sub_volume = stack_3d;
    end

end

function val_min = get_minimum_crop_value(pos, crop_size)
    val_min = pos - crop_size;
    if val_min<1
        val_min=1;
    end
end

function val_max = get_maximum_crop_value(pos, crop_size, index_max)
    %index_max  maximum value that the index can reach

    val_max = pos + crop_size;
    if val_max > index_max
        val_max= index_max;
    end
end