function save_traces(traces_array, folder_path, file_name, flag_create_folders, flag_trace_in_VTK_format)
    %function that allows to save the traces from the iterative algorithm

    for i=1:length(traces_array)
        
        %file name for current trace
        current_file_name = ['trace_num_' num2str(i) '_' file_name];

        %check where the trace will be save
        folder_output = folder_path;
        if flag_create_folders
            folder_output = fullfile(folder_path, ['Trace_num_' num2str(i)]);
        end

        %create folder in case it is not already created
        create_folder(folder_output)

        %saving current trace
        writematrix(traces_array{i}, fullfile(folder_output, [current_file_name '.csv']));

        if flag_trace_in_VTK_format
            points_to_VTK(traces_array{i}, fullfile(folder_output, [current_file_name '.vtk']));
        end
    end
end