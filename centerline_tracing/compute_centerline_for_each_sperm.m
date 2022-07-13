function output = compute_centerline_for_each_sperm(probability, img_3d_raw, current_head_positions, max_number_iterations, length_first_iteration, length_per_iteration)
    %tracing the centerline using an iterative algorithm
    cost_function = construct_cost_function(probability, img_3d_raw);
    binary_mask = true(size(cost_function));
    extra_segment = 5;
    
    if not(isempty(current_head_positions))
        %creating the index of the sperms to trace
        sperm_idx = 1:size(current_head_positions,1);
        %not trace the sperms with value inf ... this have been lost of the
        %field of view
        sperm_idx(current_head_positions(:,1)==inf)=[];

        %variable to save traces
        trace = cell(1,size(current_head_positions,1));
        
        %only for visualization purposes
        trace_last_iteration = cell(1,size(current_head_positions,1));

        for iteration=1:max_number_iterations
            fprintf('\n it %i ', iteration);
            idx_stop = [];
    
            %getting the length in voxels to trace
            if iteration==1
                %we need a large length to get out of sperm's head
                ite_length = length_first_iteration + extra_segment;
            else
                ite_length = length_per_iteration + extra_segment;
            end
    
            %crop the volume in case that we are tracking a single object
            %(it is faster the algorithm)   
            [current_cost_function, pos_min, pos_max] = get_subvolume(cost_function, current_head_positions(sperm_idx,:), ite_length);
            current_binary_mask = get_subvolume(binary_mask, current_head_positions(sperm_idx,:), ite_length);
    
            seed_point = current_head_positions(sperm_idx,:) - pos_min +1;
            
            [minimal_cost_path, distance_voxels, tracks_id, stop_pos_each_object] = compute_minimal_cost_path_fast_marching(current_cost_function, current_binary_mask, ite_length, seed_point');
            
            trace_current_it = backtrace(seed_point, stop_pos_each_object, minimal_cost_path);
    
            for i=1:length(trace_current_it)
                %updating index to the input size//we cropped the volume
                trace_current_it{i} = trace_current_it{i}+pos_min-1;
                
                %make sure to remove extra segment
                if size(trace_current_it{i},1)>extra_segment+3
                    trace_current_it{i} = trace_current_it{i}(1:end-extra_segment,:);
                end

                current_head_positions(sperm_idx(i),:) = trace_current_it{i}(end,:);
                
                %check if current segment must be added to the trace
                trace_length = length(trace{sperm_idx(i)});
                if iteration==1
                    add_segment = add_segment_to_trace_based_on_probability_and_direction(probability, trace_current_it{i}, []);
                else
                    add_segment = add_segment_to_trace_based_on_probability_and_direction(probability, trace_current_it{i}, trace{sperm_idx(i)}{trace_length});
                end
    
                if add_segment
                    trace{sperm_idx(i)}{trace_length+1} = trace_current_it{i};
                else
                    %this sperms must stop tracking
                    trace_last_iteration{sperm_idx(i)} = trace_current_it{i};
                    idx_stop = [idx_stop; i];
                end
            end
    
    
            %stopping sperms that satisfy the stopping criteria
            sperm_idx(idx_stop) = [];
    
            %creating a cylinder to remove voxels already visited;
            %mask = add_cylinder_mask_to_not_allow_grow_fast_marching(mask, distance_to_boundary, trace, radius_cylinder);
            

            %remove voxels already visied
            mask = false(size(cost_function));
            mask(pos_min(1):pos_max(1),pos_min(2):pos_max(2),pos_min(3):pos_max(3)) = distance_voxels<(ite_length-extra_segment);
            cost_function(mask)=1; %% just to make sure that it can propagate 
            probability(mask) = 0;

            %check if there are not more seed points
            if isempty(sperm_idx)
                break;
            end
        end
    else
        trace =[];
        trace_last_iteration = [];
        warning('Could trace centerline because seeds points (sperms heads) were not detected');
    end
    
    output.trace = trace;
    output.trace_last_iteration = trace_last_iteration;
end