% this function uses the laplacian mesh editing algorithms to update the mesh

% model: ||Le·C-C^*||^2 + ALPHA·||L·C-DELTA||^2
% model: ||Le·C-C^*||^2 + ALPHA·||E·C-DE||^2
%%
function [sceneFlow] = model_DS_cls(POINTS,FLAG,SF,ALPHA,L,DELTA,PL,MAP,MASKN)

N = size(POINTS,1);
M = sum(FLAG);
indices = find(FLAG);

% generate anchors
anchors = POINTS(FLAG,:)+SF(FLAG,:);

% generate additional sparse laplacian matrix
rows = (1:M)';
cols = indices(:);
values = ones(M,1);
Le = sparse(rows,cols,values,M,N);

La = [Le;ALPHA*L];
Da = [anchors;ALPHA*DELTA];
% Da = La*C, C is the smoothed vertices
dLa = decomposition(La);
C = dLa\Da; % C = [X Y Z]

FLAG2 = indexFlagFromMask(C,PL,MASKN);

M2 = sum(FLAG2);
if M2 == N
    sceneFlow = C - POINTS;
    return;
end

% find constraint for Z
[pz] =  findPz(C,FLAG2,PL,MAP);
% if the corresponding pz is lower than Cz := pz>Cz-5
% we neglect such pz, by setting the corresponding FLAG2 as true
pzFlag = logical(pz-C(~FLAG2,3)>5);
% disp(sum(pzFlag)/length(pzFlag));
FLAG2(~FLAG2) = pzFlag;
pz = pz(~pzFlag);

% generate invalid selection matrix
M2 = sum(FLAG2);
if M2 == N
    sceneFlow = C - POINTS;
    return;
end
rows = (1:N-M2)';
indices2 = find(~FLAG2);
cols = indices2(:);
values = ones(N-M2,1);
S = sparse(rows,cols,values,N-M2,N);

C(:,3) = lsqlin(La,Da(:,3),-S,-pz);

sceneFlow = C - POINTS;

end
%%
function [pz] =  findPz(C,FLAG,PL,MAP)

N = sum(~FLAG);
W = size(MAP,2);
H = size(MAP,1);

Ci = C(~FLAG,:);
vi = PL*[Ci,ones(N,1)]';
vi = vi./vi(3,:);
vi = round(vi');

pz = zeros(N,1);
parfor i = 1 : N
    y = vi(i,2);
    x = vi(i,1);
    if x < 1 || y < 1 || x > W || y > H
        pz(i) = -inf;
        continue;
    end
    pz(i) = MAP(y,x,3);
end

end