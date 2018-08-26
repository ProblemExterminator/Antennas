% this script demonstrates conversion from directivity values to Efield values subject to a 
% distance-dependent scale which does NOT affect any results when converting the resulting 
% Efield back to directivity
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(patchMicrostripCircular,fc);
%el= design(dipole,fc);

azi_grid= -180:2:180;
elv_grid= -90:90;

[D,azi,elv]= pattern(el,fc,azi_grid,elv_grid);   % directivity plot
[F,azi,elv]= pattern(el,fc,azi_grid,elv_grid,'Type','efield');   % e-field plot

[Dre,Prad]= Efield2dir(F,azi,elv);

Fre= sqrt(60*Prad*10.^(D/10));   % this is |E| computed from directivity, subject to distance fix

[Dre2,Prad2]= Efield2dir(Fre,azi,elv);

figure; 
surf(abs(D-Dre)); view(2); shading flat; colorbar;
title(gca,'Actual vs Efield-based directivity (diff in dB)');

figure; 
plot(Fre(:)./F(:)); title(gca,'Reconstructed field / given field');

figure;  
surf(abs(D-Dre2)); view(2); shading flat; colorbar;
title(gca,'Actual vs scale-dependent Efield-based directivity (diff in dB)');