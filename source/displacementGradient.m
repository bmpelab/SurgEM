% this function uses pixel-wise least square algorithm to fit the scene flow
    % values for invalid vertices
% POINTS := input points of mesh, size(POINTS) == [length(POINTS),3]
% INDEX,NUM := outputs of the function 'vertexNeighborIter, 3-ring neighbor
    % storing the neighbor relationships of vertices in Jagged array
    % size(NUM) == [length(POINTS)+1,1]
% SF := scene flow value, for those invalid vertices, the values are [0,0,0]
    % size(SF) == [length(POINTS),3]
% DT := distance threshold, recommend 3 mm

% DG := displacement gradient, size(DG) == [length(POINTS),9]

%%
function [DG,MPS] = displacementGradient(POINTS,INDEX,NUM,SF,FLAG,DT)

% displacement gradient and smoothed displacement [4 by 3]
% note: partial derivative := pd
% dispGrad_smoothDisp = |     u0          v0          w0    |
%                       |pd(u)/pd(x) pd(v)/pd(x) pd(w)/pd(x)|
%                       |pd(u)/pd(y) pd(v)/pd(y) pd(w)/pd(y)|
%                       |pd(u)/pd(z) pd(v)/pd(z) pd(w)/pd(z)|
% DISP(n,:) = [u0 v0 w0]
% DG(n,:) = [pd(u)/pd(x) pd(v)/pd(x) pd(w)/pd(x) ...]
DISP = SF;
DG = zeros(size(POINTS,1),9);
MPS = zeros(size(POINTS,1),1);
parfor i = 1 : size(POINTS,1)
    if ~FLAG(i)
        continue;
    end
    neighborIndex = INDEX(NUM(i)+1:NUM(i+1));
    num = length(neighborIndex); % num >= 12
    if num < 12
        continue;
    end
    % coor is a num by 4 matrix
    % relative coordinates to MESH1.Points(indexMap(r,c),:)
    % coor = |1 DeltaX1 DeltaY1 DeltaZ1|
    %        |1 DeltaX2 DeltaY2 DeltaZ2|
    %        |         ......          |
    coor = ones(num,4);
    coor(:,2:end) = POINTS(neighborIndex,:) - POINTS(i,:);
    % coor*[displacement gradient] = disp
    % [displacement gradient] = dispGrad_smoothDisp is a 4 by 3 matrix
    % if rank(coor) == 4, which means coor has full column rank
    % its pseudo inverse matrix exists
    % note that coor_pi is the pseudo inverse matrix of coor
    % coor_pi is a 4 by num matrix
    % coor_pi*coor = I(4x4)
    % coor_pi*coor*dispGrad_smoothDisp = dispGrad_smoothDisp = coor_pi*disp
    % add distance limitation
    distanceFlag = (sqrt(sum(coor(:,2:4).^2,2)) < DT);
    coor = coor(distanceFlag,:);
    neighborIndex = neighborIndex(distanceFlag);
    num = length(neighborIndex); % num >= 12
    if num < 12
        continue;
    end
    if rank(coor) < 4 % coor do not have full column rank
        continue;
    end
    % calculate coor^(+)
    coor_pi = (coor'*coor)\coor';
    % disp is a num by 3 matrix
    % disp = |u1 v1 w1|
    %        |u2 v2 w2|
    %        | ...... |
    disp = SF(neighborIndex,:);
    % displacement gradient [4 by 3]
    % note: partial derivative := pd
    % dispGrad_smoothDisp = |     u0          v0          w0    |
    %                       |pd(u)/pd(x) pd(v)/pd(x) pd(w)/pd(x)|
    %                       |pd(u)/pd(y) pd(v)/pd(y) pd(w)/pd(y)|
    %                       |pd(u)/pd(z) pd(v)/pd(z) pd(w)/pd(z)|
    dispGrad_smoothDisp = coor_pi*disp;
    DG(i,:) = [dispGrad_smoothDisp(2,:),dispGrad_smoothDisp(3,:),dispGrad_smoothDisp(4,:)];
    DISP(i,:) = dispGrad_smoothDisp(1,:);
    % strainTensor = [3 by 3] is a symmetric matrix
    %              = |epsilon_xx epsilon_xy epsilon_xz|
    %                |epsilon_yx epsilon_yy epsilon_yz|
    %                |epsilon_zx epsilon_zy epsilon_zz|
    strainTensor = zeros(3,3);
    strainTensor(1,1) = dispGrad_smoothDisp(2,1); % epsilon_xx = pd(u)/pd(x)
    strainTensor(2,2) = dispGrad_smoothDisp(3,2); % epsilon_yy = pd(v)/pd(y)
    strainTensor(3,3) = dispGrad_smoothDisp(4,3); % epsilon_zz = pd(w)/pd(z)
    strainTensor(1,2) = 0.5*(dispGrad_smoothDisp(3,1)+dispGrad_smoothDisp(2,2)); % epsilon_xy = 0.5*(pd(u)/pd(y)+pd(v)/pd(x))
    strainTensor(1,3) = 0.5*(dispGrad_smoothDisp(4,1)+dispGrad_smoothDisp(2,3)); % epsilon_xz = 0.5*(pd(u)/pd(z)+pd(w)/pd(x))
    strainTensor(2,3) = 0.5*(dispGrad_smoothDisp(4,2)+dispGrad_smoothDisp(3,3)); % epsilon_yz = 0.5*(pd(v)/pd(z)+pd(w)/pd(y))
    strainTensor(2,1) = strainTensor(1,2);
    strainTensor(3,1) = strainTensor(1,3);
    strainTensor(3,2) = strainTensor(2,3);
    % calculate the eigenvalues of strain tensor
    % using singular value decomposition (SVD) 
    principalStrain = sqrt(svd(strainTensor));
    % store the maximum principal strain
    MPS(i) = max(principalStrain);
end

end