function current_head_positions = get_objects_to_trace(all_head_positions, approximate_head_pos, max_displacement_head, boolean_track_all_objects)
    %function that gets the position of the heads detected in the image
    %closest to the approximate position of the objects
    
    if isempty(approximate_head_pos)
        %we dont have reference from approximate position of previous time.
        %Track all objects
        current_head_positions = all_head_positions;
    elseif boolean_track_all_objects
        %we have approximate positions of the objects to trace and we
        %require to trace all the objects detected in current stack
        current_head_positions = inf*ones(size(approximate_head_pos));
        
        %assign a position for each detected object in the current stack
        for i=1:size(all_head_positions,1)
            %from the detected head position in the current image, detect
            %the closest head position in the previous time point
            D = pdist2(approximate_head_pos, all_head_positions(i,:));
            [closest_distance, ind_min] = min(D);
            
            if (closest_distance < max_displacement_head )
                % the sperm in the previous time has moved less than the
                % minimum displacement. We found a match
                current_head_positions(ind_min,:) = all_head_positions(i,:);
                approximate_head_pos(ind_min,:)=inf;
            else
                %we dont have a match increase the size of the detected
                %objects
                current_head_positions = [current_head_positions; all_head_positions(i,:)];
            end
        end
    else
        %we are tracking only specific sperms. This is useful when there
        %are many sperms and the user only wants to analyze few of them.
        current_head_positions = inf*ones(size(approximate_head_pos));

        for i=1:size(approximate_head_pos,1)
            %from the detected head position in the current image, detect
            %the closest head position in the previous time point
            D = pdist2(all_head_positions, approximate_head_pos(i,:));
            [closest_distance, ind_min] = min(D);
            
            if (closest_distance < max_displacement_head )
                % the sperm in the previous time has moved less than the
                % minimum displacement. We found a match
                current_head_positions(i,:) = all_head_positions(ind_min,:);
            end
        end
    end
end