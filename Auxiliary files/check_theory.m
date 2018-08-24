% this script compares the Matlab-computed AF vs the analytical solution for a linear array
close all;
clear variables;

c= 3e8;
fc= 60e9;
lambda= c/fc;
k=2*pi/lambda;

el= design(dipole,fc);
Numel= 8;
dx= lambda/2;

la= linearArray('NumElements',Numel,'ElementSpacing',dx);
show(la);

azi_grid= -180:2:180; 
elv_grid= 0;

[AF,azi,elv]= arrayFactor(la,fc,azi_grid,elv_grid);

AFm= zeros(size(azi_grid));

for ii=0:Numel-1
   AFm= AFm + exp(1j*k*ii*dx*cosd(azi_grid));
end    

% arrayFactor always computes the AF in dB with 10*log10
plot(azi,AF); hold on; plot(azi,10*log10(abs(AFm)),'r');
set(gca,'ylim',[-50 inf]); legend('Matlab','Theory');
