% this function generate connected components for mesh

% k_vn := the number of cluster
% ROI_vn := cluster index matrix, row = length(TRI.Points), column = k_vn
% INDEX,NUM := 1-ring neighbor in Jagged array

% cc_list_whole := the output connected components list
    % cc_list_whole{i} = cc_list
    % cc_list{j} = an array of point index

%%
function [cc_list_whole] = connectedComponentsForMesh_1Ring(k_vn,ROI_vn,INDEX,NUM)
cc_list_whole = cell(k_vn,1);
for ROI_index = 1 : k_vn
    candidates = find(ROI_vn(:,ROI_index) == 1);
    cc_list = cell(0,0);
    
    for i = 1 : length(candidates)
        candidate = candidates(i);
        exist_flag = false;

        % traverse the connected component list to check the existence of the candidate
        for cc_index = 1 : length(cc_list)
            cc = cc_list{cc_index};
            % the candidate already exist
            if sum(cc == candidate) ~= 0
                exist_flag = true;
                break;
            end
        end
        % the candidate is new
        if ~exist_flag
            cc_list = [cc_list;cell(1,1)];
            cc_list{end} = candidate;
            
            % boundaries
            boundaries = zeros(0,0);
            
            % search the neighbors
            neighbors = INDEX(NUM(candidate)+1:NUM(candidate+1));
            neighbors(neighbors==candidate) = [];
            
            for j = 1 : length(neighbors)
                neighbor = neighbors(j);
                exist_flag2 = false;
                if sum(candidates == neighbor) ~= 0 % neighbor belongs to ROI
                    % traverse the connected component list to check the
                    % existence of the neighbor
                    for cc_index = 1 : length(cc_list)
                        cc = cc_list{cc_index};
                        % the neighbor already exist
                        if sum(cc == neighbor) ~= 0
                            exist_flag2 = true;
                            break;
                        end
                    end
                    % the neighbor is new
                    if ~exist_flag2
                        % add the neighbor into cc_list array
                        cc_list{end} = [cc_list{end};neighbor];
                        % add the neighbor into boundaries
                        boundaries = [boundaries;neighbor];
                    end
                end % neighbor belongs to ROI
            end % j = 1 : neighbors
            
            % boundary growing
            while(~isempty(boundaries))
                boundaries_temp = zeros(0,0);
                neighbors = zeros(0,0);
                % find all neighbors of the boundaries' members
                for b = 1 : length(boundaries)
                    boundary = boundaries(b);
                    neighbors_temp = INDEX(NUM(boundary)+1:NUM(boundary+1));
                    neighbors_temp(neighbors_temp==boundary) = [];
                    neighbors = [neighbors;neighbors_temp];
                end
                neighbors = unique(neighbors);
                
                for j = 1 : length(neighbors)
                    neighbor = neighbors(j);
                    exist_flag2 = false;
                    if sum(candidates == neighbor) ~= 0 % neighbor belongs to ROI
                        % traverse the connected component list to check the
                        % existence of the neighbor
                        for cc_index = 1 : length(cc_list)
                            cc = cc_list{cc_index};
                            % the neighbor already exist
                            if sum(cc == neighbor) ~= 0
                                exist_flag2 = true;
                                break;
                            end
                        end
                        % the neighbor is new
                        if ~exist_flag2
                            % add the neighbor into cc_list array
                            cc_list{end} = [cc_list{end};neighbor];
                            % add the neighbor into boundaries
                            boundaries_temp = [boundaries_temp;neighbor];
                        end
                    end
                end
                boundaries = boundaries_temp;
            end % boundary growing
            
        end % the candidate is new
        
    end % i = 1 : candidates
    
    cc_list_whole{ROI_index} = cc_list;
end
end