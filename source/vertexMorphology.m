% PointSelected: points that have been selected from TR.Points, size of
% PointSelected is the same as the length of TR.Points
    % PointSelected(i) == 1 means selected
    % PointSelected(i) == 0 means not selected
% TR: triangulation
% type: type of morphology operation

%%
function [PointSelected2] = vertexMorphology(PointSelected,TR,type)

PointID = find(PointSelected == 1);
E = edges(TR);
Flag = zeros(size(E,1),2);

for i = 1 : size(PointID,1)
    Flag_t = (E == PointID(i));
    Flag = Flag + Flag_t;
end

PointID2 = E((sum(Flag,2)==1),:);
PointID2 = PointID2(:);
PointSelected2 = PointSelected;

if strcmp(type,"dilate")
    PointSelected2(PointID2) = 1;
    PointSelected2 = logical(PointSelected2);
elseif strcmp(type,"erode")
    PointSelected2(PointID2) = 0;
    PointSelected2 = logical(PointSelected2);
else
    PointSelected2 = 0;
    disp("morphology type not included");
end

end