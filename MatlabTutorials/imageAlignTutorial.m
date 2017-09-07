% imageAlignTutorial
%
% The long-term goal of this is to figure out fast ways
% to do image aligment.  This is a simple start using
% Matlab's cross correlation function, and provides
% an upper bound.
%
% Assumes that test image is a subset of full iamge, and
% differs only in xy translation.
%
% Options to think about.  GPU computation, map-seeking circuit
% algorithm, sparsifying image and using a sparse representation.
%
% 3/19/12  dhb  Wrote it.

%% Clear
clear all; close all

%% Parameters
fullImageRows = 64;
fullImageCols = 128;
testImageRows = 16;
testImageCols = 64;
testImageRowOffset = 5;
testImageColOffset = 10;

%% Generate full test image. Filtered random noise.
probOnes = 0.2;
fullImage = binornd(1,probOnes,fullImageRows,fullImageCols);
convKernalHalfSize = 5;
convKernalSigma = 6;
[X1,X2] = meshgrid((-convKernalHalfSize:convKernalHalfSize)',(-convKernalHalfSize:convKernalHalfSize)');
X = [X1(:) X2(:)];
convKernal = mvnpdf(X, [0 0], [convKernalSigma 0 ; 0 convKernalSigma]);
convKernal = convKernal/sum(convKernal(:));
convKernal = reshape(convKernal,length((-convKernalHalfSize:convKernalHalfSize)),length((-convKernalHalfSize:convKernalHalfSize)));
fullImage = conv2(fullImage,convKernal,'same');
figure; clf;
imshow(fullImage);

%% Extract reference image and test image
testImage = fullImage(testImageRowOffset:testImageRowOffset+testImageRows,...
    testImageColOffset:testImageColOffset+testImageCols);
[testRows,testCols] = size(testImage);

%% Figure out where test is, using cross-correlation
% This is right out of the documentation for normxcorr2
tic;
cc = normxcorr2(testImage,fullImage); 
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-testRows+1) (xpeak-testCols+1) ];
toc
corr_offset



