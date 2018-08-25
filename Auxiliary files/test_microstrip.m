% this script just illustrates use of antenna toolbox functions
close all;
clear all;

c= 3e8;
fc= 60e9;
lambda= c/fc;

mr= design(patchMicrostrip,fc);
mc= design(patchMicrostripCircular,fc);

tic;
[FFr,azir,elvr]= pattern(mr,fc,-180:2:180,-90:90);
[FFc,azic,elvc]= pattern(mc,fc,-180:2:180,-90:90);

DD= abs(FFr-FFc);

% we neglect radiation behind microstrip patch
surf(azir,elvr,DD); xlabel('Azimuth angle'); ylabel('Elevation angle');
set(gca,'xlim',[-180 180],'ylim',[0 90]); view(2); shading flat; colorbar;

fprintf(1,'(Max) Directivity for rectangular patch= %d\n',max(max(FFr)));
fprintf(1,'(Max) Directivity for circular patch= %d\n',max(max(FFc)));

% pattern slices
[F1r,azi1r,elv1r]= pattern(mr,fc,-180:180,0);
[F1c,azi1c,elv1c]= pattern(mc,fc,-180:180,0);

[F2r,azi2r,elv2r]= pattern(mr,fc,0,-180:180);
[F2c,azi2c,elv2c]= pattern(mc,fc,0,-180:180);

[F3r,azi3r,elv3r]= pattern(mr,fc,90,-180:180);
[F3c,azi3c,elv3c]= pattern(mc,fc,90,-180:180);

figure; plot(azi1r,F1r); hold on; plot(azi1c,F1c,'r'); 
title('Azimuth pattern'); legend('rectangular','circular');

figure; plot(elv2r,F2r); hold on; plot(elv2c,F2c,'r'); 
title('Elevation patter for phi=0'); legend('rectangular','circular');

figure; plot(elv3r,F3r); hold on; plot(elv3c,F3c,'r'); 
title('Elevation patter for phi=90'); legend('rectangular','circular');
toc,