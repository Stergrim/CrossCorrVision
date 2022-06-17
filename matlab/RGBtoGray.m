function [Img1] = RGBtoGray(Img)
% The function of converting a color image to black and white

[M0, N0, ~] = size(Img);

Img1 = zeros(M0, N0, 'uint8');

for x = 1:M0
    for y = 1:N0
        Img1(x, y) = (Img(x, y, 1)*0.2989)+(Img(x, y, 2)*0.5870)+(Img(x, y, 3)*0.114);
    end
end

end

