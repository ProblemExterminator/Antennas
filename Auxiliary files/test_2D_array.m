close all;
clearvars;

fd= 1e9;
c= 3e8;
lambda= c/fd;
dlength= lambda/4;

d1=dipole('Length',dlength,'Width',0.01*lambda);
show(d1); set(gcf,'name','z-oriented dipole');

d2=dipole('Length',dlength,'Width',0.01*lambda,'Tilt',90,'TiltAxis',[0 1 0]);
figure; show(d2); set(gcf,'name','x-oriented dipole');

d3=dipole('Length',dlength,'Width',0.01*lambda,'Tilt',90,'TiltAxis',[1 0 0]);
figure; show(d3); set(gcf,'name','y-oriented dipole');

% by default, array is constructed in x-y plane, where rows/columns
% correspond to crossword notation
% all elements are placed symmetrically w.r.t. x,y axes
% if you want to manually set element positions, use conformalArray instead
ra1= rectangularArray('Element',d1,'Size',[2 3],'RowSpacing',lambda/2,'ColumnSpacing',lambda);
figure; show(ra1);

ra2= rectangularArray('Element',d2,'Size',[2 3],'RowSpacing',lambda/2,'ColumnSpacing',lambda);
figure; show(ra2);

ra3= rectangularArray('Element',d3,'Size',[2 3],'RowSpacing',lambda/2,'ColumnSpacing',lambda);
figure; show(ra3);

disp('Press any key to continue');
pause;

disp('We will now compute radiation patterns in different planes');
close all;

patternAzimuth(ra1,fd,0,'Azimuth',-180:180); set(gcf,'name','ra1 azimuth pattern at elevation 0');
figure; patternElevation(ra1,fd,90,'Elevation',-180:180); set(gcf,'name','ra1 elevation pattern at phi=90');
figure; patternElevation(ra1,fd,0,'Elevation',-180:180); set(gcf,'name','ra elevation pattern at phi=0');
figure; patternAzimuth(ra1,fd,[0 10 20 30],'Azimuth',-180:180); set(gcf,'name','ra1 azimuth patterns at different elevations');

% plot different patterns in Cartesian plot; different rows correspond to
% different elevations
FF= pattern(ra1,fd,'Azimuth',-180:180,'Elevation',[0 10 20 30]);
figure; plot(-180:180,FF'); set(gca,'xlim',[-180 180]); title('Azimuth patterns at different elevations');

disp('Moving on to second array. Press any key to continue');
pause;

close all;
pattern(ra2,fd);
figure; patternAzimuth(ra2,fd,0,'Azimuth',-180:180);

[fie1,~,elv1]= pattern(ra2,fd,0,-180:180);
[fie2,~,elv2]= pattern(ra2,fd,90,-180:180);

plot(elv1,fie1); hold on; plot(elv2,fie2,'r'); set(gca,'xlim',[-180 180]); 
xlabel('Elevation'); legend('phi=0','phi=90');

disp('Moving on to third array. Press any key to continue');
pause;

close all;
pattern(ra3,fd);
figure; patternAzimuth(ra3,fd,0,'Azimuth',-180:180);
figure; patternElevation(ra3,fd,0,'Elevation',-180:180);
figure; patternElevation(ra3,fd,90,'Elevation',-180:180);

disp('To see how Matlab numbers elements, use layout');
disp('Press any key to continue');
pause;

close all;
d4= copy(d1);
d4.Length= lambda/4;
ra4= rectangularArray('Element',d4,'Size',[2 10],'RowSpacing',lambda/2,'ColumnSpacing',lambda/4);
layout(ra4);

ra4.AmplitudeTaper= repmat([1; 0],10,1);
bb=[90*(1:10); zeros(1,10)];
ra4.PhaseShift= bb(:);
figure; patternAzimuth(ra4,fd,0,'Azimuth',-180:180);
set(gcf,'name','Peak should be on opposite side of first element');

figure; ra4.PhaseShift= -ra4.PhaseShift;
patternAzimuth(ra4,fd,0,'Azimuth',-180:180);
set(gcf,'name','Peak should be on same side of first element');

ra4.PhaseShift= ra4.PhaseShift + 50;
figure; patternAzimuth(ra4,fd,0,'Azimuth',-180:180);
set(gcf,'name','Adding constant phase to each array element');


disp('We next demonstrate array rotation. Press any key to continue');
pause;

close all;
ra5= copy(ra1);
ra5.TiltAxis= [0 0 1];
ra5.Tilt= 90;

show(ra1); figure; show(ra5); set(gcf,'name','Rotating around z axis');

% WARNING: all rotations are w.r.t. original array orientation
ra5.TiltAxis= [1 0 0];
ra5.Tilt= 90; 

figure; show(ra5); set(gcf,'name','Rotating around x axis');

% apply consecutive rotations. Each rotation needs an axis of rotation (3
% points in space) and an angle of rotation w.r.t. this axis
% WARNING: first set the value of the TiltAxis and then the value of Tilt
ra5.TiltAxis= [0 0 1; 1 1 0];
ra5.Tilt= [45; 90];
figure; show(ra5); set(gcf,'name','Performing sequence of rotations');

% WARNING: even though array has been rotated, individual element still
% has original orientation
figure; show(ra5.Element);

% WARNING: array rotation operates as a whole, i.e. the entire array is rotated

ra5.Tilt= 45;
ra5.TiltAxis= [0 0 1];
figure; pattern(ra5,fd);

disp('We finally examine mutual coupling effects. Press any key to continue');
pause;

close all;

[F1_nc,~,~]= patternMultiply(ra1,fd,-180:180,0);
[F1_c,azi1,elv1]= pattern(ra1,fd,-180:180,0);

[F2_nc,~,~]= patternMultiply(ra1,fd,0,-180:180);
[F2_c,azi2,elv2]= pattern(ra1,fd,0,-180:180);

subplot(1,2,1);
plot(azi1,F1_nc); hold on; plot(azi1,F1_c,'r'); title('Azimuth patterns');
legend('No coupling','Coupling');

subplot(1,2,2);
plot(elv2,F2_nc); hold on; plot(elv2,F2_c,'r'); title('Elevation patterns');
legend('No coupling','Coupling');

[F3_nc,~,~]= patternMultiply(ra2,fd,-180:180,0);
[F3_c,azi3,elv3]= pattern(ra2,fd,-180:180,0);

[F4_nc,~,~]= patternMultiply(ra2,fd,0,-180:180);
[F4_c,azi4,elv4]= pattern(ra2,fd,0,-180:180);

figure;
subplot(1,2,1);
plot(azi3,F3_nc); hold on; plot(azi3,F3_c,'r'); title('Azimuth patterns');
legend('No coupling','Coupling');

subplot(1,2,2);
plot(elv4,F4_nc); hold on; plot(elv4,F4_c,'r'); title('Elevation patterns');
legend('No coupling','Coupling');

