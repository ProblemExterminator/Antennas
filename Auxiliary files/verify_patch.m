% this script demonstrates antenna toolbox capabilities w.r.t. orientation, angles etc
close all;
clear vars;

fd= 60e9;
patch_el= design(patchMicrostrip,fd);
show(patch_el); title('Default orientation');

%figure(2);
%impedance(patch_el,linspace(0.8*fd,1.2*fd,50));

figure(3);
pattern(patch_el,fd);

% perform rotation and see if pattern changes accordingly
patch_el.TiltAxis=[1 0 0]; % rotate w.r.t. x axis
patch_el.Tilt= -90;  % positive rotation is w.r.t. right-hand rule

figure(4);
show(patch_el); title('Rotated ground plane of patch antenna');

figure(5);
pattern(patch_el,fd);

disp('Inspect all plots and make sure everything makes sense. Press any key to continue');
pause;

close all;
patch_el= design(patchMicrostrip,fd);

[UU,azi,elv]= pattern(patch_el,fd); 
% rows of UU indicate different elevation angles
% columns of UU indicate different azimuth angles
% azimuth and elevation angles are in row vectors

surf(azi,elv,UU); shading flat; colorbar; view(2); xlabel('Azimuth (degrees)');
ylabel('Elevation (degrees)');

figure(2);   % specific pattern functions
patternAzimuth(patch_el,fd,0,'Azimuth',-180:2:180); 
AV1= patternAzimuth(patch_el,fd,0,'Azimuth',-180:2:180);  % elv=0 plot 

figure(3);
%Elevation angle below is measured from the equator
patternElevation(patch_el,fd,[0 45 90],'Elevation',-180:2:180);

% general pattern function: element, freq, azimuth, elev
AV2= pattern(patch_el,fd,-180:2:180,0);

[UU2,azi2,elv2]= pattern(patch_el,fd,-180:5:180,-180:5:180); 
[UU3,azi3,elv3]= pattern(patch_el,fd,-180:5:180,-90:2:90);

% plot patterns of data with patternCustom: 2D plots
% CAUTION: matrix argument has different convention w.r.t pattern
% rows denotes different azimuth values, columns denote different elevation values
% basically, you need to tranpose a matrix produded by pattern to plot it
% with patternCustom
figure(4);
patternCustom(UU2',elv2,azi2,'Slice','phi','SliceValue',90);

% if elevation has only been specified in [-90 90], then only half of the space is plotted. This can be 
% considered a "bug" of patternCustom, which is why patternCustom should be avoided
figure(5);
patternCustom(UU3',elv3,azi3,'Slice','phi','SliceValue',90);


AV3= patternElevation(patch_el,fd,90,'Elevation',-180:5:180);

figure(6); set(gcf,'name','Rectangular plot at phi=90');
patternCustom(UU2',elv2,azi2,'Slice','phi','SliceValue',90,'CoordinateSystem','rectangular');
hold on; plot(-180:5:180,AV3,'r','Linewidth',2); legend('patternCustom slice','pattern');

% first argument is stdout fid
fprintf(1,'If everything is OK, the following result should be 1: %d\n', isequal(AV1',AV2));

patch_cyl= design(patchMicrostripCircular,fd);
pa1= patternAzimuth(patch_el,fd,0,'Azimuth',-180:2:180);
pa2= patternAzimuth(patch_cyl,fd,0,'Azimuth',-180:2:180);

% create multiple 2D patterns in same plot
figure(7);
polarpattern(-180:2:180,pa1,-180:2:180,pa2,'AngleResolution',30,'DrawGridToOrigin',1,'LegendVisible',1,...
        'LegendLabels',{'rectangular','circular'},'TitleTop','Azimuth pattern comparison');


