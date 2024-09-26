% this function modify the locations of the input vertices using the
    % reconstructed 3D points 
    % do not modify the scene flow

% POINTS := selected vertices of the mesh from the previous frame, 
    % for the vertex whose indexFlag == false in the previous frame
    % but indexFlag == true in the current frame
    % move the vertex to its closest 3D point by modifying the DISP
    % search for the closest 3D point in the 3D point map
% SF := scene flow use to move the corresponding point
% PL := left camera projection matrix
% MAP := 3D point map
% MASK := segmentation result,
    % == false := valid
    % == true := invalid, mismatch
    % in practice, MASK is the segmentation results
    % in simulation experiment, MASK is generated using the segmented mask
    % and pointMapFlag = (sum(abs(pointMap),3)==0)，
    % pointMap is generated from the 'pointMapFrom3DPoints' function

% POINTS2 := modified vertices
    
%%
function [POINTSM,SFM] = vertexModification(POINTS,SF,PL,MAP,MASK,DT)

W = size(MASK,2);
H = size(MASK,1);
N = size(POINTS,1);
HWS = 3; % half window size, window size is 2*HWS by 2*HWS
POINTSM = POINTS;
SFM = SF;

% pixels are guaranteed to be within the image by the function of 'sceneFlowValidationCheck'
% therefore, it is unnecessary to check the boundary
POINTS2 = POINTS + SF;
points2 = [POINTS2,ones(N,1)]'; % points is a 4 by n matrix, vertices in homogenous coordinate
pixels2 = PL*points2;
pixels2 = pixels2(1:2,:)./pixels2(3,:);
pixels2 = pixels2'; % n by 3 matrix
PIXELS = round(pixels2(:,1:2)); % n by 2 matrix

parfor i = 1 : N
    % search within a 7 by 7 window
    % select those 3D points whose MASK value is true
    x_range = [PIXELS(i,1)-HWS, PIXELS(i,1)+HWS];
    y_range = [PIXELS(i,2)-HWS, PIXELS(i,2)+HWS];
    if x_range(1) < 1
        x_range(1) = 1;
    end
    if x_range(2) > W
        x_range(2) = W;
    end
    if y_range(1) < 1
        y_range(1) = 1;
    end
    if y_range(2) > H
        y_range(2) = H;
    end
    neighborPoints = [];
    for r = y_range(1) : y_range(2)
        for c = x_range(1) : x_range(2)
            if ~MASK(r,c)
                neighborPoints = [neighborPoints;squeeze(MAP(r,c,:))'];
            end
        end
    end
    if isempty(neighborPoints)
        continue;
    end
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
    % update the scene flow but not updating the point
    SFM(i,:) = SF(i,:) + (projectedPoint - POINTS2(i,:));
end

end