
clear

%% get image files & gps labels
image_files = {};
query_file_gps = {};
for f=dir('query')'
    if ~f.isdir
        image_files{end+1} = ['query/', f.name];
        x = imfinfo(image_files{end});
        y = strsplit(x.Comment{9});
        z = strsplit(x.Comment{10});
        query_file_gps{end+1} = [str2num(y{2}), str2num(z{2})];
    end
end

%% predict gps
query_outputs = predict_gps(image_files);

%% compute accuracy
errors = [];
for i=1:length(query_outputs)
    gps1 = query_file_gps{i};
    gps2 = query_outputs{i};
    d = gps_distance(gps1(1), gps1(2), gps2(1), gps2(2));
    errors(end+1) = d;
end
for d_error=[1, 25, 200, 750, 2500];
    correct_count = sum(errors <= d_error);
    acc = (correct_count / length(errors));
    disp(['Accuracy at ', num2str(d_error), 'km is ', num2str(acc)]);
end
































