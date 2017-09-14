
function features = compute_image_features(img_files)

    caffe_weights = '/media/nam/James4T/ImageGeoFall16/caffe_gps/vggc10/7000only/7000only__iter_167400.caffemodel';
    caffe_model = '/media/nam/James4T/ImageGeoFall16/caffe_gps/vgg16_rank/deploy.prototxt';
    image_resize_size = 224;
    batch_size = 1;

    caffe.reset_all();
    caffe.set_mode_cpu();
    % caffe.set_mode_gpu();
    net = caffe.Net(caffe_model, caffe_weights, 'test');

    batch_data = single(zeros(image_resize_size, image_resize_size, 3, batch_size));
    net.blobs('data').reshape([image_resize_size, image_resize_size, 3, batch_size]);
    net.reshape();

    features = {};
    for i=1:length(img_files)
        img = imread(img_files{i});
        img = my_resize_img( img, image_resize_size, 1);
        batch_data(:,:,:,1) = convert_img_for_cafffe(img, image_resize_size);
        net.blobs('data').set_data(batch_data);
        net.forward_prefilled();
        f = net.blobs('pool5').get_data();
        f = squeeze(f);
        features{end+1} = f;
    end

end
