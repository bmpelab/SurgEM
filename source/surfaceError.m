% this function measure the error between a vertex of the updated mesh and
    % its projected point in the plane formed by the three closest vertices
    % in the ground truth mesh

% POINTS := vertices of the mesh in the current frame
% PL := left camera projection matrix
% MAP := 3D point map from the current frame
% MASK := occluded area == 1

% E := surface errors for each vertex in the mesh M
% OF := occluded flag == 1
    
%%
function [E,EX,EY,EZ,OF] = surfaceError(POINTS,PL,MAP,MASK)

W = size(MAP,2);
H = size(MAP,1);
N = size(POINTS,1);
HWS = 3; % half window size, window size is 2*HWS by 2*HWS
E = zeros(N,1);
EX = zeros(N,1);
EY = zeros(N,1);
EZ = zeros(N,1);
OF = false(N,1);

points = [POINTS,ones(N,1)]'; % points is a 4 by n matrix, vertices in homogenous coordinate
pixels = PL*points;
pixels = pixels(1:2,:)./pixels(3,:);
pixels = pixels'; % n by 3 matrix
PIXELS = round(pixels(:,1:2)); % n by 2 matrix

for i = 1 : N
    if MASK(PIXELS(i,2),PIXELS(i,1))
        OF(i) = true;
    end
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
    neighborPoints = zeros((x_range(2)-x_range(1)+1)*(y_range(2)-y_range(1)+1),3);
    counter = 1;
    for r = y_range(1) : y_range(2)
        for c = x_range(1) : x_range(2)
            neighborPoints(counter,:) = squeeze(MAP(r,c,:))';
            counter = counter + 1;
        end
    end
    % calculate the distance
    distance = sqrt(sum((neighborPoints - POINTS(i,:)).^2,2));
    % find the closest three points
    [~,order] = sort(distance); % ascending
    if length(order) < 3
        E(i) = NaN;
        continue;
    end
    closestPoints = neighborPoints(order(1:3),:);
    % calculate a surface normal using the closest three points
    faceNormal = cross(closestPoints(2,:)-closestPoints(1,:),closestPoints(3,:)-closestPoints(1,:));
    if sum(abs(faceNormal)) == 0 % three points are collinear
        % find the projection of POINTS(i,:) on the line
        projectedPoint = closestPoints(1,:) + sum((closestPoints(2,:)-closestPoints(1,:)).*(POINTS(i,:)-closestPoints(1,:)))...
            *(closestPoints(2,:)-closestPoints(1,:))/sum((closestPoints(2,:)-closestPoints(1,:)).^2);
    else
        faceNormal = faceNormal/norm(faceNormal);
        % find the projection of POINTS(i,:) on the surface
        k = (sum(closestPoints(1,:).*faceNormal) - sum(POINTS(i,:).*faceNormal))/sum(faceNormal.^2);
        projectedPoint = POINTS(i,:) + k*faceNormal;
    end
%     % check whether the distance between the projected point within limitation
%     if sqrt(sum((projectedPoint-POINTS(i,:)).^2)) > DT
%         continue;
%     end
    % calculate error
    E(i) = sqrt(sum((POINTS(i,:)-projectedPoint).^2));
    EX(i) = abs(POINTS(i,1)-projectedPoint(1));
    EY(i) = abs(POINTS(i,2)-projectedPoint(2));
    EZ(i) = abs(POINTS(i,3)-projectedPoint(3));
end

end