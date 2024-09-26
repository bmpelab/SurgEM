% the function detect rigid area according to the displacement gradient

% DG := displacement gradient

%%
function [indexFlag] = rigidAreaDetector(DG,T)

indexFlag = true(size(DG,1),1);
SDG = zeros(size(DG,1),1);

for i = 1 : length(indexFlag)
    SDG(i) = sum(abs(DG(i,:)));
end

indexFlag = SDG<T;

end