function [CoordStart,CoordEnd] = MultiplePassInterrogation(Image1, Image2, SizeWindow, CrossWindow, Iters, Indent, Scale)
% The main function of calling the method of mutual correlation on two images

% If the images are three-channel, then convert to black and white
if (size(size(Image1),2) == 3)
    if (size(Image1,3) == 3)
        [Image1] = FGray(Image1);
        [Image2] = FGray(Image2);
    end
end

% Horizontal and vertical polling window size
lx = SizeWindow;
ly = SizeWindow;

% The size of the intersection of the polling windows horizontally and vertically
px = CrossWindow;
py = CrossWindow;

[M, N] = size(Image1); % Writing image sizes

% The offset from the edges of the image in the offsets of the polling windows
D = Indent;

% Determining the number of polling windows with a fixed intersection value
kx = floor((N - px)/(lx - px)) - 2*D;
ky = floor((M - py)/(ly - py)) - 2*D;

OffsetValue0 = zeros(ky, kx, 3); % Initializing the initial offset of windows

p = 0; % Counter of displacement vectors that are greater than one
Smax = Iters; % Maximum number of offset cycles

for s = 1:Smax
    % Cross correlation taking into account window offsets in the previous step
    [OffsetValue1] = CrossCorrelation(OffsetValue0, Image1, Image2, kx, ky, D, lx, ly, px, py);
    [MV, k] = ValidationOutlier(OffsetValue1, kx, ky);% Checking for emissions
    [OffsetValue1] = Interpolation(MV, OffsetValue1, k);% Interpolation
    
    % Counting the number of vectors whose length is greater than one
    for i0 = 1:ky
        for j0 = 1:kx
            for c = 2:3
                if abs(OffsetValue1(i0,j0,c) - OffsetValue0(i0,j0,c)) > 1
                    p = p + 1;
                end
            end
        end
    end
    % Writing the offset for the next iteration of the loop or output
    OffsetValue0 = OffsetValue1;
    
    % If all vectors have an offset less than one, then exit the loop,
    % otherwise reset the counter
    if p == 0
        break;
    else
        p = 0; 
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output of the offset field

CenterValue = zeros(ky,kx,2);

for i0 = 1:ky
    for j0 = 1:kx
        % Writing the coordinates of the reference window centers 
        CenterValue(i0, j0, 1) = lx/2 + (j0-1+D)*(lx-px); 
        CenterValue(i0, j0, 2) = ly/2 + (i0-1+D)*(ly-py);
    end
end

% Initializing arrays to build a vector field
X = zeros(ky,kx);
Y = zeros(ky,kx);
U = zeros(ky,kx);
V = zeros(ky,kx);

for m = 1:ky
    for n = 1:kx
        X(m,n) = CenterValue(m,n,1);
        Y(m,n) = CenterValue(m,n,2);
        U(m,n) = -OffsetValue0(m,n,2);
        V(m,n) = -OffsetValue0(m,n,3);
    end
end

S = size(X);
N = S(1)*S(2);

CoordStart = zeros(N,2);
CoordEnd = zeros(N,2);

for i0 = 1:N
    CoordStart(i0,1) = X(i0);
    CoordStart(i0,2) = Y(i0);
    CoordEnd(i0,1) = X(i0) + U(i0);
    CoordEnd(i0,2) = Y(i0) + V(i0);
end

% Image output together with a vector field
imshow(Image1, [0,255])
hold on
if (Scale == "NoAuto")
    quiver(X,Y,U,V,0,'g', LineWidth = 1.5) % Output without autoscaling
elseif (Scale == "Auto")
    quiver(X,Y,U,V,'g', LineWidth = 1.5) % Output with autoscaling
else
    error('Set the vector scaling parameter: Scale ("Auto" or "NoAuto")');
end

end

