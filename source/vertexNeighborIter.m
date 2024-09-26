% this function is a combination of function 'vertexNeighbor' and 'neighborIter'

%%
function [INDEX,NUM] = vertexNeighborIter(MESH,ITER)

[INDEX0,NUM0] = vertexNeighbor(MESH);

if ITER == 1
    INDEX = INDEX0;
    NUM = NUM0;
    return;
end

NUM = zeros(length(MESH.Points)+1,1);
for index = 1 : length(MESH.Points)
%     if ~mod(index,10000)
%         disp(100*index/length(MESH.Points));
%     end
    neighborIndex = neighborIter(index,INDEX0,NUM0,ITER);
    NUM(index+1:end) = NUM(index+1:end) + length(neighborIndex);
    INDEX(NUM(index)+1:NUM(index+1)) = neighborIndex;
end
INDEX = INDEX(:);

end

%%
% this function returns the neighbor indices of vertices of each vertex
% MESH := mesh
    
% the outputs are stored in Jagged array
% INDEX := stores the indices of the neighbor vertices
% NUM := has the length as length(MESH.Points)+1, storing the number of
    % neighbor indices of a vertex
    % NUM(1) == 0
% for a given vertex (index = A), its neighbor vertices' indices are
    % INDEX(NUM(A)+1)~INDEX(NUM(A+1))

%%
function [INDEX,NUM] = vertexNeighbor(MESH)

% INDEX = (1:length(MESH.Points))';
% NUM = (0:length(MESH.Points))';

% EDGE = edges(MESH);
% for i = 1 : length(EDGE)
%     for j = 1 : 2
%         INDEX(NUM(EDGE(i,j)+1)+2:end+1) = INDEX(NUM(EDGE(i,j)+1)+1:end);
%         if j == 1
%             INDEX(NUM(EDGE(i,j)+1)+1) = EDGE(i,2);
%         elseif j == 2
%             INDEX(NUM(EDGE(i,j)+1)+1) = EDGE(i,1);
%         end
%         NUM(EDGE(i,j)+1:end) = NUM(EDGE(i,j)+1:end) + 1;
%     end
% end

EDGE = edges(MESH);
EDGE = [EDGE;[EDGE(:,2),EDGE(:,1)]];
INDEX = zeros(length(EDGE)+length(MESH.Points),1);
NUM = (0:length(MESH.Points))';
for index = 1 : length(MESH.Points)
    INDEX(NUM(index)+1) = index;
    neighborIndex = EDGE(EDGE(:,1)==index,2);
    NUM(index+1:end) = NUM(index+1:end) + length(neighborIndex);
    INDEX(NUM(index)+2:NUM(index+1)) = neighborIndex;
end

end

%%
% this function iteratively returns neighbor indices of the vertex with an
    % given index
% INDEX,NUM are outputs of function 'vertexNeighbor'
% ITER := the depth of recursion

% neighborIndex := indices of neighbor vertices of the given vertex

%%
function [neighborIndex] = neighborIter(index,INDEX,NUM,ITER)

neighborIndex = index;

for iter = 1 : ITER
    neighborIndex0 = neighborIndex;
    for j = 1 : length(neighborIndex0)
        neighborIndex = [neighborIndex;INDEX(NUM(neighborIndex0(j))+1:NUM(neighborIndex0(j)+1))];
    end
    neighborIndex = unique(neighborIndex);
end

% for iter = 1 : ITER
%     neighborIndex0 = neighborIndex;
%     counter = 0;
%     for j = 1 : length(neighborIndex0)
%         counter = counter + (NUM(neighborIndex0(j)+1)-NUM(neighborIndex0(j)));
%     end
%     neighborIndex = zeros(counter,1);
%     counter = 0;
%     for j = 1 : length(neighborIndex0)
%         counterT = NUM(neighborIndex0(j)+1)-NUM(neighborIndex0(j));
%         neighborIndex(counter+1:counter+counterT) = INDEX(NUM(neighborIndex0(j))+1:NUM(neighborIndex0(j)+1));
%         counter = counter+counterT;
%     end
%     neighborIndex = unique(neighborIndex);
% end

end