function add_segment = add_segment_to_trace_based_on_probability_and_direction(probability, trace_coordinates, previous_trace)
    %this function allows to decide if the segment correspond to the
    %structure of interest
    probability_stop = 0.5;
    angle_stop = 110;

    %index of the center-line tracing for current step
    index_trace = sub2ind(size(probability), trace_coordinates(:,1), trace_coordinates(:,2), trace_coordinates(:,3));
    
    %probability cost
    percentile = prctile(probability(index_trace),50);

    %direction cost
    if not(isempty(previous_trace))
        if size(trace_coordinates,1)>5 && size(previous_trace,1)>5
            direction_previous_trace = getDirectionFromPoints(previous_trace(end-5:end,:));
            direction_current_trace = getDirectionFromPoints(trace_coordinates(1:5,:));
            angle = acosd(dot(direction_previous_trace, direction_current_trace));
        else
            angle = 0;
        end
        
    else 
        angle = 0;
    end

    if (or(percentile< probability_stop, angle>angle_stop))                
        add_segment = false;
    else
        add_segment = true;
    end      
end