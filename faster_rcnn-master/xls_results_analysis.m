%%
%该代码根据已生成的xml，制作VOC2007数据集中的trainval.txt;train.txt;test.txt和val.txt
%trainval占总数据集的50%，test占总数据集的50%；train占trainval的50%，val占trainval的50%；
%上面所占百分比可根据自己的数据集修改，如果数据集比较少，test和val可少一些
%%
%注意修改下面四个值
xmlfilepath='E:\20170104\Annotations\';
txtsavepath='E:\20170104\ImageSets\Main\';
trainval_percent=0.5;%trainval占整个数据集的百分比，剩下部分就是test所占百分比
train_percent=0.5;%train占trainval的百分比，剩下部分就是val所占百分比

class={'apple' 
    'banana' 
    'bread' 
    'bun'
    'doughnut' 
    'egg' 
    'fired_dough_twist'%'fdt' 
    'grape' 
    'lemon' 
    'litchi'
    'mango'
%     'mix'
    'mooncake'
    'orange'
    'peach'
    'pear'
    'plum'
    'qiwi'
    'sachima'
    'tomato'
    };
sum=0;
volumes=[];
err=[];
counter=1;
for j=1:length(class)
    cls_name=class{j};
    tempxmlfilepath=strcat(xmlfilepath,cls_name);
    tempxmlfilepath=strcat(tempxmlfilepath,'*');
    xmlfile=dir(tempxmlfilepath);
    numOfxml=length(xmlfile);%减去.和.. 总的数据集大小，不需要－２
    sum=sum+numOfxml;
    cls_num=xmlfile(round(numOfxml/2)).name(length(cls_name)+1:length(cls_name)+3);%留编号，不区分S T
    start=round(numOfxml/2)+1;
    while ~isempty(strfind(xmlfile(start).name,cls_num))&&start>0
        start=start-1;
    end

    if start==0
        start=round(numOfxml/2)-1;
        while ~isempty(strfind(xmlfile(start).name,cls_num))&&start<numOfxml
            start=start+1;
        end
       if start==numOfxml
           start=round(numOfxml/2);
       else
           start=start-1;
       end
%     else
        %start=start+1;
    end
%     start=numOfxml;
%     fprintf('%s-sum: %d     -train %d;test %d;name:%s;\n',class{j},numOfxml,start,numOfxml-start,xmlfile(start+1).name);
    [~,~,xlsdata]  = xlsread('result.xls',class{j});
    len=size(xlsdata,1);
    
%     for k=1:len
%         if ~isempty(strfind(xmlfile(start+1).name,xlsdata{k,1}))%由于有可能部分图像没有进行检测，所以k不一定等于start+1
% %             fprintf('start: %d ;name:%s;%s\n',k,xmlfile(start+1).name,xlsdata{k,1});
%             volumes(j).class=cls_name;
%             volumes(j).data=xlsdata(1:(k-1),:);
%             
%             available=0;
%             sum=0;
%             estimate_sum=0;
%             for l=1:size(volumes(j).data,1)
%                 if volumes(j).data{l,6}==0
%                     continue;
%                 end
%                 available=available+1;
%                 sum=sum+volumes(j).data{l,3};
%                 estimate_sum=estimate_sum+volumes(j).data{l,6};
%             end
%             if available
%                 sum=sum/available;
%                 estimate_sum=estimate_sum/available;
%                 error=(estimate_sum-sum)/sum*100.0;
%                 fprintf('origin: %s & %d & %d & %d & %3.2f & %3.2f & %3.2f \\\\ \n',volumes(j).class,start,numOfxml-start, available, sum, estimate_sum,error);
%             end
%             break;
%         end
%     end
%     volume=[];
    
    for k=1:len
        if ~isempty(strfind(xmlfile(start+1).name,xlsdata{k,1}))%由于有可能部分图像没有进行检测，所以k不一定等于start+1
%             fprintf('start: %d ;name:%s;%s\n',k,xmlfile(start+1).name,xlsdata{k,1});
            volumes(j).class=cls_name;
            volumes(j).data=xlsdata(k:len,:);
            
            available=0;
            sum=0;
            estimate_sum=0;
            for l=1:size(volumes(j).data,1)
                if volumes(j).data{l,6}==0
                    continue;
                end
                err(counter)=volumes(j).data{l,6};counter=counter+1;
                available=available+1;
%                 sum=sum+volumes(j).data{l,2};
                sum=sum+volumes(j).data{l,3};
                estimate_sum=estimate_sum+volumes(j).data{l,6};
            end
            if available
                sum=sum/available;
                estimate_sum=estimate_sum/available;
                error=(estimate_sum-sum)/sum*100.0;
                fprintf('%s & %d & %d & %d & %3.2f & %3.2f & %3.2f \\\\ \n',volumes(j).class,start,numOfxml-start, available*2, sum, estimate_sum,error);
                err((counter-available):(counter-1))=err((counter-available):(counter-1))./sum-1;
            end
            break;
        end
    end
end
std2(err)
% save volumes volumes

% for i=1:length(class)
%     available=0;
%     sum=0;
%     estimate_sum=0;
%     for j=1:size(volumes(i).data,1)
%         if volumes(i).data{j,6}==0
%             continue;
%         end
%         available=available+1;
%         sum=sum+volumes(i).data{j,2};
%         estimate_sum=estimate_sum+volumes(i).data{j,6};
%     end
%     if available
%         error=(estimate_sum-sum)/sum;
%         fprintf('%s & %f\n',volumes(i).class,error);
%     end
% end

%采用随机排序
% trainval=sort(randperm(numOfxml,floor(numOfxml*trainval_percent)));
% test=sort(setdiff(1:numOfxml,trainval));
% 
% 
% trainvalsize=length(trainval);%trainval的大小
% train=sort(trainval(randperm(trainvalsize,floor(trainvalsize*train_percent))));
% val=sort(setdiff(trainval,train));
% 
% 
% ftrainval=fopen([txtsavepath 'trainval.txt'],'a');%zai yuan wen jian zhi hou xie ru xin xi
% ftest=fopen([txtsavepath 'test.txt'],'a');
% ftrain=fopen([txtsavepath 'train.txt'],'a');
% fval=fopen([txtsavepath 'val.txt'],'a');
% 
% 
% for i=1:numOfxml
%     if ismember(i,trainval)
%         fprintf(ftrainval,'%s\r\n',xmlfile(i+2).name(1:end-4));
%         if ismember(i,train)
%           fprintf(ftrain,'%s\r\n',xmlfile(i+2).name(1:end-4));
%         else
%           fprintf(fval,'%s\r\n',xmlfile(i+2).name(1:end-4));
%         end
%     else
%         fprintf(ftest,'%s\r\n',xmlfile(i+2).name(1:end-4));
%     end
% end
% fclose(ftrainval);
% fclose(ftrain);
% fclose(fval);
% fclose(ftest);
% fclose('all');
