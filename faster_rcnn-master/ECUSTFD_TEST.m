% [data,text]  = xlsread('E:\食物+体积+质量\density_table.xls','banana');

    path='E:\resized_ECUSTFD\';
    class={'apple' 
        'banana' 
        'bread' 
        'bun'
        'doughnut' 
        'egg' 
        'fired_dough_twist' 
        'grape' 
        'lemon' 
        'litchi'
        'mango'
        %'mix'
        'mooncake'
        'orange'
        'peach'
        'pear'
        'plum'
        'qiwi'
        'sachima'
        'tomato'
        };
    save_xls='result.xls';%用fopen创建的xls无法正确读取
%     if(~exist(save_xls))
%         file_id=fopen(save_xls,'a+'); 
%         fclose(file_id);
%     end
    clc;
    clear mex;
    clear is_valid_handle; % to clear init_key
    run(fullfile(fileparts(mfilename('fullpath')), 'startup'));
    %% -------------------- CONFIG --------------------
    opts.caffe_version          = 'caffe_faster_rcnn';
    opts.gpu_id                 = auto_select_gpu;
    active_caffe_mex(opts.gpu_id, opts.caffe_version);

    opts.per_nms_topN           = 6000;
    opts.nms_overlap_thres      = 0.7;
    opts.after_nms_topN         = 3000;
    opts.use_gpu                = true;

    opts.test_scales            = 1000;

    %% -------------------- INIT_MODEL --------------------
    model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC2007_ZF'); %% ZF
    proposal_detection_model    = load_proposal_detection_model(model_dir);
    proposal_detection_model.conf_proposal.test_scales = opts.test_scales;
    proposal_detection_model.conf_detection.test_scales = opts.test_scales;
    if opts.use_gpu
        proposal_detection_model.conf_proposal.image_means = gpuArray(proposal_detection_model.conf_proposal.image_means);
        proposal_detection_model.conf_detection.image_means = gpuArray(proposal_detection_model.conf_detection.image_means);
    end

    % caffe.init_log(fullfile(pwd, 'caffe_log'));
    % proposal net
    rpn_net = caffe.Net(proposal_detection_model.proposal_net_def, 'test');
    rpn_net.copy_from(proposal_detection_model.proposal_net);
    % fast rcnn net
    fast_rcnn_net = caffe.Net(proposal_detection_model.detection_net_def, 'test');
    fast_rcnn_net.copy_from(proposal_detection_model.detection_net);

    % set gpu/cpu
    if opts.use_gpu
        caffe.set_mode_gpu();
    else
        caffe.set_mode_cpu();
    end   



    for i=1:length(class)
        temp=strcat(path,class{i});
        temp=strcat(temp,'\');
        d=dir(temp);
        [~,~,xlsdata]  = xlsread('density.xls',class{i});
        xls_start=1;
        xlsdata_start=1;
        for j=2:size(xlsdata,1)
            if isempty(xlsdata{j,1})
                continue;
            end
            tmp=strcat(temp,xlsdata{j,1});
            str=strcat(tmp,'*T(*.jp*');
            temp_d=dir(str);
            for k=1:length(temp_d)
                top_filename=strcat(temp,temp_d(k).name);
                side_filename=strrep(top_filename,'T(','S(');
                if ~exist(side_filename,'file')
                    continue;
                end
                %fprintf('%s;%s\n',top_filename,side_filename);
                volume=faster_rcnn_rec(top_filename,side_filename,opts,proposal_detection_model,rpn_net,fast_rcnn_net);
                if isempty(volume)
                    volume=0;
                end
%                 xlswrite(save_xls,[xlsdata(j,:) class{i} temp_d(k).name volume],class{i},strcat('A',num2str(xls_start)));       %xlswrite(filename,A,sheet,xlRange)  
                xlswrite(save_xls,[xlsdata(j,:) temp_d(k).name volume],class{i},strcat('A',num2str(xls_start)));       %xlswrite(filename,A,sheet,xlRange)   
                xls_start=xls_start+1;
            end
        end
%         for j=1:length(d)
%             if(length(d(j).name)<3)||~exist(strcat(temp,d(j).name),'dir')
%                 continue;
%             end
%             %[filename,volume,quality]=xlsdata(j+1,:);
%             tmp=strcat(temp,d(j).name);%apple
%             tmp=strcat(tmp,'\');
%             str=strcat(tmp,'*T(*.jp*');
%             temp_d=dir(str);
%             for k=1:length(temp_d)
%                 top_filename=strcat(tmp,temp_d(k).name);
%                 side_filename=strrep(top_filename,'T(','S(');
%                 if ~exist(side_filename,'file')
%                     continue;
%                 end
%                 fprintf('%s;%s\n',top_filename,side_filename);
%                 volume=faster_rcnn_rec(top_filename,side_filename,opts,proposal_detection_model,rpn_net,fast_rcnn_net);
%                 if isempty(volume)
%                     volume=0;
%                 end
%                 if isempty(strfind(top_filename,xlsdata(xlsdata_start+1,1)))
%                     xlsdata_start=xlsdata_data_start+1;
%                 end
%                 xlswrite(save_xls,[xlsdata(xlsdata_start+1,:) class{i} k volume],class{i},strcat('A',num2str(xls_start)));                
%                 xls_start=xls_start+1;
%             end
%         end    
    end
caffe.reset_all(); 
clear mex;




