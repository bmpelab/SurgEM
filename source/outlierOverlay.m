%

%%
function [OVERLAY] = outlierOverlay(FLAG,FLAG2,POINTS,PL,IMG)

OVERLAY = IMG;
for i = 1 : length(FLAG)
    if ~FLAG2(i)
        pixel = PL*[POINTS(i,:),1]';
        pixel = pixel/pixel(3);
        pixel = round(pixel(1:2)'); % [x y]
        if pixel(1)<1 || pixel(2)<1 || pixel(1)>size(IMG,2) || pixel(2)>size(IMG,1)
            continue;
        end
        OVERLAY(pixel(2),pixel(1),:) = [squeeze(IMG(pixel(2),pixel(1),1));...
            255;squeeze(IMG(pixel(2),pixel(1),3))];
    elseif ~FLAG(i)
        pixel = PL*[POINTS(i,:),1]';
        pixel = pixel/pixel(3);
        pixel = round(pixel(1:2)'); % [x y]
        if pixel(1)<1 || pixel(2)<1 || pixel(1)>size(IMG,2) || pixel(2)>size(IMG,1)
            continue;
        end
        OVERLAY(pixel(2),pixel(1),:) = [255;...
            squeeze(IMG(pixel(2),pixel(1),2));squeeze(IMG(pixel(2),pixel(1),3))];
    end
end

end