% this function modify the locations of the input vertices using the
    % ground truth of mesh 
    % do not modify the scene flow

% POINTS := selected vertices of the mesh from the previous frame, 
    % for the vertex whose indexFlag == false in the previous frame
    % but indexFlag == true in the current frame
    % move the vertex to its closest 3D point by modifying the DISP
    % search for the closest 3D point in the 3D point map
% SF := scene flow use to move the corresponding point
% ID := the indices of selected vertices to be modified
% POINTS0 := points of the ground truth of mesh
% INDEX,NUM := neighbor relationship in Jagged array
% FLAG0 := valid index of point in POINTS0

% POINTSM := modified vertices
    
%%
function [POINTSM] = vertexModificationClosestVertices(POINTS,SF,ID,POINTS0,INDEX,NUM,FLAG0)

DT = 1; % distance threshold in millimeters
POINTSM = POINTS;
POINTS2 = POINTS + SF;

for iter = 1 : length(ID)
    i = ID(iter);
    neighborPoints = POINTS0(INDEX(NUM(i)+1:NUM(i+1)),:);
    neighborFlag = FLAG0(INDEX(NUM(i)+1:NUM(i+1)),:);
    neighborPoints = neighborPoints(neighborFlag,:);
    % calculate the distance
    distance = sqrt(sum((neighborPoints - POINTS2(i,:)).^2,2));
    % find the closest three points
    [~,order] = sort(distance); % ascending
    if length(order) < 3
        continue;
    end
    closestPoints = neighborPoints(order(1:3),:);
    % calculate a surface normal using the closest three points
    faceNormal = cross(closestPoints(2,:)-closestPoints(1,:),closestPoints(3,:)-closestPoints(1,:));
    if sum(abs(faceNormal)) == 0 % three points are collinear
        % find the projection of POINTS(i,:) on the line
        projectedPoint = closestPoints(1,:) + sum((closestPoints(2,:)-closestPoints(1,:)).*(POINTS2(i,:)-closestPoints(1,:)))...
            *(closestPoints(2,:)-closestPoints(1,:))/sum((closestPoints(2,:)-closestPoints(1,:)).^2);
    else
        faceNormal = faceNormal/norm(faceNormal);
        % find the projection of POINTS(i,:) on the surface
        k = (sum(closestPoints(1,:).*faceNormal) - sum(POINTS2(i,:).*faceNormal))/sum(faceNormal.^2);
        projectedPoint = POINTS2(i,:) + k*faceNormal;
    end
    % check whether the distance between the projected point within limitation
    if sqrt(sum((projectedPoint-POINTS2(i,:)).^2)) > DT
        continue;
    end
    % update POINTS(i,:) but not updating the scene flow
    POINTSM(i,:) = POINTS(i,:) + (projectedPoint - POINTS2(i,:));
end

end