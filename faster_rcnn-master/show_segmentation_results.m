top=imread('top.jpg');
top_mask=imread('top_mask.jpg');
side=imread('side.jpg');
side_mask=imread('side_mask.jpg');
for i=1:size(top_mask,1)
    for j=1:size(top_mask,2)
        if top_mask(i,j)~=3
            top(i,j,:)=[0 0 0];
        end
    end
end
figure 
imshow(top)
for i=1:size(side_mask,1)
    for j=1:size(side_mask,2)
        if side_mask(i,j)~=3
            side(i,j,:)=[0 0 0];
        end
    end
end
figure
imshow(side)