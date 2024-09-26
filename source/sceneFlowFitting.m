% this function uses pixel-wise least square algorithm to fit the scene flow
    % values for invalid vertices
% POINTS := input points of mesh, size(POINTS) == [length(POINTS),3]
% INDEX,NUM := outputs of the function 'vertexNeighborIter'
    % storing the neighbor relationships of vertices in Jagged array
    % size(NUM) == [length(POINTS)+1,1]
% SF := scene flow value, for those invalid vertices, the values are [0,0,0]
    % size(SF) == [length(POINTS),3]
% FLAG == true means valid, == false means invalid,
    % size(FLAG) == [length(POINTS),1]
% DT := distance threshold, recommend 3 mm

% DISP := the fitted scene flow value, to distinguished between the input SF,
    % here we use DISP (displacement)
    % size(DISP) == [length(POINTS),3]
% DG := displacement gradient, size(DG) == [length(POINTS),9]

%%
function [DISP,DG] = sceneFlowFitting(POINTS,INDEX,NUM,SF,FLAG,DT)

% displacement gradient and smoothed displacement [4 by 3]
% note: partial derivative := pd
% dispGrad_smoothDisp = |     u0          v0          w0    |
%                       |pd(u)/pd(x) pd(v)/pd(x) pd(w)/pd(x)|
%                       |pd(u)/pd(y) pd(v)/pd(y) pd(w)/pd(y)|
%                       |pd(u)/pd(z) pd(v)/pd(z) pd(w)/pd(z)|
% DISP(n,:) = [u0 v0 w0]
% DG(n,:) = [pd(u)/pd(x) pd(v)/pd(x) pd(w)/pd(x) ...]
DISP = SF;
DG = zeros(length(FLAG),9);
% initialization
indexFlag = FLAG;
indexFlag2 = indexFlag;
invalidIndex = find(~indexFlag2);
%loop = 0;
while(~isempty(invalidIndex))
    %loop = loop + 1;
    invalidINDEX = [];
    invalidNUM = zeros(length(invalidIndex)+1,1);
    for i = 1 : length(invalidIndex)
        % the indices of neighbor vertices of the invalid vertices
        invalidINDEX(end+1:end+NUM(invalidIndex(i)+1)-NUM(invalidIndex(i)))...
            = INDEX(NUM(invalidIndex(i))+1:NUM(invalidIndex(i)+1));
        invalidNUM(i+1:end) = invalidNUM(i+1:end)...
            + NUM(invalidIndex(i)+1) - NUM(invalidIndex(i));
    end
    invalidINDEXFlag = true(length(invalidINDEX),1);
    for i = 1 : length(invalidINDEXFlag)
        invalidINDEXFlag(i) = indexFlag(invalidINDEX(i));
    end
    numOfValidNeighbor = zeros(length(invalidIndex),1);
    for i = 1 : length(numOfValidNeighbor)
        numOfValidNeighbor(i) = sum(invalidINDEXFlag(invalidNUM(i)+1:invalidNUM(i+1)));
    end
    indexFlag2 = true(length(invalidIndex),1);
    for i = 1 : length(indexFlag2)
        indexFlag2(i) = numOfValidNeighbor(i)>=12;
    end
    % do the least square for index == invalidIndex(indexFlag2)
    invalidIndex2 = find(indexFlag2);
    for i = 1 : length(invalidIndex2)
        index2 = invalidIndex2(i);
        neighborIndex = invalidINDEX(invalidNUM(index2)+1:invalidNUM(index2+1));        
        neighborIndexFlag = invalidINDEXFlag(invalidNUM(index2)+1:invalidNUM(index2+1));
        neighborIndex = neighborIndex(neighborIndexFlag);
        num = length(neighborIndex); % num >= 12

        % coor is a num by 4 matrix
        % relative coordinates to MESH1.Points(indexMap(r,c),:)
        % coor = |1 DeltaX1 DeltaY1 DeltaZ1|
        %        |1 DeltaX2 DeltaY2 DeltaZ2|
        %        |         ......          |
        coor = ones(num,4);
        coor(:,2:end) = POINTS(neighborIndex,:) - POINTS(invalidIndex(index2),:);
        % coor*[displacement gradient] = disp
        % [displacement gradient] = dispGrad is a 4 by 3 matrix
        % if rank(coor) == 4, which means coor has full column rank
        % its pseudo inverse matrix exists
        % note that coor_pi is the pseudo inverse matrix of coor
        % coor_pi is a 4 by num matrix
        % coor_pi*coor = I(4x4)
        % coor_pi*coor*dispGrad = dispGrad = coor_pi*disp
        % add distance limitation
        distanceFlag = (sqrt(sum(coor(:,2:4).^2,2)) < DT);
        coor = coor(distanceFlag,:);
        neighborIndex = neighborIndex(distanceFlag);
        num = length(neighborIndex); % num >= 12
        if num < 12
            indexFlag2(index2) = false;
            continue;
        end
        if rank(coor) < 4 % coor do not have full column rank
            indexFlag2(index2) = false;
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
        DG(invalidIndex(index2),:) = [dispGrad_smoothDisp(2,:),dispGrad_smoothDisp(3,:),dispGrad_smoothDisp(4,:)];
        DISP(invalidIndex(index2),:) = dispGrad_smoothDisp(1,:);
        SF(invalidIndex(index2),:) = dispGrad_smoothDisp(1,:);
    end
    
    % update indexFlag and invalidIndex with indexFlag2
    indexFlag(invalidIndex(indexFlag2)) = true;
    invalidIndex = invalidIndex(~indexFlag2);
end

end