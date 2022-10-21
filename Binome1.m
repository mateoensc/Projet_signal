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

G_X = - X/ (2*pi*sigmaG^4) .*(exp(-(X.^2 + Y.^2)/(2*sigmaG^2)));
G_Y = - Y/ (2*pi*sigmaG^4) .*(exp(-(X.^2 + Y.^2)/(2*sigmaG^2)));


% convolution
gradX = conv2(imgGray,G_X,'same'); % A VOIR DANS COURS
gradY = conv2(imgGray,G_Y,'same');

figure, imshow(gradX), title("Composantes horizontales");
figure, imshow(gradY), title("Composantes verticales");

% covariance des gradients
% (approche de Canny : gradient I estimé par convo des dérives partielles de G sur I)
IxIx = gradX.* gradX;
IyIy = gradY.* gradY;
IxIy = gradX.*gradY;  % = IyIx

sigmaC1 = 3;
GC1 = (1 / (2*pi*sigmaC1^2)) * exp(-(X.^2+Y.^2)/(2*sigmaC1^2));

Cxx1 = conv2(IxIx,GC1,'same');
Cyy1 = conv2(IyIy,GC1,'same');
Cxy1 = conv2(IxIy,GC1,'same');  % = Cyx

sigmaC2 = 5;
GC2 = (1 / (2*pi*sigmaC2^2)) * exp(-(X.^2+Y.^2)/(2*sigmaC2^2));
Cxx2 = conv2(IxIx,GC2,'same');
Cyy2 = conv2(IyIy,GC2,'same');
Cxy2 = conv2(IxIy,GC2,'same');  % = Cyx

% Calcul du détecteur en tout point
k = 0.05;
DetTrace1 = Cxx1.*Cyy1 - Cxy1.*Cxy1 - k.* ((Cxx1 + Cyy1).^2);
DetTrace2 = Cxx2.*Cyy2 - Cxy2.*Cxy2 - k.* ((Cxx2 + Cyy2).^2);

% combinaison multi-échelle
Dmulti = min(DetTrace1 .* abs(DetTrace2), abs(DetTrace1) .* DetTrace2);

figure, imshow(Dmulti), title("Détecteur de Harris");
