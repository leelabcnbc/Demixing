function [ ZMatrix ] = Gauss2D( Width, Length, Peak )
%Gauss2D Make a 2D gaussian bump for the simulation
%   Detailed explanation goes here
x = -19:20;
y = -19:20;
[X,Y] = meshgrid(x,y);
ZMatrix=Peak*exp(-(X.^2)/(2*Width^2)-(Y.^2)/(2*Length^2));


end

