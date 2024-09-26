% this function returns the selected indices and scene flow of vertices
    % from the given masks and scene flow map

% POINTS := points of mesh in frame 1
% MASK1 := mask in frame 1, is a logical matrix, == false := not masked area, 
    % masked area means mismatched area
    % MASK has the same size of the image captured by the camera
% MASK2 := mask in frame 2
% MAP := scene flow map between frame 1 and 2
% PL := left camera projection matrix

% SF := the selected scene flow
% FLAG := the selected indices in logical array

%%
function [SF,FLAG] = sceneFlowFromMap(POINTS,MASK1,MASK2,MAP,PL)

H = size(MASK1,1);
W = size(MASK1,2);
L = size(POINTS,1);

% map 3d points to 2d pixels
pixels = PL*[POINTS,ones(L,1)]';
pixels = pixels./pixels(3,:);
pixels = pixels';

% initialization
FLAG = true(L,1);
SF = zeros(L,3);

parfor index = 1 : L
    pixel = pixels(index,:);
    % check whether the pixel is within the image
    % pixel = (x,y,1), x should be in [1,W], y should be in [1,H]
    x = pixel(1);
    y = pixel(2);
    if (x < 1) || (x > W) || (y < 1) || (y > H) % if outside the boundary
        FLAG(index) = false;
        SF(index,:) = 0;
        continue;
    end
    %
    xC = ceil(x);
    xF = floor(x);
    yC = ceil(y);
    yF = floor(y);
    if MASK1(yC,xC) || MASK1(yC,xF) || MASK1(yF,xC) || MASK1(yF,xF) % == true := mismatched area
        FLAG(index) = false;
        SF(index,:) = 0;
        continue;
    end
    % generate scene flow value from the scene flow map using bilinear
    % interpolation, and check whether all four neighbor pixels contain
    % scene flow value
    w1 = [x-xF, xC-x]; % already normalized
    w2 = [y-yF, yC-y];
    sceneFlow = w2(2)*(w1(1)*MAP(yF,xC,:) + w1(2)*MAP(yF,xF,:))...
        + w2(1)*(w1(1)*MAP(yC,xC,:) + w1(2)*MAP(yC,xF,:));
    sceneFlow = squeeze(sceneFlow)';
    
%     if sqrt(sum(sceneFlow.^2)) > 1
%         FLAG(index) = false;
%         SF(index,:) = 0;
%         continue;
%     end
    
    SF(index,:) = sceneFlow;
    
    % updated vertex
    point2 = POINTS(index,:) + sceneFlow;
    pixel2 = PL*[point2,1]';
    pixel2 = pixel2/pixel2(3);
    pixel2 = pixel2';
    % check the location of the projection of the updated vertex
    % boundary
    x2 = pixel2(1);
    y2 = pixel2(2);
    if (x2 < 1) || (x2 > W) || (y2 < 1) || (y2 > H) % if outside the boundary
        FLAG(index) = false;
        SF(index,:) = 0;
        continue;
    end
    % mask
    xC2 = ceil(x2);
    xF2 = floor(x2);
    yC2 = ceil(y2);
    yF2 = floor(y2);
    if MASK2(yC2,xC2) || MASK2(yC2,xF2) || MASK2(yF2,xC2) || MASK2(yF2,xF2) % == true := mismatched area
        FLAG(index) = false;
        SF(index,:) = 0;
        continue;
    end
end

end