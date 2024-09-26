function [EFLAG] = edgeSelect(MESH,PFLAG)
edge = edges(MESH);
M = size(edge,1);
EFLAG = false(M,1);
for i = 1 : M
    p1 = edge(i,1);
    if ~PFLAG(p1)
        continue;
    end
    p2 = edge(i,2);
    if ~PFLAG(p2)
        continue;
    end
    EFLAG(i) = true;
end

end