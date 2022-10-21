clear;

vid = VideoReader('vid_in2.mp4');

%% Découpage de la vidéo en images

% totalFrames = vid.NumFrames;
% NFP = ceil(sqrt(totalFrames));
% for i=1:totalFrames
%     frame = read(vid,i);
%     ImgName = strcat('frame',int2str(i),'.png');
%     imwrite(frame, ImgName);
% end

% 326 images
% On prend la première

frame1 = read(vid,1);
imgName = strcat('frame',int2str(1),'.png');
imwrite(frame1,imgName);

imgIn=imread(imgName);
imgGray=rgb2gray(imgIn);
%imgYcbcr=rgb2ycbcr(imgIn);
%imgY   = int32(imgYcbcr(:,:,1));

figure
imshow(imgGray);


%% Création du filtre gaussien


% test avec flou gaussien
% h = ones(5,5)/25;
% imgOut = imfilter(imgIn,h);
% figure 
% subplot(1,2,1), imshow(imgIn)
% title(imgName);
% subplot(1,2,2), imshow(imgOut)
% title("réduction du bruit");

% dérivées partielles de la gaussienne
sigmaG = 2.1;
delta = ceil(3*sigmaG); % arrondi au supérieur pour que la fenêtre comprenne l'intervalle [-3sig;3sig]
[X,Y] = meshgrid( -delta:delta , -delta:delta );

G_X = - X./ ((2*pi*sigmaG^4) * exp(-(X.^2 + Y.^2)/(2*sigmaG^2)));
G_Y = - Y / (2*pi*sigmaG^4) * exp(-(X.^2 + Y.^2)/(2*sigmaG^2));

% convolution
gradX = conv2(imgGray,G_X);
gradY= conv2(imgGray,G_Y);

figure, image(gradX), title("Composantes horizontales");
figure, image(gradY), title("Composantes verticales");

% covariance des gradients
% (approche de Cany : gradient I estimé par convo des dérives partielles de G sur I)
IxIx = gradX.* gradX;
IyIy = gradY.* gradY;
IxIy = gradX.*gradY;  % = IyIx

sigmaC = 3;
G = (1 / (2*pi*sigmaC^2)) * exp(-(X.^2+Y.^2)/(2*sigmaC^2));

Cxx = conv2(IxIx,G);
Cyy = conv2(IyIy,G);
Cxy = conv2(IxIy,G);  % = Cyx

% Calcul du détecteur en tout point
DetHarris1 = Cxx.*Cyy - Cxy.^2 - k.* (Cxx + Cyy).^2;
