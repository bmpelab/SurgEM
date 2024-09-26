%

%%
function [indexFlag] = edgeOutlierDetector(POINTS,EDGES,LENS,LENS0,SF)

indexFlag = true(size(POINTS,1),1);
rT = 1.2;
rT0 = 2;

POINTS2 = POINTS + SF;
LENS2 = sqrt(sum((POINTS2(EDGES(:,1),:)-POINTS2(EDGES(:,2),:)).^2,2));

deltaLen = LENS2./LENS;
deltaLen0 = LENS2./LENS0;
outlierFlag = logical((deltaLen>rT)+(deltaLen<1/rT)+(deltaLen0>rT0)+(deltaLen0<1/rT0));

indexFlag(EDGES(outlierFlag,1)) = false;
indexFlag(EDGES(outlierFlag,2)) = false;

end