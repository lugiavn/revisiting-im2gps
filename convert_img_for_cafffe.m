function img = convert_img_for_cafffe(img, s)
%CONVERT_IMG_FOR_CAFFFE Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
      s = 224;
    end
    img = single(imresize(img, [s s])) - 100.0;
    if size(img,3) == 1,
        img(:,:,2) = img(:,:,1);
        img(:,:,3) = img(:,:,1);
    end
    img = img(:, :, [3, 2, 1]); % convert from RGB to BGR
    img = permute(img, [2, 1, 3]); % permute width and height
end


