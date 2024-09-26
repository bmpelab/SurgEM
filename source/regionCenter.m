%

%%
function [C] = regionCenter(MASK)

rows = size(MASK,1);
cols = size(MASK,2);
rmin = rows;
rmax = 1;
for r = 1 : rows
    for c = 1 : cols
        if MASK(r,c)
            if rmin > r
                rmin = r;
            end
            if rmax < r
                rmax = r;
            end
        end
    end
end
C = zeros(1,2);
counter = 0;
for r = round(rmin) : round(rmin+1*(rmax-rmin))
    for c = 1 : cols
        if MASK(r,c)
            counter = counter + 1;
            C(1) = C(1) + c;
            C(2) = C(2) + r;
        end
    end
end
C = round(C/counter);
end