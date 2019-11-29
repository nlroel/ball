I = imread('ball.jpg');
I = undistortImage(I,cameraParams);
% figure
% subplot(1,2,1),imshow(I);
% subpIlot(1,2,2),imshow(J);
I = I(:,:,1);
BW = roipoly(I);
I(BW==0)=0;
imshow(I)
BW1 = edge(I,'sobel');    %自动选择阈值用Sobel算子进行边缘检测（二值化）
 
figure(1)
subplot(121)
imshow(BW1); title('边缘检测');
se = strel('square',2);
BW=imdilate(BW1,se);%图像A1被结构元素B膨胀
 
hough_circle=zeros(m,n,3);
[Limage, num] = bwlabel(BW,8);   %num 连通区域个数
for N=1:num
    
    %[rows,cols] = find(BW);  % 找出二值图中的所有非零元素，并将这些元素的线性索引值返回到[rows,cols]  即找出边缘
      [rows,cols] = find(Limage==N);  % 找出二值图中的所有非零元素，并将这些元素的线性索引值返回到[rows,cols]  即找出边缘
      pointL=length(rows);      %非零元素个数,椭圆的周长
 
        max_distan=zeros(m,n);
        distant=zeros(1,pointL);
        for i=1:m  
            for j=1:n
                for k=1:pointL
                    distant(k)=sqrt((i-rows(k))^2+(j-cols(k))^2); %计算所有点 到椭圆边界的点的距离
                end
            max_distan(i,j)=max(distant);  %（i，j）点到椭圆边界的最大距离
            end
        end
        min_distan=min(min(max_distan));   %图像中所有的点到椭圆边界最大距离 的最小值，这个最小值对应的坐标位置 就是椭圆的中心。
 
 
        [center_yy,center_xx] = find(min_distan==max_distan);  %检索出椭圆中心的位置，
        center_y=(min(center_yy)+max(center_yy))/2;            %由于计算误差，椭圆中心可能是一簇点，所以选择中心点
        center_x=(min(center_xx)+max(center_xx))/2;            %center_x，center_y为椭圆的中心
        a=min_distan;                                          %a为椭圆的长轴
    %%  下面进行Hough变换  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hough_space = zeros(round(a+1),180);     %Hough空间
        for k=1:pointL
            for w=1:180      %theta
                G=w*pi/180; %角度转换为弧度
                XX=((cols(k)-center_x)*cos(G)+(rows(k)-center_y)*sin(G))^2/(a^2);
                YY=(-(cols(k)-center_x)*sin(G)+(rows(k)-center_y)*cos(G))^2;
                B=round(sqrt(abs(YY/(1-XX)))+1);
                if(B>0&&B<=a)   %  计算时，B的值可能很大，这里进行异常处理
                     hough_space(B,w)=hough_space(B,w)+1;
                end
            end
        end
 
     %%  搜索超过阈值的聚集点
        max_para = max(max(max(hough_space)));  % 找出累积最大值
 
        [bb,ww] = find(hough_space>=max_para);  %找出累积最大值在hough_space位置坐标（坐标值就是b和 theta）
        if(max_para<=pointL*0.33*0.25)     % 如果累积最大值 不足一定的阈值  则判断不存在椭圆
           disp('No ellipse'); 
           return ;
        end
        b=max(bb);                   %  b为椭圆的短轴
        W=min(ww);                          % %theta
        theta=W*pi/180;
 
 
      %% 标记椭圆
       
      for k=1:pointL
                XXX=((cols(k)-center_x)*cos(theta)+(rows(k)-center_y)*sin(theta))^2/(a^2);
                YYY=(-(cols(k)-center_x)*sin(theta)+(rows(k)-center_y)*cos(theta))^2/(b^2);
                if((XXX+YYY)<=1)   %实心椭圆
                 %if((XXX+YYY)<=1.1&&(XXX+YYY)>=0.99)  % 椭圆轮廓
                    hough_circle(rows(k),cols(k),1) = 255;
                    
                end
      end
     
end
   subplot(122)
   imshow(hough_circle);title('检测结果');title('检测结果');

