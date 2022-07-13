function trace_centerline_for_current_step_and_every_seed_point(fast_marching, seed_points,terminal_points)   
    %function that extracts the centerline for each seed point in the
    %current step

    for index=1:size(terminal_points,2)
        %backtrace each terminal point to seed point
        current_terminal_point = terminal_points(:,index);

        if (sum(current_terminal_point(:))~=0)
            %make sure that the point is different from zero

            %back-trace current terminal point
            trace = backtrace(seed_points, terminal_points, fast_marching);
            
            %removing the additional 5 points when computing the
            %fast_marching
            trace{1} = trace{1}(1:end-5,:);
        end
    end

end