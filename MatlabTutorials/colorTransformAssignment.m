% colorTransformAssignment
%
% Skeleton assignment for thinking about transformations
% between color spaces.
%
% The beginning part loads in the spectral data you'll need
% from files that are part of the Psychophysics Toolbox.  All
% are at the same underlying wavelength sampling [380 5 81].
%
% 1/20/10  dhb  Wrote it.

%% Clear
clear; close all;

%% Load in some color matching functions
% and cone fundamentals to play with.
%
% Judd-Vos XYZ functions and Smith-Pokorny
% cone fundamentals are consistent with the
% same observer, so we'll use those.
load T_xyzJuddVos
load T_cones_sp

%% Load in some primaries.  Typical monitor
% primaries seem as good as anything.
load B_monitor

% Load in a spectral power distribution.
load spd_D65

%% 1) Compute the tristimulus coordinates and
% cone responses to spd_D65

%% 2) Find the linear transformation M_XYZToCones
% that maps XYZ tristimulus coordinates to
% cone responses.
%
% Verify by making a plot that applying this to
% the XYZ color matching functions reproduces
% the cone fundamentals.
%
% Verify that applying this matrix to the tristimulus
% vector you obtained explicitly for spd_D65 produces
% the cone coordinates you obtained explicitly for
% spd_D65.
%
% Verify that obtaining M_ConesToXYZ by taking the
% inverse of M_XYZToCones works for the other direction.


%% 3) Find the linear transformation M_XYZTorgb that
% obtains the linear phosphor weights rgb from desired
% XYZ coordinates.
%
% Compute the rgb values that are needed to produce
% a metamer on the monitor for spd_D65, using this
% matrix and the tristimulus values for spd_D65.
%
% Reconstruct the spectrum that comes off the monitor
% when you use the rgb values above, and compute the
% tristimulus coordinates of this spectrum.  Verify that
% they match those of spd_D65.
%
% Plot spd_D65 and the metameric light that comes from the
% monitor, to verify that even though they have the same
% tristimulus values, they are physically different.

%% 4) Constrcut a matrix B_monochrom that describes monochromatic
% primaries, one with power at 440 nm, one with power at 520 nm,
% and one with power at 650 nm.  Each column of this matrix should
% be the vector representation of one monochromatic light.
%
% Compute a matrix that transforms between rgb values for the
% monitor and rgb values with respect to these primaries, such
% that the two sets of rgb values produce metamers.  
%
% Verify that the metamer you get by applying your matrix and
% reconstructing the weighted sum of monochromatic primaries
% has the right properties, by expliclity computing tristimulus 
% values.