% this script compares the extracted cuts of compute_cuts_inf vs
% patternElevation and patternAzimuth for the 3 primary planes
close all;
clear vars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(patchMicrostripCircular,fc);
el.GroundPlaneWidth= inf;

% we can also use monopole since we want to radiate in a half space (not really important, 
% as we can restrict the elevation values in which we compute the pattern)
%el= design(monopole,fc);

pattern(el,fc,-180:2:180,0:90);
[FF,azi_grid,elv_grid]= pattern(el,fc,-180:2:180,0:90); % 3D pattern

% elevation patterns for phi=90 (x=0)
[F1,azi1,elv1]= pattern(el,fc,90,0:2:180);
F2= patternElevation(el,fc,90,'Elevation',0:2:180);
[ppsi1,Field1]= compute_cuts_inf(-180:2:180,0:90,FF,'x',0,50,'n');

% elevation patterns for phi=0 (y=0)
[F3,azi3,elv3]= pattern(el,fc,0,0:2:180);
F4= patternElevation(el,fc,0,'Elevation',0:2:180);
[ppsi2,Field2]= compute_cuts_inf(-180:2:180,0:90,FF,'y',0,50,'n');

% azimuth patterns
[Fa,azi_a,elv_a]= pattern(el,fc,-180:2:180,0);
Fb= patternAzimuth(el,fc,0,'Azimuth',-180:2:180);
[ppsi3,Field3]= compute_cuts_inf(-180:2:180,0:90,FF,'z',0,50,'n');


figure; 
subplot(3,1,1); plot(ppsi1,Field1); hold on; plot(elv1,F1,'r'); hold on; plot(0:2:180,F2,'g');
title('Elevation pattern for phi=90'); 
legend('cut-based','pattern','patternElevation','Location','Best');

subplot(3,1,2); plot(ppsi2,Field2); hold on; plot(elv3,F3,'r'); hold on; plot(0:2:180,F4,'g');
title('Elevation pattern for phi=0'); 
legend('cut-based','pattern','patternElevation','Location','Best');

subplot(3,1,3); plot(ppsi3,Field3); hold on; plot(azi_a,Fa,'r'); hold on; plot(azi_a,Fb,'g');
title('Azimuth pattern for elv=0'); set(gca,'xlim',[-180 180],'xtick',[-180:30:180]);
legend('cut-based','pattern','patternAzimuth','Location','Best');
