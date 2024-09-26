clear; clc;
mask_flag = true;
pose_flag = true;
% batch processing using mesh-based outlier detector real data
addpath(genpath('./source'));
data_folder = 'G:/chen/Documents/DataManagement/Data/g1';
if mask_flag
mask_folder = [data_folder '/mask'];
end
image_folder = [data_folder '/rectified_left'];
sceneflow_map_folder = [data_folder '/scene_flow'];
point3d_map_folder = [data_folder '/point_3d_map'];
if pose_flag
constraint_map_folder = [data_folder '/constraint_map'];
end
output_mesh_folder = [data_folder '/mesh'];
if ~exist(output_mesh_folder,'dir')
    mkdir(output_mesh_folder);
end
% load camera projection matrix
load([data_folder '/rectifiedCamera.mat']);

% scene flow file (.mat) list
sceneflow_map_dir = dir([sceneflow_map_folder '/*.mat']);
sceneflow_map_names = {sceneflow_map_dir.name};
[sceneflow_map_names,~] = sortNat(sceneflow_map_names);
if mask_flag
% mask file (.png) list
mask_dir = dir([mask_folder '/*.png']);
mask_names = {mask_dir.name};
[mask_names,~] = sortNat(mask_names);
end
% point map file (.mat) list
point3d_map_dir = dir([point3d_map_folder '/*.mat']);
point3d_map_names = {point3d_map_dir.name};
[point3d_map_names,~] = sortNat(point3d_map_names);
% image
image_dir = dir([image_folder '/*.png']);
image_names = {image_dir.name};
[image_names,~] = sortNat(image_names);
if pose_flag
% constraint map file (.mat) list
constraint_map_dir = dir([constraint_map_folder '/*.mat']);
constraint_map_names = {constraint_map_dir.name};
[constraint_map_names,~] = sortNat(constraint_map_names);
end

%
mesh0 = stlread([data_folder '/0.stl']);
image = imread([image_folder '/' image_names{1}]);
vertices = mesh0.Points;
faces = mesh0.ConnectivityList;
for j = 1 : size(vertices,1)
    pixel = PL*[vertices(j,:)';1];
    pixel = pixel/pixel(3);
    r = round(pixel(2))+1;
    c = round(pixel(1))+1;
    if r < 1 || r > size(image,1) || c < 1 || c > size(image,2)
        continue;
    end
    vertice_colors(j,:) = squeeze(double(image(r,c,:)))/255;
end
mesh_color = surfaceMesh(vertices,faces,VertexColors=vertice_colors);
writeSurfaceMesh(mesh_color,[output_mesh_folder '\' erase(point3d_map_names{1},'mat') 'ply']);
% 
[INDEX1,NUM1] = vertexNeighborIter(mesh0,1);
[INDEX2,NUM2] = vertexNeighborIter(mesh0,2); % store the neighbor relationships in Jagged array
[INDEX3,NUM3] = vertexNeighborIter(mesh0,3); % store the neighbor relationships in Jagged array
[E,DE] = edgeMatrix(mesh0);

%%
meshOutput = mesh0;
sceneFlowN = zeros(length(mesh0.Points),3);
indexFlagN = true(length(mesh0.Points),1);
indexFlagR = true(length(mesh0.Points),1);
indexFlagM = true(length(mesh0.Points),1);
indexFlag = false(length(mesh0.Points),1);
if mask_flag
    maskN = imread([mask_folder '/' mask_names{1}]);
    maskN = logical((maskN(:,:,1)==0).*(maskN(:,:,2)==255).*(maskN(:,:,3)==0)); % == true := mismatched area
    mask0 = false(size(maskN));
else
    maskN = false(size(image,1),size(image,2));
    mask0 = false(size(maskN));
end

figure(1);hold on;pause();
for i = 1 : length(sceneflow_map_names)
    disp(i);
    clf(1);
    trisurf(meshOutput,'FaceColor','w');hold on;
    indexFlagLen = logical(indexFlagR~=indexFlagN);
    plot3(meshOutput.Points(indexFlagLen,1),...
        meshOutput.Points(indexFlagLen,2),meshOutput.Points(indexFlagLen,3),'b.');
    plot3(meshOutput.Points(~indexFlagN,1),...
        meshOutput.Points(~indexFlagN,2),meshOutput.Points(~indexFlagN,3),'r.');
    plot3(meshOutput.Points(~indexFlagM,1),...
        meshOutput.Points(~indexFlagM,2),meshOutput.Points(~indexFlagM,3),'g.');
    view(0,-90);axis image;pause(0.1);
    % vertices to be updated
    Points = meshOutput.Points;
    % select valid scene flow
    maskC = maskN;
    if mask_flag
        maskN = imread([mask_folder '/' mask_names{i+1}]);
        maskN = logical((maskN(:,:,1)==0).*(maskN(:,:,2)==255).*(maskN(:,:,3)==0)); % == true := mismatched area
    else
        maskN = mask0;
    end
    % load scene flow map as sceneFlowMap!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    sceneFlowMap = load([sceneflow_map_folder '\' sceneflow_map_names{i}]).scene_flow_map;
    % if a vertex is outside the image or in the mismatched area
    % its corresponding indexFlag is false
    indexFlagC = indexFlagN;
    % the input is sceneFlowMap, size = [HxWx3]
    % output is sceneFlowForMesh, size = [length(Points),3]
    sceneFlowC = sceneFlowN;
    [~,indexFlagM] = sceneFlowFromMap(Points,maskC,maskN,sceneFlowMap,PL);
    [sceneFlowN,~] = sceneFlowFromMap(Points,mask0,mask0,sceneFlowMap,PL);
    [~,MPS] = displacementGradient(Points,INDEX3,NUM3,sceneFlowN,true(size(Points,1),1),10);
    [indexFlagN] = rigidAreaDetector(MPS,1);
    indexFlagN = logical(indexFlagN.*indexFlagM);
    
    % for the vertex whose indexFlagC == false but indexFlagN == true
        % search for the closest thress 3D point in the 3D point map
        % and modify the vertex location
    % load 3D point map as pointMap
    pointMap = load([point3d_map_folder '\' point3d_map_names{i+1}]).point_3d_map;
    maskPointMap = (sum(abs(pointMap),3)==0); % annotate empty value with true
    maskPointMap = logical(maskPointMap);
    % selection
    indexFlag = logical((indexFlagC == false).*(indexFlagN == true));
    % error compensation
    % updated scene flow
%     indexFlag(:) = false; disp("forbid vertexModification");
    [~,sceneFlow_temp] = vertexModification(Points(indexFlag,:),sceneFlowN(indexFlag,:),PL,pointMap,maskPointMap,5);
    sceneFlowN(indexFlag,:) = sceneFlow_temp;
    [~,MPS] = displacementGradient(Points,INDEX3,NUM3,sceneFlowN,true(size(Points,1),1),10);
    [indexFlagN] = rigidAreaDetector(MPS,1);
    indexFlagN = logical(indexFlagN.*indexFlagM);
    
    sceneFlowTemp = sceneFlowN(indexFlagN,:);
    lens = sqrt(sum(sceneFlowTemp.^2,2));
    t99 = prctile(lens,99);
    %t1 = prctile(lens,1);
    t1 = 0;
    lensFlag1 = logical((lens<t99).*(lens>=t1));
    
    indexFlagR = indexFlagN;
    indexFlagR(indexFlagN) = indexFlagR(indexFlagN).*lensFlag1;
    sceneFlowN(~indexFlagR,:) = 0;
    
%     indexFlagMN = indexFlagFromMask(Points+sceneFlowN,PL,maskN);
    % scene flow fitting
    if pose_flag
        constraint_map = load([constraint_map_folder '\' constraint_map_names{i+1}]).constraint_map;
    else
        constraint_map = pointMap; % for the ipcai method
    end
    [sceneFlowN] = model_DS_cls(Points,indexFlagR,...
            sceneFlowN,1.07,E,DE,PL,constraint_map,maskN);
    
    % update the mesh
    meshOutput = triangulation(mesh0.ConnectivityList,...
        Points(:,1)+sceneFlowN(:,1),Points(:,2)+sceneFlowN(:,2),Points(:,3)+sceneFlowN(:,3));
    % stlwrite(meshOutput,[output_mesh_folder '\' erase(point3d_map_names{i+1},'mat') 'stl']);

    image = imread([image_folder '/' image_names{i+1}]);
    vertices = meshOutput.Points;
    faces = meshOutput.ConnectivityList;
    for j = 1 : size(vertices,1)
        pixel = PL*[vertices(j,:)';1];
        pixel = pixel/pixel(3);
        r = round(pixel(2))+1;
        c = round(pixel(1))+1;
        if r < 1 || r > size(image,1) || c < 1 || c > size(image,2)
            continue;
        end
        if maskN(r,c)
            continue;
        end
        vertice_colors(j,:) = squeeze(double(image(r,c,:)))/255;
    end
    mesh_color = surfaceMesh(vertices,faces,VertexColors=vertice_colors);
    writeSurfaceMesh(mesh_color,[output_mesh_folder '\' erase(point3d_map_names{i+1},'mat') 'ply']);
end