%% p nelson 10/08  unsharp.m
% what we will show: 
% At high illumination, truncation to 1-bit depth destroys a lot of detail (fig 2),
% but not if we first apply unsharp mask (fig 3, fig 5).
% At low illumination (fig 6), truncation to 1-bit depth still destroys detail (fig 7), but
% it's even worse if preceded by the unsharp mask (fig 9).
% We can gain back some detail by using an unsharp mask with wider surround.

% parameters
clear all; 
illum=30; %mean number of photons/pixel in most brightly illuminated pixels
%% import image
close all
A=imread('bwEmily.tif');
%% render original
figure;
% we need full 8-bit depth when we render:
co=[0:(1/256):1]; colormap([co;co;co]');
image(A); axis off tight; title('original');
%% reduce to 1-bit depth
figure;
med=median(A(:))
B1=(A>30)*255;
colormap([co;co;co]');image(B1); axis off tight; title('1-bit depth');
%% make a set of Gaussian masks
gaussMask = zeros(7,7);
for i = 1:1:7
    for j = 1:1:7
        gaussMask(i,j) = exp(-((i-4)^2 + (j-4)^2)/5);
    end
end
gaussMask = gaussMask/sum(gaussMask(:));
meanx=0;meany=0;ssq=0;
for i=1:7,for j=1:7,
        ssq=ssq+(i^2+j^2)*gaussMask(i,j);
        meany=meany+(j*gaussMask(i,j));meanx=meanx+(i*gaussMask(i,j));
    end;end
varGauss=ssq-meanx^2-meany^2
[meanx meany]
%
gaussMaskB = zeros(7,7);
for i = 1:1:7
    for j = 1:1:7
        gaussMaskB(i,j) = exp(-((i-4)^2 + (j-4)^2)/.5);
    end
end
gaussMaskB = gaussMaskB/sum(gaussMaskB(:));
meanx=0;meany=0;ssq=0;
for i=1:7,for j=1:7,
        ssq=ssq+(i^2+j^2)*gaussMaskB(i,j);
        meany=meany+(j*gaussMaskB(i,j));meanx=meanx+(i*gaussMaskB(i,j));
    end;end
varGauss=ssq-meanx^2-meany^2
[meanx meany]

%% unsharp mask is the difference of gaussians
unsharpMask=gaussMaskB-(gaussMask); 
sum(unsharpMask(:))
figure;
surf(unsharpMask); title('unsharp mask');
unsharpA = conv2(unsharpMask, A);
figure;
%hist(unsharpA(:));
colormap([co;co;co]');
imagesc(unsharpA); axis off tight; title('unsharp mask, 8-bit');
figure;
B2=(unsharpA>0)*255;
colormap([co;co;co]');
image(B2); axis off tight; title('unsharp mask, 1-bit depth');

%% introduce Poisson noise
[ht wd]=size(A)
B3=zeros(ht,wd); %reserve space
trunc=wd;
multiBins=multiPoissonSetup(illum);
for i=1:ht, for j=1:trunc,
        [n,k]=histc(rand,multiBins(1+A(i,j),:));
        B3(i,j)=k-1; end; end
figure
maxB=max(max(double(B3(:,(1:trunc)))))
co=[0:(1./(maxB)):.999];
colormap([co;co;co]')
image(B3); axis off tight; title('noisy');
figure
med=median(B3(:));
Btmp=(A>30)*255;
colormap([co;co;co]');image(Btmp); axis off tight; title('noisy, 1-bit depth');
%% try unsharp now
unsharpB3 = conv2(unsharpMask, B3);
figure;
hist(unsharpB3(:)); title('hist of unsharp applied to noisy');
figure;
B4=(unsharpB3>0)*255;
colormap([co;co;co]');
image(B4); axis off tight; title('unsharp, noisy, 1-bit depth');
%% try a broader unsharp surround
gaussMask = zeros(31,31);
for i = 1:1:31
    for j = 1:1:31
        gaussMask(i,j) = exp(-((i-16)^2 + (j-16)^2)/20);
    end
end
gaussMask = gaussMask/sum(gaussMask(:));
%
gaussMaskB = zeros(31,31);
for i = 1:1:31
    for j = 1:1:31
        gaussMaskB(i,j) = exp(-((i-16)^2 + (j-16)^2)/1);
    end
end
gaussMaskB = gaussMaskB/sum(gaussMaskB(:));
unsharpMaskWide=gaussMaskB-(gaussMask); 
unsharpB5 = conv2(unsharpMaskWide, B3);
figure;
B6=(unsharpB5>0)*255;
colormap([co;co;co]');
image(B6); axis off tight;title('wide-surround unsharp, noisy, 1-bit depth')

