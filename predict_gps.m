
function gps = predict_gps(image_files)

%% params
reference_feature_path = './reference/';
use_flann = 1;
nearest_num = 1000;
nn_batch_size = 300000; % we will not load all the reference data at the same time
flann_search_num = 10000;
do_reuse_flann_index = 1;
do_l2_norm = 1;

%% compute image features
disp('Extract image features...')
query_file_ids = image_files;
query_file_features = compute_image_features(query_file_ids);

if do_l2_norm
    for j=1:length(query_file_features)
        query_file_features{j} = query_file_features{j} / norm(query_file_features{j});
    end
end

% place holder
query_nns = {};
query_nns_dist = {};
query_nns_gps = {};
query_nns_feature = {};
for i=1:length(query_file_ids)
    query_nns{i} = {};
    query_nns_dist{i} = [];
    query_nns_gps{i} = [];
    query_nns_feature{i} = [];
end

%% reference feature files
files = dir(reference_feature_path)';
for i=length(files):-1:1
    f = files(i);
    if f.isdir | length(findstr(f.name, '.mat')) == 0
        files(i) = [];
    end
end

%% load reference & search

reference_file_ids = {};
reference_file_features = {};
reference_file_gps = {};
reference_data_size = 0;

for f=files
    disp(['Load reference features from ', f.name])
    load([reference_feature_path, '/', f.name]);
    
    if do_l2_norm
        for j=1:length(file_ids)
            file_features{j} = file_features{j} / norm(file_features{j});
        end
    end
    
    reference_file_ids = [reference_file_ids, file_ids];
    reference_file_features = [reference_file_features, file_features];
    reference_file_gps = [reference_file_gps, file_gps];

    
    if length(reference_file_ids) >= nn_batch_size || strcmp(f.name, files(end).name)
        
        if use_flann
            
            % flann: index data
            params = struct;
            params.algorithm = 'kdtree';
            params.trees = 32;
            params.checks = 10;
            params.core = 4;
            tic;
            d = [reference_file_features{:}];
            flann_index_path = [reference_feature_path, '/', num2str(sum(d(:))) , '.flann_index'];
            if ~exist(flann_index_path) | ~do_reuse_flann_index
                disp('build flann index');
                [index, params, speedup] = flann_build_index(d, params); 
                flann_save_index(index, flann_index_path);
            else
                disp('load flann index');
                index = flann_load_index(flann_index_path, d);
            end
            toc;
            
            % flann: search
            tic;
            disp('flann search')
            q = [query_file_features{:}];
            [result, dists] = flann_search(index, q, flann_search_num, params);
            flann_free_index(index);
            toc;
            
            % save result
            for i=1:length(query_file_ids)
                query_nns{i} = [query_nns{i}, reference_file_ids{result(1:nearest_num,i)}];
                query_nns_dist{i} = [query_nns_dist{i}; dists(1:nearest_num,i)];
                query_nns_gps{i} = [query_nns_gps{i}; cell2mat(reference_file_gps(result(1:nearest_num,i))')];
                query_nns_feature{i} = [query_nns_feature{i}; cell2mat(reference_file_features(result(1:nearest_num,i)))'];
                
                % keep top nearest_num
                [a, b] = sort(query_nns_dist{i});
                query_nns{i} = query_nns{i}(b(1:nearest_num));
                query_nns_dist{i} = query_nns_dist{i}(b(1:nearest_num));
                query_nns_gps{i} = query_nns_gps{i}(b(1:nearest_num),:);
                query_nns_feature{i} = query_nns_feature{i}(b(1:nearest_num),:);
            end
            
        end
        
        % reset
        reference_data_size = reference_data_size + length(reference_file_ids);
        reference_file_ids = {};
        reference_file_features = {};
        reference_file_gps = {};
        clearvars file_ids file_features file_gps a b d i q;
        pause(1);
    end
end

%% from nn to final prediction
query_outputs = {};
best_of = [];
weird_ids = [];
tic;
for i=1:length(query_file_ids)
    nns = query_nns{i};
    nns_dist = query_nns_dist{i};
    
    
    % xxx
    if 1
        %disp(i);
        best_score = 0;
        w = zeros(180, 360);
        %j0 = 0;
        for j=1:100
            lat =  ceil(query_nns_gps{i}(j,1) * 1) + 90;
            long = ceil(query_nns_gps{i}(j,2) * 1) + 180;
            try
                w(lat,long) = w(lat,long) + 1/(nns_dist(j)/1)^10;
            end
        end
        %tic;
        w = imgaussfilt(w,4);
        if 0
            subplot(1,2,1);
            imagesc(w);
            lat =  ceil(query_file_gps{i}(1) * 1) + 90;
            long = ceil(query_file_gps{i}(2) * 1) + 180;
            hold on; 
            plot(long, lat, 'xr');
            hold off;
            subplot(1,2,2); imshow(imread(query_file_ids{i}));
            pause;
        end
        %toc;
        [latx, longx] = ind2sub(size(w), find(w == max(w(:))));
        query_outputs{i} = [latx-90, longx-180]/1;
        latx = max(21, min(159, latx));
        longx = max(21, min(339, longx));
        
        if 1
        %disp(i);
        w = zeros(1800, 3600);
        best_score = 0;
        %j0 = 0;
        for j=1:100
            lat =  ceil(query_nns_gps{i}(j,1) * 10) + 900;
            long = ceil(query_nns_gps{i}(j,2) * 10) + 1800;
            try
                w(lat,long) = w(lat,long) + 1/(nns_dist(j)/1)^10;
            end
        end
        
        w2 = imgaussfilt(...
           w(latx*10-200:latx*10+200, longx*10-200:longx*10+200),40);
        w = zeros(1800, 3600);
        w(latx*10-200:latx*10+200, longx*10-200:longx*10+200) = w2;
      
        
        [lat, long] = ind2sub(size(w), find(w == max(w(:))));
        query_outputs{i} = [lat(1)-900, long(1)-1800]/10;
        end
        
        % check again with top
        d_best = 999999999;
        j_best = -1;
        for j=1:100
            gps1 = query_outputs{i};
            gps2 = query_nns_gps{i}(j,:);
            d = gps_distance(gps1(1), gps1(2), gps2(1), gps2(2));
            if d < 100,
                if d < d_best
                    d_best = d;
                    j_best = j;
                    break
                end
            end
        end
        if j_best >= 0
             query_outputs{i} = query_nns_gps{i}(j_best,:);
        end
    end
end

% return
gps = query_outputs;

end

