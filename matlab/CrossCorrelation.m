function [OffsetValue0] = CrossCorrelation(OffsetValue0, Image1, Image2, kx, ky, D, lx, ly, px, py)
% A function that performs cross correlation on two images

% Declaration and initialization of arrays for recording values of
% reference windows and polling windows
I1 = zeros(ly, lx, ky, kx);
I2 = zeros(ly, lx, ky, kx);

% Declaration and initialization of arrays for recording the mean and
% standard deviation
mean = zeros(ky, kx, 2);
stdev = zeros(ky, kx, 2);

% Divided into survey windows and calculate the standard deviation
for i0 = 1:ky
    for j0 = 1:kx
        for l = 1:ly
            for m = 1:lx
                % Coordinates of the reference window, taking into account
                % the displacement vectors
                OffsetY = (ly - py)*(i0 - 1 + D) + l + round(OffsetValue0(i0, j0, 3));
                OffsetX = (lx - px)*(j0 - 1 + D) + m + round(OffsetValue0(i0, j0, 2));
                I1(l, m, i0, j0) = Image1(OffsetY, OffsetX);% Reference window
                I2(l, m, i0, j0) = Image2((ly - py)*(i0 - 1 + D) + l, (lx - px)*(j0 - 1 + D) + m);% Окно опроса
                
                mean(i0, j0, 1) = mean(i0, j0, 1) + I1(l, m, i0, j0);
                mean(i0, j0, 2) = mean(i0, j0, 2) + I2(l, m, i0, j0);
            end
        end
        
        % Calculation of the mean value
        mean(i0, j0, 1) = mean(i0, j0, 1) / (lx * ly);
        mean(i0, j0, 2) = mean(i0, j0, 2) / (lx * ly);
        
        % Calculation of the mean square deviation
        for l = 1:ly
            for m = 1:lx
                I1(l, m, i0, j0) = I1(l, m, i0, j0) - mean(i0, j0, 1);
                I2(l, m, i0, j0) = I2(l, m, i0, j0) - mean(i0, j0, 2);
                
                stdev(i0, j0, 1) = stdev(i0, j0, 1) + (I1(l, m, i0, j0))^2;
                stdev(i0, j0, 2) = stdev(i0, j0, 2) + (I2(l, m, i0, j0))^2;
            end
        end
        
        stdev(i0, j0, 1) = (stdev(i0, j0, 1))^0.5;
        stdev(i0, j0, 2) = (stdev(i0, j0, 2))^0.5;
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cross correlation. Recording of displacement values, coordinates of survey
% window centers and normalized correlation coefficients of survey windows
f1 = zeros(ly,lx);
f2 = zeros(ly,lx);

Corr = zeros(ly,lx);

for i0 = 1:ky
    for j0 = 1:kx
        for l = 1:ly
            for m = 1:lx
                f1(l, m) = I1(l, m, i0, j0);
                f2(l, m) = I2(l, m, i0, j0);
            end
        end
        
        F1 = fft2(f1);
        F2 = fft2(f2);
        
        % Here you can add frequency filtering of polling windows and
        % reference windows
        %%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%
        
        % Multiplication of Fourier images of windows with normalization
        for l = 1:ly
            for m = 1:lx
                Corr(l, m) = F1(l, m)*conj(F2(l, m))*((-1)^(l + m));
            end
        end
        
        c = ifft2(Corr);
        
        for l = 1:ly
            for m = 1:lx
                c(l, m) = abs(c(l, m)) / (stdev(i0, j0, 1) * stdev(i0, j0, 2));
            end
        end
        
        cmax = 0;
        xmax = 0;
        ymax = 0;
        
        % Search for coordinates and maximum values in the array
        for l = 1:ly
            for m = 1:lx
                if(cmax < c(l, m))
                    cmax = c(l, m);
                    xmax = m;
                    ymax = l;
                end
            end
        end
        
        % Search for a maximum with subpixel accuracy through a Gaussian curve
        if (xmax == 1)
            Cx = [c(ymax, end), c(ymax, xmax), c(ymax, xmax + 1)];
        elseif(xmax == length(c(1,:)))
            Cx = [c(ymax, xmax - 1), c(ymax, xmax), c(ymax, 1)];
        else
            Cx = [c(ymax, xmax - 1), c(ymax, xmax), c(ymax, xmax + 1)];
        end
        if (ymax == 1)
            Cy = [c(end, xmax), c(ymax, xmax), c(ymax + 1, xmax)];
        elseif(ymax == length(c(:,1)))
            Cy = [c(ymax - 1, xmax), c(ymax, xmax), c(1, xmax)];
        else
            Cy = [c(ymax - 1, xmax), c(ymax, xmax), c(ymax + 1, xmax)];
        end
        
        xmax = xmax + (log(Cx(1)) - log(Cx(3)))/(2*log(Cx(1)) - 4*log(Cx(2)) + 2*log(Cx(3)));
        ymax = ymax + (log(Cy(1)) - log(Cy(3)))/(2*log(Cy(1)) - 4*log(Cy(2)) + 2*log(Cy(3)));
        
        OffsetValue0(i0, j0, 1) = cmax;
        
        % Writing the magnitude of the offsets
        OffsetValue0(i0, j0, 2) = xmax - lx/2 - 1 + round(OffsetValue0(i0, j0, 2));
        OffsetValue0(i0, j0, 3) = ymax - ly/2 - 1 + round(OffsetValue0(i0, j0, 3));
    end
end

end

