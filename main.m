I = imread('ball.jpg');
I = undistortImage(I,cameraParams);
% figure
% subplot(1,2,1),imshow(I);
% subpIlot(1,2,2),imshow(J);
I = I(:,:,1);
BW = roipoly(I);
I(BW==0)=0;
imshow(I)


