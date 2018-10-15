# Revisiting Im2GPS

![](https://lugiavn.github.io/gatech/revisitingim2gps_iccv2017/pipeline.png "")

Code & data for our "Revisiting IM2GPS in the Deep Learning Era" paper

PyTorch version: to be released

Prerequisites:
- Matlab
- Caffe & its Matlab interface: http://caffe.berkeleyvision.org/
- FLANN & its Matlab interface: http://www.cs.ubc.ca/research/flann/
- Have 3.5GB of free RAM

Test on new images:
- Download reference features from http://www.mediafire.com/file/7l2dqi7f7obzu57/reference_im2gps.zip and unzip the .mat files to "reference" folder
- Download caffe model from http://www.mediafire.com/file/d9hifat6qi4tu2m/7000only__iter_167400.caffemodel
- Run main.m to predict gps coordinate of an example image

Test on im2gps-test-set:
- Download the test set from http://graphics.cs.cmu.edu/projects/im2gps and unzip the images to "query" folder
- Run main_im2gps_test.m
- The numbers might not be exactly the same as reported in the paper because of FLANN randomization or image decoding.

Datasets:
- Im2GPS3k, used for testing in our paper: this is part of the original Im2GPS dataset, here's the 3000 (full resolution) images http://www.mediafire.com/file/7ht7sn78q27o9we/im2gps3ktest.zip
- Im2GPS, used for training/referencing: more than 5 million images, this is part of the original Im2GPS dataset. We are not able to provide access to the images, though you can download the reference features (above), look up the file names and infer the original sources on Flickr.
- YFCC100M, used for referencing: due to time constraint, we were only able to download ~22 million images for the experiments reported in the paper. The full dataset can be found here https://webscope.sandbox.yahoo.com/catalog.php?datatype=i&did=67
- YFCC4k, used for testing in our paper: actually 4536 images. We've lost our YFCC100M data, but still have the list of image-id here: http://www.mediafire.com/file/8v2j565997i5jed/0aaaa.r.imagedata.txt, from which you can look up the sources/URLs in the YFCC100M dataset.

Reference:
- Nam Vo, Nathan Jacobs and James Hays. "Revisiting IM2GPS in the Deep Learning Era". ICCV 2017.

















