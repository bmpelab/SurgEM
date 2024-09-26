% this function measure the error between a vertex of the updated mesh and
    % its projected point in the plane formed by the three closest vertices
    % in the ground truth mesh

% M := the updated mesh
% GT := the ground truth of a mesh
% INDEX,NUM := neighbor vertices in Jagged array

% E := surface errors for each vertex in the mesh M
    
%%
function [E] = surfaceErrorClosestVertices(M,GT,INDEX,NUM)

E = zeros(size(M.Points,1),1);

for i = 1 : size(M.Points,1)
    indices = INDEX(NUM(i)+1:NUM(i+1));
    neighborPoints = GT.Points(indices,:);
    distance = sqrt(sum((neighborPoints-M.Points(i,:)).^2,2));
    [~,order] = sort(distance); % ascending
    % find the closest three vertices
    closestPoints = neighborPoints(order(1:3),:);
    % calculate a surface normal using the closest three points
    faceNormal = cross(closestPoints(2,:)-closestPoints(1,:),closestPoints(3,:)-closestPoints(1,:));
    if sum(abs(faceNormal)) == 0 % three points are collinear
        % find the projection of POINTS(i,:) on the line
        projectedPoint = closestPoints(1,:) + sum((closestPoints(2,:)-closestPoints(1,:)).*(M.Points(i,:)-closestPoints(1,:)))...
            *(closestPoints(2,:)-closestPoints(1,:))/sum((closestPoints(2,:)-closestPoints(1,:)).^2);
    else
        faceNormal = faceNormal/norm(faceNormal);
        % find the projection of POINTS(i,:) on the surface
        k = (sum(closestPoints(1,:).*faceNormal) - sum(M.Points(i,:).*faceNormal))/sum(faceNormal.^2);
        projectedPoint = M.Points(i,:) + k*faceNormal;
    end
    % calculate the distance between the projected point and the vertex
    E(i) = sqrt(sum((projectedPoint-M.Points(i,:)).^2));
end

end