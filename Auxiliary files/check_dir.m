% this script compares directivity plots that Matlab computes with field-based 
% directivity plots based on our methodology
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(patchMicrostripCircular,fc);

azi_grid= -180:2:180;
elv_grid= -90:90;

[D,aziD,elvD]= pattern(el,fc,azi_grid,elv_grid);   % directivity pattern
[F,aziF,elvF]= pattern(el,fc,azi_grid,elv_grid,'Type','efield');  % field pattern
Ftt= F.^2;   % need |E|^2 for radiation intensity U (check Balanis)
 
dth= (elv_grid(end)-elv_grid(1))/(length(elv_grid)-1)*pi/180;  % convert to radians
dphi= (azi_grid(end)-azi_grid(1))/(length(azi_grid)-1)*pi/180; % convert to radians
   
Prad=0;
for ind=1:length(azi_grid)
   Prad= Prad+ dot(Ftt(:,ind),cosd(elv_grid))*dth*dphi;
end
   
Ft= 10*log10(Ftt*4*pi/Prad);  % keep the name Ft so that plotting commands don't change

P1=polarpattern([elvD elvD+180], [D(:,aziD==0); flipud(D(:,aziD==180))], ...              
                [elvF elvF+180], [Ft(:,aziF==0); flipud(Ft(:,aziF==180))]);        
            
P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;        
set(gcf,'name','Elevation plot for phi=0');
legend('directivity pattern','field-based pattern');

figure; set(gcf,'name','Elevation plot for phi=90');
P2=polarpattern([elvD elvD+180], [D(:,aziD==90); flipud(D(:,aziD==-90))], ...
                [elvF elvF+180], [Ft(:,aziF==90); flipud(Ft(:,aziF==-90))]);

P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;        
legend('directivity pattern','field-based pattern');

figure; set(gcf,'name','Azimuth plot for elv=20');
P3= polarpattern(aziD,D(elvD==20,:),aziF,Ft(elvF==20,:));
P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
legend('directivity pattern','field-based pattern');
