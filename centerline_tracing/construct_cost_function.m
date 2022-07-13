function costFunction = construct_cost_function(probability, v_raw, varargin)
    %this function creates a cost function with higher values close to the
    %centerline
    %The input is assumed to be a 3D image stack with values in the range
    %[0,1] with higher values corresponding to foreground and lower to
    %background

    %gettting input parameters
    parameters = get_parameters(varargin);    

    %just to allow to grown in the whole volume. This step is important in
    %case of gaps/holes in the volume
    probability(probability<0.25)=0.25;
    
    %take into account the original raw intensity values in the cost
    %function
    costFunction = probability.*normalizeVol(single(v_raw),0, 255);
  
    %to trucate values and normalize cost values to not exploit during the
    %application of the exponential.
    max_val_CF = max(costFunction(:)/2);
    costFunction(costFunction>max_val_CF) = max_val_CF;
    
    %smoothing to give high values to the center of the structures
    %(specially for regions with constant values).
    costFunction = imgaussfilt3(costFunction, parameters.gauss_sigma);
    
    %normalize cost function
    costFunction= normalizeVol(costFunction,0.1, 1);

    % exponential to give very high values to the center
    costFunction = exp(parameters.exp_val*costFunction); 

end

function parameters = get_parameters(input_values)
    %default values for algoritm
   
    p = inputParser;
    addParameter(p,'exp_val', 60, @(x) isnumeric(x))
    addParameter(p,'gauss_sigma', [1 1 2], @(x) isnumeric(x))
    
    parse(p,input_values{:});
    
    parameters = p.Results;
end