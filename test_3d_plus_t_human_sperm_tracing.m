function test_3d_plus_t_human_sperm_tracing()
    %this functions is an example to test the code. It allows to trace the
    %flagellum's centerline of human sperm.
    root_path = fileparts(which('trace_centerline_iterative.m'));

    folder_path = '/data/data_270516_Exp3';
    file_prefix = 'Exp3_stacks';

    flag_create_folders = true; %create a folder to save the trace for each sperm
    sperm_head_pos = []; %just to have a variable to save the position of sperm
    track_all_objects = true;

    for time_point = 10:10:250
        %close all figures
        close all;

        file_name = [file_prefix num2str(time_point, '_TP%03g')]; %file_name of the stack to trace
        
        file_input = fullfile(root_path,folder_path, file_name);

        result = trace_centerline_iterative(file_input, 'flag_create_folders', flag_create_folders, 'approximate_head_pos', sperm_head_pos, 'track_all_objects', track_all_objects);

        %update the head position for the next iteration
        sperm_head_pos = result.head_positions;
    end

end
