% this function returns the valid index flag using the given mask

% the whole function is the same as part of the function 'sceneFlowFromMap'

% MASK == true -> occluded
% FLAG == true -> non-occluded

%%
function [FLAG] = indexFlagFromMask(POINTS,PL,MASK)

H = size(MASK,1);
W = size(MASK,2);
L = size(POINTS,1);

% map 3d points to 2d pixels
pixels = PL*[POINTS,ones(L,1)]';
pixels = pixels./pixels(3,:);
pixels = pixels';

% initialization
FLAG = true(L,1);

for i = 1 : L
    pixel = pixels(i,:);
    % check whether the pixel is within the image
    % pixel = (x,y,1), x should be in [1,W], y should be in [1,H]
    x = pixel(1);
    y = pixel(2);
    if (x < 1) || (x > W) || (y < 1) || (y > H) % if outside the boundary
        FLAG(i) = false;
        continue;
    end
    %
    xC = ceil(x);
    xF = floor(x);
    yC = ceil(y);
    yF = floor(y);
    if MASK(yC,xC) || MASK(yC,xF) || MASK(yF,xC) || MASK(yF,xF) % == true := mismatched area
        FLAG(i) = false;
        continue;
    end
end

end