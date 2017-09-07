% sRGBTransformGeneration
%
% As per suggestion of "Jacobolus" at Wikepedia, generate
% sRGB transformation matrices from the primary and white
% point luminances, to try to understand why the forward
% transformation matrices in IEC 61966-2-1:1999 and in 
% the original Stokes et al. (1996) document might differ.
%
% The Stokes et al. document is currently on the web at:
%   http://www.w3.org/Graphics/Color/sRGB
% You have to purchase the IEC 61966-2-1:1999 if you want
% to look at it, but a draft standard that is the same
% for the purposes under consideration here is currently
% on the web at 
%   http://www.colour.org/tc8-05/Docs/colorspace/61966-2-1.pdf
%
% If you want to run this code, you'll need to install the (free)
% Psychophyics Toolbox (http://psychtoolbox.org), or write your
% own xyYToXYZ and XYZToxyY routines.
%
% 8/23/10  dhb  Wrote it.

% Clear
clear; close all;

% Specify sRGB xyz chromaticities and white point.  Although
% the standard specifies the white luminance as 80 cd/m2, to
% generate the matrix you have to use 1 cd/m2.  I have not yet
% figured out whence this difference.  It is noted on the
% Wikipedia sRGB page.
M_xyz = [[0.6400 0.3300 0.0300]', [0.3000 0.6000 0.1000]', [0.1500 0.0600 0.7900]'];
W_xyz = [0.3127 0.3290 0.3583]';
W_Y = 1;

% Compute white point tristimulus (XYZ) coordinates from chromaticity and
% luminance.
W_xyY = [W_xyz(1:2) ; W_Y];
W_XYZ = xyYToXYZ(W_xyY);

% Convert primariy chromaticities (which we treat as normalized
% tristimulus values) to the primariy tristimulus values.  Constraint
% is that primaries must add up to produce the white point.
%
% The output of the following is pasted below (8/24/10) and matches
% the sRGB standard to the four places specified in the standard
%
% M_RGBToXYZ =
% 
%     0.4124    0.3576    0.1805
%     0.2126    0.7152    0.0722
%     0.0193    0.1192    0.9505
w = M_xyz\W_XYZ;
M_RGBToXYZ = M_xyz*diag(w);

% As a second check, verify that this transform produces the
% specified white point.  Yes (8/24/10).
%
% W_xyYCheck =
% 
%     0.3127
%     0.3290
%     1.0000
W_XYZCheck = M_RGBToXYZ*[1 1 1]';
W_xyYCheck = XYZToxyY(W_XYZCheck);

% Invert the matrix at the working precision of Matlab (more than
% the four places that print out).  The result to four places
% matches what is in Stokes et al., 1996.
%
% M_XYZToRGB =
% 
%     3.2410   -1.5374   -0.4986
%    -0.9692    1.8760    0.0416
%     0.0556   -0.2040    1.0570
M_XYZToRGB = inv(M_RGBToXYZ);

% Round the matrix M_RGBToXYZ to the four places that are
% actually given in the standard.  Then invert.  This
% produces the matrix that is in IEC 61966-2-1:1999 (8/24/10)
%
% M_XYZToRGB2 =
% 
%     3.2406   -1.5372   -0.4986
%    -0.9689    1.8758    0.0415
%     0.0557   -0.2040    1.0570
M_RGBToXYZ2 = round(10000*M_RGBToXYZ)/10000;
M_XYZToRGB2 = inv(M_RGBToXYZ2);

% Conclusion.  The difference between Stokes et al. (1996)
% and IEC 61966-2-1:1999 is whether you invert and then round
% (Stokes et al.) or round and then invert.

% Does the rounded matrix produce the specification white point
% to four places.  Yes (8/24/10).
%
% W_xyYCheck2 =
% 
%     0.3127
%     0.3290
%     1.0000
W_XYZCheck2 = M_RGBToXYZ2*[1 1 1]';
W_xyYCheck2 = XYZToxyY(W_XYZCheck2);



