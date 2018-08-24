% this script demonstrates that the AF of a rectangular array depends only on array configuration 
% and NOT on specific radiating element used. It computes the AF of 2 arrays (dipoles and microstrip 
% patch) and compares them
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

d= design(dipole,fc);
el= design(patchMicrostripCircular,fc);

ra= rectangularArray('Element',d,'Size',[2 2],'RowSpacing',3*lambda/4,'ColumnSpacing',lambda);
ra2= rectangularArray('Element',el,'Size',[2 2],'RowSpacing',3*lambda/4,'ColumnSpacing',lambda);

[F1,azi1,elv1]= arrayFactor(ra,fc);
[F2,azi2,elv2]= arrayFactor(ra2,fc);

plot_increment= 180;

figure;
P1= polarpattern([elv1 elv1+plot_increment], [F1(:,azi1==0); flipud(F1(:,azi1==180))], ...
                 [elv2 elv2+plot_increment], [F2(:,azi1==0); flipud(F2(:,azi1==180))]);

P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;
P1.TitleBottom= 'AF at phi=0';
legend('AF with dipole','AF with microstrip');

figure;
P2= polarpattern([elv1 elv1+plot_increment], [F1(:,azi1==90); flipud(F1(:,azi1==-90))], ...
                 [elv2 elv2+plot_increment], [F2(:,azi1==90); flipud(F2(:,azi1==-90))]);

P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;
P2.TitleBottom= 'AF at phi=90';
legend('AF with dipole','AF with microstrip');

figure; 
P3= polarpattern(azi1,F1(elv1==20,:),azi2,F2(elv2==20,:));
P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
P3.TitleBottom= 'AF at elv=0';
legend('AF with dipole','AF with microstrip');
