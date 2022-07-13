function [minimal_cost_path, distance_voxels, tracks_id, stop_track] = compute_minimal_cost_path_fast_marching(cost_function, binary_mask, max_length, seed_points)

    n_heads = size(seed_points,2);
    number_max_iterations = round(4*n_heads*power(max_length,3)); %number maximum of iterations of the fast marching algoritm
    stop_point = [-1;-1;-1]; %stop if algoritms reachs this point


    %computing fast marching
    [minimal_cost_path, distance_voxels, tracks_id, stop_track]= fast_marching_stop_length(double(cost_function),...
    single(seed_points-1), single(stop_point), number_max_iterations, binary_mask, max_length); 

    stop_track = check_validity_of_terminal_points(stop_track, minimal_cost_path, tracks_id);

    %just to save the fast-marching
    not_reached_voxels =  minimal_cost_path>10000; 
    minimal_cost_path(not_reached_voxels) = inf;

end

function stop_track = check_validity_of_terminal_points(stop_track, minimal_cost_path, tracks_id)
    %just make sure that all the seed points reached the requested maximum
    %length
    for i=1:size(stop_track,1)
        if sum(stop_track(i,:))==0
            %maximum length not reached

            %getting the current id of the track
            current_id = i-1;
            I = tracks_id ==current_id;

            %variable temporal
            mcp_temp = minimal_cost_path;
            
            %setting distance to zero to all values not reached by current
            %id
            mcp_temp(not(I))=0;
            
            %getting the maximum of current id
            [~,ind] = max(mcp_temp(:));
            
            %getting the x,y,z coordinates of the maximum value
            [x,y,z] = ind2sub(size(mcp_temp),ind(1));

            stop_track(i,:) = [x,y,z];
        end
    end
end
