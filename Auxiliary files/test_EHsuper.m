% this script demonstrates E,H superposition
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

ant1= design(dipole,fc);
ant2= copy(ant1);
ant2.Tilt= 90;
ant2.TiltAxis= [0 1 0];
ant3= copy(ant1);
ant3.Tilt= 90;
ant3.TiltAxis= [1 0 0];

ca=conformalArray('Element',[ant1 ant2 ant3],'ElementPosition',[0 0 0; 0 lambda/2 0; lambda 0 0]);
show(ca);

elv_grid= -90:90;
azi_grid= -180:5:180;
plot_increment= 180;

[AZI,ELV]= meshgrid(azi_grid,elv_grid);
[X,Y,Z] = sph2cart(AZI*pi/180,ELV*pi/180,100*lambda);
points= [X(:) Y(:) Z(:)]';

[E1,H1]= EHfields(ca,fc,points,'ElementNumber',1);
[E2,H2]= EHfields(ca,fc,points,'ElementNumber',2);
[E3,H3]= EHfields(ca,fc,points,'ElementNumber',3);

Et= E1+E2+E3;
Ht= H1+H2+H3;

Esq= abs(Et(1,:)).^2+ abs(Et(2,:)).^2 + abs(Et(3,:)).^2; 
Hsq= abs(Ht(1,:)).^2+ abs(Ht(2,:)).^2 + abs(Ht(3,:)).^2; 

dth= (elv_grid(end)-elv_grid(1))/(length(elv_grid)-1)*pi/180;  % convert to radians
dphi= (azi_grid(end)-azi_grid(1))/(length(azi_grid)-1)*pi/180; % convert to radians

Esq= reshape(Esq,length(elv_grid),length(azi_grid));

Prad= 0;

for ind=1:length(azi_grid)
   Prad= Prad+ dot(Esq(:,ind),cosd(elv_grid))*dth*dphi;
end

Dre= 10*log10(Esq*4*pi/Prad); 

[D,azi,elv]= pattern(ca,fc,azi_grid,elv_grid);

figure;
surf(abs(D-Dre)); shading flat; view(2); colorbar;
title(gca,'Matlab vs superposition-computed directivity (diff in dB)');

figure; patternCustom(D',90-elv,azi);
title(gca,'Matlab-computed directivity');

figure; patternCustom(Dre',90-elv,azi);
title(gca,'Superposition-computed directivity');

figure;
subplot(3,1,1);  plot([elv elv+plot_increment], [D(:,azi==0); flipud(D(:,azi==180))], ...                        
                      [elv elv+plot_increment], [Dre(:,azi==0); flipud(Dre(:,azi==180))]);   
title(gca,'Elevation pattern at phi=0');
legend('Directivity','Superposition','Location','Best');

subplot(3,1,2);  plot([elv elv+plot_increment], [D(:,azi==90); flipud(D(:,azi==-90))], ...                        
                      [elv elv+plot_increment], [Dre(:,azi==90); flipud(Dre(:,azi==-90))]);   
title(gca,'Elevation pattern at phi=90');
legend('Directivity','Superposition','Location','Best');

subplot(3,1,3);  plot(azi,D(elv==0,:),azi,Dre(elv==0,:));
title(gca,'Azimuth pattern at elv=0');
legend('Directivity','Superposition','Location','Best');


