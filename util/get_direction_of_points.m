function direction_points = get_direction_of_points(points)
%only to smooth the current segment <- to compute better the direction of
%the segment
if size(points,1)>1
    current_segment{1} = points;
    current_segment = smoothSegments(current_segment);
    points = current_segment{1};
end

%getting the direction from the segment
direction = [points(:,1)-points(1,1), points(:,2)-points(1,2), points(:,3)-points(1,3)];
direction(1,:) = [];
direction = mean(direction,1);
direction = direction/norm(direction);



if size(points,1)>=3
    %compute the direction just in case that there are more than 3 points
    
    %getting the direction of the segment usingthe principal component with the
    %largest value    
    %P = pca(points);
    P = pca(points);
    
    
    P = P(:,1)';

    %just to make sure that the principal component have the same direction
    %that te points
    direction_points = sign(dot(P,direction)) * P;
else
    %just in case that there are few points to compute the direction
    %the direction will not be taken into account for computing the
    %connection cost
    direction_points = [0 0 0];
end

end