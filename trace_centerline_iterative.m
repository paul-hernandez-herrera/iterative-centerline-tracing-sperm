function result = trace_centerline_iterative(file_input, varargin)
    %This function trace the centerter-line from a bright tubular structure
    %using an iterative approach. 
    % https://doi.org/10.1109/TMI.2018.2840047

    % PARAMETERS:
    % file_input: file path to the 3D image stack to be traced (tif or
    % mhd format) 

    % PARAMETERS OPTIONAL:
    % meson_radius: radius of the tubular structures to be detected. default [2 3 4 5]

    % threshold_head: threshold value used to segment sperm's head. Default
    % method uses the otsu algorithm to segment the heads

    % min_conn_comp: minimum number of voxels to have a connected
    % components in the segmentation to be identified as sperm's head.
    % Default value 5^3

    % approximate_head_pos: Trace only sperms that are close to the positions 
    % given in the array approximate_head_position. This is very useful if there 
    % are many sperms in the 3d image stack and the user is only interested in few
    % of them. Default empty

    % max_displacement_head: maximum displacement in voxels from approximate_head_pos that a sperm
    % can move from one time point to the next one. If a sperm move more then it is descarted.
    % This is important to track sperms across time. Default 20

    % preprocess: apply a log transform to the 3D image stack to increase
    %contrast

    % track_all_objects: track all objects detected in the image stack. Default
    %false. 

    % max_number_iterations: maximum number of iterations to stop the
    % algorithm. Default 20. Note: It can stop early if the trace for a
    % given iteration has low probability or change drastically its
    % direction.

    % length_per_iteration: number of voxels to extract per iteration.
    % Default 20

    % length_first_iteration: number of voxels to extract in the first
    % iteration. Default 60
    
    % flag_create_folder: create a folder for each sperm tracked. Useful
    % when there are many sperms in the 3d image stack. 

    % save_images: save an image with the main steps of the algorithm.

    % trace_in_VTK_format: write trace in vtk format to be open with
    % Paraview. Default false


    %gettting input parameters
    parameters = get_parameters(varargin);
    
    [folder_path, file_name, ~] = fileparts(file_input);
    img_3d_raw = read_stack(folder_path, file_name);

    fprintf(['\n\ntracing file: ' file_name '\n\n']);

    
    %pre-processes stack to increase contrast
    img_3d = img_3d_raw;
    if parameters.preprocess
        img_3d = preprocess_stack(img_3d);
        file_name = [file_name '_prep'];
    end


    %%compute enhance tubular structures with meson
    file_name_meson = [file_name '_tmp'];
    write_raw(img_3d, folder_path, file_name_meson);
    meson_output = meson(fullfile(folder_path,file_name_meson), 'radius', parameters.meson_radius);

    if parameters.flag_save_probability
        write_raw(meson_output.output_model, folder_path,[file_name '_probability']);
    end


    %get the position of brighter structures --- we assume that these
    %structures correspond to sperm's heads
    head_output = get_all_heads_center_position(img_3d_raw, 'probability', meson_output.output_model, 'threshold_head', parameters.threshold_head, 'min_conn_comp', parameters.min_conn_comp);
    current_head_positions = get_objects_to_trace(head_output.head_positions, parameters.approximate_head_pos, parameters.max_displacement_head, parameters.track_all_objects);


    %%tracing the center-line with iterative algorithm
    center_output = compute_centerline_for_each_sperm(meson_output.output_model, img_3d_raw, current_head_positions, parameters.max_number_iterations, parameters.length_first_iteration, parameters.length_per_iteration);

    if parameters.save_images
        display_images_steps_3D_centerline_tracing(img_3d_raw, head_output.head_segmentation, current_head_positions, meson_output.output_model, center_output.trace, center_output.trace_last_iteration);
        print(gcf,fullfile(folder_path, [file_name '_output.png']),'-dpng');
    end

    %%save traces
    traces_array = convert_segments_to_array(center_output.trace);
    save_traces(traces_array, folder_path, file_name, parameters.flag_create_folders, parameters.trace_in_VTK_format)

    result = struct('head_positions', current_head_positions, 'output_model', meson_output.output_model, 'traces_array', traces_array);
    fprintf('\n\nCenter-line tracing algorithm has finished ... \n\n\n');
end


function parameters = get_parameters(input_values)
    %default values for algoritm
    min_conn_comp = power(5,3);
    
    p = inputParser;
    p.KeepUnmatched=true;
    addParameter(p,'meson_radius', [2 3 4 5], @(x) isnumeric(x))
    addParameter(p,'threshold_head', inf, @(x) isnumeric(x))
    addParameter(p,'min_conn_comp', min_conn_comp, @(x) isnumeric(x))
    addParameter(p,'approximate_head_pos', [], @(x) isnumeric(x))
    addParameter(p,'max_displacement_head', 20, @(x) isnumeric(x))
    addParameter(p,'preprocess', true, @(x) islogical(x))
    addParameter(p,'track_all_objects', false, @(x) islogical(x))
    addParameter(p,'max_number_iterations', 20, @(x) isnumeric(x))
    addParameter(p,'length_first_iteration', 60, @(x) isnumeric(x))
    addParameter(p,'length_per_iteration', 25, @(x) isnumeric(x))
    addParameter(p,'flag_create_folders', false, @(x) islogical(x))
    addParameter(p,'save_images', true, @(x) isnumeric(x))
    addParameter(p,'trace_in_VTK_format', false, @(x) islogical(x))
    addParameter(p,'flag_save_probability', false, @(x) islogical(x))

    parse(p,input_values{:});    
    parameters = p.Results;
end