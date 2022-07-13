function output = get_all_heads_center_position(stack, varargin)
    %This function segments te 3D input image stack using the threshold
    %provided by the user or automatically using the otsu algorithm. Then,
    %it elliminates small connected components and extract the centroid for
    %each connected component. 
    
    parameters = get_parameters(varargin);    
    
    seg = do_segmentation(stack, parameters);
    
    head_positions = get_center_position(seg, parameters.min_conn_comp); 

    output.head_segmentation = seg;
    output.head_positions = head_positions;
end

function parameters = get_parameters(input_values)
    %default values
    min_conn_comp = power(4,3);
    
    p = inputParser;

    addParameter(p,'threshold_head', inf, @(x) isnumeric(x))
    addParameter(p,'min_conn_comp', min_conn_comp, @(x) isnumeric(x))
    addParameter(p,'probability', 1, @(x) isnumeric(x))
    
    parse(p,input_values{:});
        
    parameters = p.Results;
end

function seg = do_segmentation(stack,parameters)
    %segment the head
    if parameters.threshold_head~=inf
        %the user gave value to threshold_head, segment head with this
        %value
        seg = stack > parameters.threshold_head;
    else
        %default segmentation method OTSU
        %seg = imbinarize(stack);
        
        %modify version of otsu were the pixel with low probability are
        %aliminate in the calculation of the otsu threshold
        stack = single(stack).*single(parameters.probability>0.5);

        %graythreshold for single values requires to be normalized in [0,1]
        stack = stack/max(stack(:));

        %only computing the otsu using values in the foreground
        I = stack>0;

        %computing threshold otsu
        threshold_otsu = graythresh(stack(I));

        %segmentation
        seg = stack > threshold_otsu;
    end
end

function head_positions = get_center_position(seg, min_num_components)
    %get the center for each structure given the segmentation
    %currently using number of voxels to discard structures, we should use
    %structure size (microns)
    
    conComp = bwconncomp(seg,26);
    
    head_positions = [];
    for i=1:conComp.NumObjects
        if (length(conComp.PixelIdxList{i})>= min_num_components)
            %only gets the centroid for structures larger in size than the
            %predifined min_connected sized
            [I,J,K] = ind2sub(size(seg),conComp.PixelIdxList{i});
            x = round(mean(I));
            y = round(mean(J));
            z = round(mean(K));
            
            head_positions = [head_positions; [x y z]];
        end
    end    
end

        