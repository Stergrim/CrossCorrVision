function [OffsetValue1] = Interpolation(MV, OffsetValue1, k)
% The function of performing bilinear interpolation by the nearest vectors

% Radius of the neighborhood of the center point (cannot exceed the radius
% when searching for outliers)
b = 1;

% Initialization of the deviation of the interpolated vector between two
% iterations. Any number greater than in the condition below
DeltaSum = 10;

% X-axis interpolation
while DeltaSum > 0.1
    DeltaSum = 0;
    for m = 1:k
        j = MV(m,1);
        i = MV(m,2);
        NeighI = OffsetValue1(j-b:j+b,i-b:i+b,2);
        NeighColI = NeighI(:);
        NeighCol2I = [NeighColI(1:(2*b+1)*b+b); NeighColI((2*b+1)*b+b+2:end)];
        MedianI = median(NeighCol2I);
        Delta = abs(MedianI - OffsetValue1(j,i,2));
        OffsetValue1(j, i, 2) = MedianI;
        DeltaSum = DeltaSum + Delta;
    end
    DeltaSum = DeltaSum/k;
end

DeltaSum = 10;

% Y-axis interpolation
while DeltaSum > 0.1
    DeltaSum = 0;
    for m = 1:k
        j = MV(m,1);
        i = MV(m,2);
        NeighJ = OffsetValue1(j-b:j+b,i-b:i+b,3);
        NeighColJ = NeighJ(:);
        NeighCol2J = [NeighColJ(1:(2*b+1)*b+b); NeighColJ((2*b+1)*b+b+2:end)];
        MedianJ = median(NeighCol2J);
        Delta = abs(MedianJ - OffsetValue1(j,i,3));
        OffsetValue1(j, i, 3) = MedianJ;
        DeltaSum = DeltaSum + Delta;
    end
    DeltaSum = DeltaSum/k;
end

end

