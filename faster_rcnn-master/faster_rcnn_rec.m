function volume=faster_rcnn_rec(top,side,opts,proposal_detection_model,rpn_net,fast_rcnn_net)
% close all;
% clc;
% clear mex;
% clear is_valid_handle; % to clear init_key
% run(fullfile(fileparts(mfilename('fullpath')), 'startup'));
%% -------------------- CONFIG --------------------
% opts.caffe_version          = 'caffe_faster_rcnn';
% opts.gpu_id                 = auto_select_gpu;
% active_caffe_mex(opts.gpu_id, opts.caffe_version);
% 
% opts.per_nms_topN           = 6000;
% opts.nms_overlap_thres      = 0.7;
% opts.after_nms_topN         = 3000;
% opts.use_gpu                = true;
% 
% opts.test_scales            = 1000;
% 
% %% -------------------- INIT_MODEL --------------------
% % model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC0712_vgg_16layers'); %% VGG-16
% model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC0712_ZF'); %% ZF
% model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC2007_ZF'); %% ZF
% proposal_detection_model    = load_proposal_detection_model(model_dir);
% proposal_detection_model.conf_proposal.test_scales = opts.test_scales;
% proposal_detection_model.conf_detection.test_scales = opts.test_scales;
% if opts.use_gpu
%     proposal_detection_model.conf_proposal.image_means = gpuArray(proposal_detection_model.conf_proposal.image_means);
%     proposal_detection_model.conf_detection.image_means = gpuArray(proposal_detection_model.conf_detection.image_means);
% end
% 
% % caffe.init_log(fullfile(pwd, 'caffe_log'));
% % proposal net
% rpn_net = caffe.Net(proposal_detection_model.proposal_net_def, 'test');
% rpn_net.copy_from(proposal_detection_model.proposal_net);
% % fast rcnn net
% fast_rcnn_net = caffe.Net(proposal_detection_model.detection_net_def, 'test');
% fast_rcnn_net.copy_from(proposal_detection_model.detection_net);
% 
% % set gpu/cpu
% if opts.use_gpu
%     caffe.set_mode_gpu();
% else
%     caffe.set_mode_cpu();
% end       

running_time = [];
im_names={top,side};
for j = 1:length(im_names)
    
    im = imread(im_names{j});
    
    if opts.use_gpu
        im = gpuArray(im);
    end
    
    % test proposal
    th = tic();
    [boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
    t_proposal = toc(th);
    th = tic();
    aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
    t_nms = toc(th);
    
    % test detection
    th = tic();
    if proposal_detection_model.is_share_feature
        [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
            aboxes(:, 1:4), opts.after_nms_topN);
    else
        [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            aboxes(:, 1:4), opts.after_nms_topN);
    end
    t_detection = toc(th);
    
    fprintf('%s (%dx%d): time %.3fs (resize+conv+proposal: %.3fs, nms+regionwise: %.3fs)\n', im_names{j}, ...
        size(im, 2), size(im, 1), t_proposal + t_nms + t_detection, t_proposal, t_nms+t_detection);
    running_time(end+1) = t_proposal + t_nms + t_detection;
    
    % visualize,节省时间，不显示了
    classes = proposal_detection_model.classes;
    boxes_cell = cell(length(classes), 1);
    thres = 0.8;%0.5->0.8
    for i = 1:length(boxes_cell)
        boxes_cell{i} = [boxes(:, (1+(i-1)*4):(i*4)), scores(:, i)];
        boxes_cell{i} = boxes_cell{i}(nms(boxes_cell{i}, 0.3), :);%非极大化抑制，剔除重复的boxes_cell   
        I = boxes_cell{i}(:, 5) >= thres;
        boxes_cell{i} = boxes_cell{i}(I, :);
    end
    food{j}.boxes_cell=boxes_cell;
    
%     figure(j);
%     showboxes(im, boxes_cell, classes, 'voc');
%     pause(0.1);
    
%     fix_width = 800;
%     if isa(im, 'gpuArray')
%         im = gather(im);
%     end
%     imsz = size(im);
%     scale = fix_width / imsz(2);

%     for i=1:length(boxes_cell)
%         if(~isempty(boxes_cell{i}))
%             a=double(boxes_cell{i}(1:4));%需要double类型的输入,a=[y_start x_start y_end x_end]
%             img=grabcut_mex(top,[a(1),a(2),a(3)-a(1),a(4)-a(2)]);%[x,y,length,width]
%             imshow(img,[]);
%             pause(0.1);
%         end
%     end

end
fprintf('mean time: %.3fs\n', mean(running_time));

top_pixel=0;
side_pixel=0;
load food_info
volume=0;
% fp=fopen('result.txt','w');
if ~isempty(food{1}.boxes_cell{5})
    [~,pos]=max(food{1}.boxes_cell{5}(:,5));%选取可信度最高的硬币
    top_pixel=double(2.5 / ((food{1}.boxes_cell{5}(pos,4)+food{1}.boxes_cell{5}(pos,3)-food{1}.boxes_cell{5}(pos,2)-food{1}.boxes_cell{5}(pos,1))/2)); % fushitu bilixishu   
    if ~isempty(food{2}.boxes_cell{5})
        [~,pos]=max(food{2}.boxes_cell{5}(:,5));%选取可信度最高的硬币
        side_pixel=double(2.5/ ((food{2}.boxes_cell{5}(pos,4)+food{2}.boxes_cell{5}(pos,3)-food{2}.boxes_cell{5}(pos,2)-food{2}.boxes_cell{5}(pos,1))/2)); % ceshitu bilixishu
        for i=1:size(food{1}.boxes_cell,1)
            if i==5||isempty(food{1}.boxes_cell{i})||isempty(food{2}.boxes_cell{i})
                continue;
            end
            [~,pos]=max(food{1}.boxes_cell{i}(:,5));%选取可信度最高的硬币
            top_rect=double(food{1}.boxes_cell{i}(pos,1:4));
%             for j=1:size(food{2}.boxes_cell{i},1)
                [~,pos]=max(food{2}.boxes_cell{i}(:,5));%选取可信度最高的硬币
                side_rect=double(food{2}.boxes_cell{i}(pos,1:4));
                volume=grabcut_mex(top,[top_rect(1),top_rect(2),top_rect(3)-top_rect(1),top_rect(4)-top_rect(2)], ...
                                side,[side_rect(1),side_rect(2),side_rect(3)-side_rect(1),side_rect(4)-side_rect(2)], ...
                                food_info{i+1,2},top_pixel,side_pixel);
                calorie=volume*food_info{i+1,3};
%                 fprintf(fp,'%s %f %d %d %d %d\r\n',food_info{i+1,1},calorie,uint16(top_rect));
%                             volume=grabcut_mex(top,[top_rect(1),top_rect(2),top_rect(3)-top_rect(1),top_rect(4)-top_rect(2)], ...
%                 side,[side_rect(1),side_rect(2),side_rect(3)-side_rect(1),side_rect(4)-side_rect(2)], ...
%                 'column',top_pixel,side_pixel)
%                             volume=grabcut_mex(top,[top_rect(1),top_rect(2),top_rect(3)-top_rect(1),top_rect(4)-top_rect(2)], ...
%                 side,[side_rect(1),side_rect(2),side_rect(3)-side_rect(1),side_rect(4)-side_rect(2)], ...
%                 'torus',top_pixel,side_pixel)
%                             volume=grabcut_mex(top,[top_rect(1),top_rect(2),top_rect(3)-top_rect(1),top_rect(4)-top_rect(2)], ...
%                 side,[side_rect(1),side_rect(2),side_rect(3)-side_rect(1),side_rect(4)-side_rect(2)], ...
%                 'ellipsoid',top_pixel,side_pixel)
%             end
        end
    end
end
% fclose(fp);
% caffe.reset_all(); 
% clear mex;

end

function proposal_detection_model = load_proposal_detection_model(model_dir)
    ld                          = load(fullfile(model_dir, 'model'));
    proposal_detection_model    = ld.proposal_detection_model;
    clear ld;
    
    proposal_detection_model.proposal_net_def ...
                                = fullfile(model_dir, proposal_detection_model.proposal_net_def);
    proposal_detection_model.proposal_net ...
                                = fullfile(model_dir, proposal_detection_model.proposal_net);
    proposal_detection_model.detection_net_def ...
                                = fullfile(model_dir, proposal_detection_model.detection_net_def);
    proposal_detection_model.detection_net ...
                                = fullfile(model_dir, proposal_detection_model.detection_net);
    
end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), per_nms_topN), :);
    end
    % do nms
    if nms_overlap_thres > 0 && nms_overlap_thres < 1
        aboxes = aboxes(nms(aboxes, nms_overlap_thres, use_gpu), :);       
    end
    if after_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), after_nms_topN), :);
    end
end
