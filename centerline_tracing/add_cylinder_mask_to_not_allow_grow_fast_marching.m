function mask = add_cylinder_mask_to_not_allow_grow_fast_marching(mask, distance_to_boundary, trace, radius_cylinder)
    %function that creates a cylinder around the trace to not allow to grow
    %the fast marching
    
    for i=1:length(trace)
        current_trace = trace{i};

        [x_min,x_max,y_min,y_max]= get_crop_coordinates(mask, current_trace, radius_cylinder);

        %update the trace to the new coordinated systemp of the cropped
        %stack
        current_trace(:,1) = current_trace(:,1) -x_min+1;
        current_trace(:,2) = current_trace(:,2) -y_min+1;     

        distance_crop = distance_to_boundary(x_min:x_max,y_min:y_max,:);
        cylinder_mask = get_cylinder_mask(distance_crop, current_trace);

        mask(x_min:x_max, y_min:y_max,:) = mask(x_min:x_max, y_min:y_max,:) || cylinder_mask; 
    end

    
    
end

function [x_min,x_max,y_min,y_max]= get_crop_coordinates(stack_3d, positions, crop_size)
    %crop volume to make the code faster
    x_min = get_minimum_crop_value(min(positions(:,1)), crop_size);
    y_min = get_minimum_crop_value(min(positions(:,2)), crop_size);
    x_max = get_maximum_crop_value(max(positions(:,1)), crop_size, size(stack_3d,1));
    y_max = get_maximum_crop_value(max(positions(:,2)), crop_size, size(stack_3d,2));
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

function cylinder_mask = get_cylinder_mask(distance_crop, positions)
    %function that creates a cylinder around the given positions using the
    %given radius

    cylinder_mask = false(size(distance_crop));

    index_trace = sub2ind(size(distance_crop),positions(:,1),positions(:,2),positions(:,3));
    cylinder_mask(index_trace)=true;
    radius = 4*ceil(max(distance_crop(index_trace)));

    %compute the anisotropic distance transform. Need to take into account
    %the correct aspect ratio. Usually the spacing is larger in Z-axis than
    %in X,Y - axis
    distance_transform= bwdistsc1(cylinder_mask,[1 1 0.5], radius);
    cylinder_mask = distance_transform < radius;
    

    %remove the tip of distance transform to have a cylinder
    I =find(cylinder_mask);
    [x,y,z] = ind2sub(size(cylinder_mask),I);
    
    v1 = get_direction_of_points(positions(end-5:end,:));
    
    val1 = v1(1).*(x-positions(end-2,1)) + v1(2).*(y-positions(end-2,2)) + v1(3).*(z-positions(end-2,3));    
    
    val = val1>0;
    cylinder_mask(I) = ~val;
end