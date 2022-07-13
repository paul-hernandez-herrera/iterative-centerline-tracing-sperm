function [linesOut,pathList] = smoothSegments(lines)

    %Each line is a segment
     % Value to clamp lengths (change to 1 for no clamping)
    % Not that it matters, but actual weight will be ClampWeight+1
    %mayor suavizado en el eje Z
    FitParamZ = 0.001;
    FitParamXY = 0.01;
    
    for i = 1 : length(lines)
        % Do fitting
        knots = 1 : size(lines{i},1);
        coefsX = lines{i}(:,1);
        coefsY = lines{i}(:,2);
        coefsZ = lines{i}(:,3);
        
        % Set weights
        weights = 2*ones(1, size(lines{i},1));    
        
        % Do spline        
        weights(1:2) =30;         weights(end-1:end) =30;
        pathList{i}.ppX = csaps(knots, coefsX, FitParamXY, [], weights);
        pathList{i}.ppY = csaps(knots, coefsY, FitParamXY, [], weights);
        pathList{i}.ppZ = csaps(knots, coefsZ, FitParamZ, [], weights);
    end
     
%    lines = cell(1,pcnt);
    for i = 1 : length(lines)
        vertCnt = pathList{i}.ppX.breaks(end);
        knots = 1 : vertCnt;
        
        vertX = fnval(knots, pathList{i}.ppX);
        vertY = fnval(knots, pathList{i}.ppY);
        vertZ = fnval(knots, pathList{i}.ppZ);
        % Start and ending points are the same as the original to ensure
        % connectivity
        vertX(1) = lines{i}(1,1);
        vertY(1) = lines{i}(1,2);        
        vertZ(1) = lines{i}(1,3);        
        
        vertX(end) = lines{i}(end,1);
        vertY(end) = lines{i}(end,2);        
        vertZ(end) = lines{i}(end,3);        
        linesOut{i} = [ vertX; vertY; vertZ ]';        
    end    

end