function [MV, k] = ValidationOutlier(OffsetValue1, kx, ky)
% Checking for outliers, the normalized median method

Thr = 1; % Fluctuation threshold (usually about 2)
J = ky; I = kx; % Offset field size
NormFluct = zeros(J,I,2); % Initialization of normalized fluctuation
b = 1; % Radius of the neighborhood of the center point (usually set to 1 or 2)
esp = 0.1; % Calculated measurement noise level (in pixels)
for c = 1:2
    if c == 1; VelComp = OffsetValue1(:,:,2); else; VelComp = OffsetValue1(:,:,3); end
    % Loop over all data points (excluding the boundary)
    for i = 1+b:I-b
        for j = 1+b:J-b
            Neigh = VelComp(j-b:j+b,i-b:i+b); % The area with the center point
            NeighCol = Neigh(:); % Translation to column
            NeighCol2 = [NeighCol(1:(2*b+1)*b+b); NeighCol((2*b+1)*b+b+2:end)];
            % Neighborhood, excluding the center point
            Median = median(NeighCol2); % Median of the neighborhood
            Fluct = VelComp(j,i) - Median; % Fluctuations relative to the median
            Res = NeighCol2 - Median; % Residual fluctuations of neighbors relative to the median
            MedianRes = median(abs(Res)); % Median (absolute) value of the remainder
            % Normalized fluctuation relative to the neighborhood
            NormFluct(j,i,c) = abs(Fluct/(MedianRes + esp)); 
        end
    end
end

% Counting the number of emissions
k = 0;
for i0 = 1:ky
    for j0 = 1:kx
        if (sqrt(NormFluct(i0,j0,1)^2 + NormFluct(i0,j0,2)^2)) > Thr
            k = k + 1;
        end
    end
end

% Writing of emission coordinates
MV = zeros(k,2);
k = 0;

for i0 = 1:ky
    for j0 = 1:kx
        if (sqrt(NormFluct(i0,j0,1)^2 + NormFluct(i0,j0,2)^2)) > Thr
            k = k + 1;
            MV(k,1) = i0;
            MV(k,2) = j0;
        end
    end
end

end

