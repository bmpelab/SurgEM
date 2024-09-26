function [E,DE] = edgeMatrix(MESH)
edge = edges(MESH);
M = size(edge,1);
rows = zeros(2*M,1);
cols = zeros(2*M,1);
values = zeros(2*M,1);
for i = 1 : M
    rows(2*i-1) = i;
    rows(2*i) = i;
    cols(2*i-1) = edge(i,1);
    cols(2*i) = edge(i,2);
    values(2*i-1) = -1;
    values(2*i) = 1;
end
E = sparse(rows,cols,values);

DE = E*MESH.Points;

end