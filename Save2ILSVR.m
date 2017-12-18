%Save gt2ILSVR2015 format
%2017.12.12

clear;
close all;

%gt_path = '/Users/weidongzhang/Documents/OpenImage2Test/file/2/annotations-human-bbox.txt';
label_list = '/Users/weidongzhang/Documents/OpenImage2Test/file/2/label_list1.txt';
map_det = '/Users/weidongzhang/Documents/OpenImage2Test/file/2/map_det.txt';

%make map from map_det.txt
map_det = fopen(map_det);
map_det = textscan(map_det, '%s%d%s');
true_map = containers.Map;
for i=1:length(map_det{1})
    true_map(map_det{1}{i}) = map_det{2}(i);
end
%make label_map.mat
label_map = fopen(label_list);
label = textscan(label_map, '%s%s');
label_id = containers.Map;
for i=1:length(label{1})
    human_synsets(i).ILSVRC2015_DET_ID = i;
    human_synsets(i).WNID = label{1}{i};
    human_synsets(i).name = label{2}{i};
    human_synsets(i).description = " ";
    label_id(label{1}{i}) = i;
end
save('meta_det.mat', 'human_synsets');

%five variables to write
%gt_img_ids 1 to 204621
load('anno_temp.mat')
anno = annoonlyopen;
gt_img_ids={};
Map_img = containers.Map;%图片的ID
for i=1:length(anno)
    %disp(anno{i,1});
    Map_img(char(anno{i,1})) = 1;
end
num_img = length(Map_img.keys);
img_key = Map_img.keys;
img_nums = containers.Map;%每张图片的数量
for i=1:length(anno)
    img_nums(char(anno{i,1})) = 0;
end
for i=1:length(anno)
    img_nums(char(anno{i,1})) = img_nums(char(anno{i,1})) + 1;
end
for i=1:length(Map_img.keys)
    Map_img(char(img_key{i})) = i;
    gt_img_ids{i} = i;
end
gt_img_ids = reshape(gt_img_ids, [length(gt_img_ids), 1]);

%gt_obj_labels and gt_obj_bboxes
gt_obj_labels = {};
gt_obj_bboxes = {};
for i=1:length(img_key)
    gt_obj_labels{Map_img(img_key{i})} = zeros(img_nums(img_key{i}), 1);
    gt_obj_bboxes{Map_img(img_key{i})} = zeros(img_nums(img_key{i}), 4);
    gt_obj_thr{Map_img(img_key{i})} = zeros(img_nums(img_key{i}), 1);
end
for i=1:length(anno)
    img_id = Map_img(char(anno{i,1}));
    gt_obj_labels{img_id}(img_nums(char(anno{i,1})),1) = label_id(char(anno{i,3}));
    gt_obj_bboxes{img_id}(img_nums(char(anno{i,1})),1) = char(anno{i,5});%x_min;
    gt_obj_bboxes{img_id}(img_nums(char(anno{i,1})),2) = char(anno{i,6});%y_min;
    gt_obj_bboxes{img_id}(img_nums(char(anno{i,1})),3) = char(anno{i,7});%x_max;
    gt_obj_bboxes{img_id}(img_nums(char(anno{i,1})),4) = char(anno{i,8});%y_max;
    gt_obj_thr{img_id}(img_nums(char(anno{i,1})),1) = 0.5;
    img_nums(char(anno{i,1})) = img_nums(char(anno{i,1})) - 1;%img_nums go zero finally
end

%num_pos_per_class
num_pos_per_class = {};
for i=1:length(anno)
    num_pos_per_class{label_id(char(anno{i,3}))} = 0;
end
for i=1:length(anno)
    num_pos_per_class{label_id(char(anno{i,3}))} = num_pos_per_class{label_id(char(anno{i,3}))}+1;
end