function newImageMatrix = NormalizeImageMatrix(imageMatrix)
% newImageMatrix = NormalizeImageMatrix(imageMatrix)
%
% rescales image in the [0..1] range (full contrast)
%
% 12/10/12  npc  Wrote it.
 
    min2 = min(min(imageMatrix));
    max2 = max(max(imageMatrix));
    newImageMatrix = (imageMatrix - min2)/(max2-min2);
end
