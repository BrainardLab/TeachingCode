function sumError = ComputeMapError(targetSolution,mappedSolution)
% sumError = ComputeMapError(targetSolution,mappedSolution)
%
% Compute an error measure of how close a mapping comes to
% a target.
%
% 11/11/05  dhb, scm       Wrote it.
% 1/28/06   scm            On a bug hunt.

DEBUG = 0;
error = targetSolution - mappedSolution;
sumError = sum(error(:).^2);
sprintf('Error %g',sumError);

% if (DEBUG)
%     figure(1); clf; hold on
%     plot(targetSolution(1,:),targetSolution(2,:),'ro','MarkerFaceColor','r','MarkerSize',6);
%     plot(mappedSolution(1,:),mappedSolution(2,:),'bo','MarkerFaceColor','b','MarkerSize',4);
%     axis('square');
%     title(sprintf('Error %g',sumError));
%     drawnow;
%     pause;
% end

