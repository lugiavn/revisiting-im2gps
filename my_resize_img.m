function r = my_resize_img( img, new_size, mode )
%MY_RESIZE_IMG Summary of this function goes here
%   img: input image
%   size: [h, w]
%   mode: 0 just resize, 1 crop resize, 2 pad resize

if mode == 0
    r = imresize(img, [new_size new_size]);
elseif mode == 1
    h = size(img, 1);
    w = size(img, 2);
    s = min(h, w);
    i1 = round((h - s)/2 + 1);
    i2 = round((w - s)/2 + 1);
    img = img(i1:(i1+s-1),i2:(i2+s-1),:);
    r = my_resize_img(img, new_size, 0);
    
elseif mode == 2
    
    h = size(img, 1);
    w = size(img, 2);
    s = max(h, w);
    r = zeros(s, s, size(img, 3));
    i1 = round((s - h)/2 + 1);
    i2 = round((s - w)/2 + 1);
    r(i1:(i1+h-1),i2:(i2+w-1),:) = img;
    r = my_resize_img(r, new_size, 0);
end

end

