function trace = backtrace(seed_points, terminal_points, fast_marching)
    %function that back-trace from terminal points until it reaches a
    %seed_point
    
    %padarray to have good boundary conditions
    fast_marching = padarray(fast_marching,[1,1,1],inf);
    seed_points = seed_points +1;
    terminal_points = terminal_points +1;

    max_val_fast_marching = inf;
    min_val_fast_marching = 0;

    %converting to index the terminal points
    if ~isempty(terminal_points)
        terminal_points_ind = sub2ind(size(fast_marching),terminal_points(:,1),terminal_points(:,2),terminal_points(:,3));

        %make sure that terminal point was reached be the fast-marching
        %algoritm
        I = fast_marching(terminal_points_ind)==inf;
        terminal_points_ind(I) = [];
    else
        terminal_points_ind = [];
    end
    
    %setting all the voxels at seed points to the minimum value of
    %fast-marcing
    seed_points_ind = sub2ind(size(fast_marching),seed_points(:,1),seed_points(:,2),seed_points(:,3));
    fast_marching(seed_points_ind) = min_val_fast_marching;

    
    %variables to save trace
    trace = [];
       
    while ~isempty(terminal_points_ind)
        %backtracing from the largest fast-marching value from terminal
        %point      
        index_terminal_point = terminal_points_ind(1);        
        val=  fast_marching(index_terminal_point);

        %removing the current terminal point from the list of points to
        %backtrace
        terminal_points_ind(1) = [];
        
        trace = getPathFromTerminalPoint(trace,fast_marching, min_val_fast_marching, max_val_fast_marching, index_terminal_point, val);
        
        %setting value to zero to the current trace to allow stop the
        %backpropagation.
        index_trace = sub2ind(size(fast_marching),trace{end}(:,1),trace{end}(:,2),trace{end}(:,3));
        fast_marching(index_trace)=0;    
    end

    %removing the additional value in the coordinates due to the padding
    for i=1:length(trace)
        trace{i} = trace{i}-1;
    end
end

function trace  = getPathFromTerminalPoint(trace,fast_marching, min_val_fast_marching, max_val_fast_marching, index_terminal_point, val)
    %getting the size of the volume
    max_it = 10000;
    
    size_fast_marching = size(fast_marching);

    %getting the 3D coordinates of the current terminal points
    [x,y,z] = ind2sub(size_fast_marching,index_terminal_point);
    
    %creating a new cell for the new path
    idS = length(trace) + 1;
    trace{idS} = [x y z];
        
    %setting the previous value as the maximum of the fast_marching
    previous_val = max_val_fast_marching;
    
    it =0;
    while val>min_val_fast_marching &&  val <= previous_val && it<max_it
        it = it +1;

        %setting the previous value as the last minimum
        previous_val = val;
    
        if previous_val == inf
            fprintf('\nCurrent_value infinite\n');
            break;
        end
    
        %creating neighboors of the current point
        %not take into account the center of the point
        current_neighboorhs = fast_marching(x-1:x+1,y-1:y+1,z-1:z+1);
        current_neighboorhs(2,2,2) = inf;
               
        %getting the minimum value from the fast_marching in the neighboorhod
        [val, iMin] = min(current_neighboorhs(:));
    
        %getting the coordinates of the minimum point, subtracting 2
        %because the center of the neighboor is [2, 2, 2]
        [xi, yi, zi] = ind2sub([3,3,3], iMin);
        x= x + xi-2; y = y + yi-2; z= z + zi-2;
    
        trace{idS} = [x y z;trace{idS}];

        if previous_val == val
            %just to avoid returning to the same coordinates
            fast_marching(x,y,z) = max_val_fast_marching;
        end        
    end
end