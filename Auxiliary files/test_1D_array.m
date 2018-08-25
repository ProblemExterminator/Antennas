close all;
clearvars;

fd= 1e9;
c= 3e8;
lambda= c/fd;
dlength= lambda/4;

% by default, dipole is oriented against z axis
d1=dipole('Length',dlength,'Width',0.01*lambda);
show(d1); set(gcf,'name','z-oriented dipole');

d2=dipole('Length',dlength,'Width',0.01*lambda,'Tilt',90,'TiltAxis',[0 1 0]);
figure;
show(d2); set(gcf,'name','x-oriented dipole');

d3=dipole('Length',dlength,'Width',0.01*lambda,'Tilt',90,'TiltAxis',[1 0 0]);
figure;
show(d3); set(gcf,'name','y-oriented dipole');

% compute some antenna beamwidths
% in case of symmetric patterns with multiple points of same intensity
% each row of angles contains points in specified plane which have the 
% required power intensity
% rows of bw correspond to different beamwidths
[bw1,angles1]= beamwidth(d1,fd,0,-180:1:180,3);
[bw2,angles2]= beamwidth(d1,fd,90,-180:1:180,3);
fprintf(1,'Beamwidth in phi=0: %d\nBeamwidth in phi=90: %d\n',bw1,bw2);

Numel= 4;
Elem_space= lambda/2;

% by default, all linear array elements are separated wrt x axis
% to separate elements along other axis, you have to provide tilt
% values to the array
la1= linearArray('Element',d1,'NumElements',Numel,'ElementSpacing',Elem_space);
la2= linearArray('Element',d2,'NumElements',Numel,'ElementSpacing',Elem_space);

figure;
show(la1); set(gcf,'name','array separation against x axis');

figure;
show(la2); set(gcf,'name','array separation against x axis');

disp('Press any key to continue');
pause;

close all;
% WARNING: do NOT use assignment to copy array objects as any such copies retain
% references to same memory and any change to one object affect the other 
% use the copy method instead
la3= copy(la2);
la3.Tilt= -90;
la3.TiltAxis= [0 1 0];

la4= linearArray('Element',d3,'NumElements',Numel,'ElementSpacing',Elem_space);

show(la1);
figure;
show(la2);
figure;
show(la3); set(gcf,'name','array separation against z axis');
figure;
show(la4);

disp('We will now check whether symmetry properties for radiation patterns hold');
disp('Press any key to continue');
pause;

close all;
pattern(la1,fd);
figure; pattern(la4,fd);
figure; pattern(la2,fd);
figure; pattern(la3,fd);

disp('We will compute some azimuth and elevation patterns');
disp('Press any key to continue');
pause;

fie1= patternElevation(la1,fd,0,'Elevation',-180:180);
fie2= patternAzimuth(la4,fd,0,'Azimuth',-180:180);
fie3= patternAzimuth(la1,fd,0,'Azimuth',-180:180);
fie4= patternElevation(la4,fd,0,'Elevation',-180:180);

subplot(2,1,1);
plot(fie1); hold on; plot(fie2,'r'); legend('la1 elevation pattern','la4 azimuth pattern','Location','Best');
subplot(2,1,2);
plot(fie4); hold on; plot(fie4,'r'); legend('la1 azimuth pattern','la4 elevation pattern','Location','Best');

fie5= patternElevation(la2,fd,90,'Elevation',-180:180);
fie6= patternAzimuth(la3,fd,0,'Azimuth',-180:180);
fie7= patternAzimuth(la2,fd,0,'Azimuth',-180:180);
fie8= patternElevation(la3,fd,0,'Elevation',-180:180);

figure;
subplot(2,1,1);
plot(fie5); hold on; plot(fie6,'r'); legend('la2 elevation pattern','la3 azimuth pattern','Location','Best');
subplot(2,1,2);
plot(fie7); hold on; plot(fie8,'r'); legend('la2 azimuth pattern','la3 elevation pattern','Location','Best');

disp('We will next compute some more radiation patterns. Press any key to continue');
pause;

close all;

pattern(la1,fd,-180:2:180,-180:2:180);
figure; patternAzimuth(la1,fd,[0 25 40],'Azimuth',-180:180);

% to combine patterns in subplots, we cannot use pattern directly since
% they delete all current axes. We have to save the data first and then use
% polarplot. Subplot numbering goes [ 1 2; 3 4 ]
[FF,azi,elv]= pattern(la1,fd,-180:180,[0 25 40 60]);  % azimuth values for elevation=0

figure;
subplot(2,2,1);
polarplot(azi*pi/180,FF(1,:)); rlim([min(FF(1,:))-10 max(FF(1,:))]);  % the -10 dB is a magic 
% number selected through trial and error to create visually appealing plots
title('elevation=0');

subplot(2,2,2);
polarplot(azi*pi/180,FF(2,:)); rlim([min(FF(2,:))-10 max(FF(2,:))]);
title('elevation=25');

subplot(2,2,3);
polarplot(azi*pi/180,FF(3,:)); rlim([min(FF(3,:))-10 max(FF(3,:))]);
title('elevation=40');

subplot(2,2,4);
polarplot(azi*pi/180,FF(4,:)); rlim([min(FF(4,:))-10 max(FF(4,:))]);
title('elevation=60');

disp('Press any key to continue');
pause;

close all;

patternAzimuth(la1,fd,[0 25 40],'Azimuth',-180:180);
figure; patternElevation(la1,fd,[0 90],'Elevation',-180:180);

figure; pattern(la2,fd);

figure; pattern(la3,fd);

figure; pattern(la4,fd);

disp('Press any key to continue');
pause;

close all;
% energize only specific elements and compare array pattern with individual element
% patterns

patternAzimuth(d1,fd,0,'Azimuth',-180:180);

% create a new array copy to test different amplitude tapers
la5= copy(la1);

disp('We now create a linear array and energize each element individually');
disp('The goal is to determine how Matlab numbers the elements and also to illustrate mutual coupling');

for ii=1:Numel
  vv = zeros(1,Numel);
  vv(ii)=1;
  la5.AmplitudeTaper= vv;
  
  figure;
  patternAzimuth(la5,fd,0,'Azimuth',-180:180); 
end

disp('We will now use end-fire antenna condition to determine how array elements are counted');
disp('Press any key to continue');
pause;

close all;
la6= linearArray('Element',d1,'NumElements',10,'ElementSpacing',lambda/4);
la6.AmplitudeTaper=1;
bb= 2*pi/lambda*la6.ElementSpacing;
la6.PhaseShift= bb*(1:la6.NumElements)*180/pi;

patternAzimuth(la6,fd,0,'Azimuth',-180:180);
set(gcf,'name','Peak should be on opposite side of first element');

figure;
la6.PhaseShift= -bb*(1:la6.NumElements)*180/pi;
patternAzimuth(la6,fd,0,'Azimuth',-180:180);
set(gcf,'name','Peak should be on same side as first element');

figure;
phi0= 30;  % angle of rotation in azimuth plane
bb= -2*pi/lambda*Elem_space*cosd(phi0);

% CONCLUSION: numbering of elements is wrt to axis increment where the axis
% is the symmetry axis of the array

disp('Press any key to continue');
pause;

close all;
disp('We will now plot radiation patterns with and without coupling for simple arrays');

disp('The following plots should all be identical circles, since they ignore coupling');
for ii=1:Numel
  vv = zeros(1,Numel);
  vv(ii)=1;
  la5.AmplitudeTaper= vv;
  
  figure;
  patternMultiply(la5,fd,-180:180,0);
end

disp('Press any key to continue');
pause;

close all;

[F1_nc,~,~]= patternMultiply(la1,fd,-180:180,0);
[F1_c,azi1,elv1]= pattern(la1,fd,-180:180,0);

[F2_nc,~,~]= patternMultiply(la1,fd,0,-180:180);
[F2_c,azi2,elv2]= pattern(la1,fd,0,-180:180);

subplot(1,2,1);
plot(azi1,F1_nc); hold on; plot(azi1,F1_c,'r'); title('Azimuth patterns');
legend('No coupling','Coupling');

subplot(1,2,2);
plot(elv2,F2_nc); hold on; plot(elv2,F2_c,'r'); title('Elevation patterns');
legend('No coupling','Coupling');

figure;
subplot(1,2,1);
polarplot(azi1*pi/180,F1_nc); rlim([min(F1_nc)-10 max(F1_nc)]);
hold on;
polarplot(azi1*pi/180,F1_c,'r'); 
title('Azimuth patterns'); legend('No coupling','Coupling');

subplot(1,2,2);
polarplot(elv2*pi/180,F2_nc); rlim([min(F2_nc)-10 max(F2_nc)]);
hold on;
polarplot(elv2*pi/180,F2_c,'r'); 
title('Elevation patterns'); legend('No coupling','Coupling');
