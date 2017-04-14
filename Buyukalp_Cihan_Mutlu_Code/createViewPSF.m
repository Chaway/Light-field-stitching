function [PSF, size1Increased, size2Increased] = createViewPSF(I, A, u0, v0)

size1 = size(I,1); size2 = size(I,2);

if mod(size1, 2) == 0
    size1 = size1+1;
    size1Increased = true;
else
    size1Increased = false;
end


if mod(size2, 2) == 0
    size2 = size2+1;
    size2Increased = true;
else
    size2Increased = false;
end

for yi =  1 : size1
    for xi = 1 : size2
        y = yi - 1 + ceil(-(size1-1)/2);
        x = xi - 1 + ceil(-(size2-1)/2);
               
        theta = angle(x+1i*y);
        su0v0(yi,xi) = y./(A*sin(asin(1/A*(cos(theta)*v0 - sin(theta)*u0)) + theta) - v0);
        
        theta = angle(-x - 1i * y);
        su0v0M(yi,xi) = -y./(A*sin(asin(1/A*(cos(theta)*v0 - sin(theta)*u0)) + theta) - v0);
    end
end
        
 PSF = (pi^2 .* A^2 .* su0v0).^(-1) + (pi^2 .* A^2 .* su0v0M).^(-1);