% this script illustrates that we can find radiation patterns if we compute
% EHfields in a sphere sufficiently far away from the antenna and compares 
% solution with patterns. Suprisingly, sometimes pattern runs much faster than EHfields. 
% This may be due to the internals of the functions, where I have little access 
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(patchMicrostripCircular,fc);
el2= copy(el);
el2.GroundPlaneWidth= inf;

dx= 1.25*lambda/2;
dy= 1.25*lambda/2;
Num_x= 2;   % number of elements along x axis
Num_y= 3;   % number of elements along y axis

la= linearArray('Element',el,'NumElements',Num_x,'ElementSpacing',dx);
la2= linearArray('Element',el2,'NumElements',Num_x,'ElementSpacing',dx);

ra= rectangularArray('Element',el,'Size',[Num_y Num_x],'RowSpacing',dy,'ColumnSpacing',dx);
ra2= rectangularArray('Element',el2,'Size',[Num_y Num_x],'RowSpacing',dy,'ColumnSpacing',dx);

la.AmplitudeTaper= [1 1];
la.PhaseShift= [0 180];
la2.AmplitudeTaper= [1 1];
la2.PhaseShift= [0 180];

ra.AmplitudeTaper= [1 0 0 1 1 0];
ra.PhaseShift= [ 0 90 90 0 90 0];
ra2.AmplitudeTaper= [1 0 0 1 1 0];
ra2.PhaseShift= [ 0 90 90 0 90 0];

maxD= sqrt(el.GroundPlaneWidth^2+el.GroundPlaneLength^2);
maxD2= min([el2.GroundPlaneLength el2.GroundPlaneWidth]);

maxD_la= (maxD+dx)*Num_x;
maxD_la2=(maxD2+dx)*Num_x;

maxD_ra= (maxD+sqrt(dx^2+dy^2))*sqrt(Num_x^2+Num_y^2);
maxD_ra2= (maxD2+sqrt(dx^2+dy^2))*sqrt(Num_x^2+Num_y^2);

% max distance for single element
maxR= max([2*maxD^2/lambda maxD]);
maxR2= max([2*maxD2^2/lambda maxD2]);

% max distance for linear array
maxR_la= max([2*maxD_la^2/lambda maxD_la]);
maxR_la2= max([2*maxD_la2^2/lambda maxD_la2]);

% max distance for rectangular array
maxR_ra= max([2*maxD_ra^2/lambda maxD_ra]);
maxR_ra2= max([2*maxD_ra2^2/lambda maxD_ra]);

if ( (100*lambda < maxR) || (100*lambda < maxR2) )
   R= 1.5*max([maxR maxR2]);
else
   R= 100*lambda; 
end

if ( (100*lambda < maxR_la) || (100*lambda < maxR_la2) )
   R_la= 1.5*max([maxR_la maxR_la2]);
else
   R_la= 100*lambda; 
end

if ( (100*lambda < maxR_ra) || (100*lambda < maxR_ra2) )
   R_ra= 1.5*max([maxR_ra maxR_ra2]);
else
   R_ra= 100*lambda; 
end

ss= input('Skip finite ground plane computations?(y/n)','s');
if (ss=='y')
   skip_finite_ground= true;
else
   skip_finite_ground= false; 
end
   
if skip_finite_ground
   elv_grid= 0:90;
else
   elv_grid= -90:90; 
end

azi_grid= -180:5:180;

[AZI,ELV]= meshgrid(azi_grid,elv_grid);
[X,Y,Z] = sph2cart(AZI*pi/180,ELV*pi/180,max([R R_la R_ra]));
points= [X(:) Y(:) Z(:)]';
plot3(points(1,:),points(2,:),points(3,:),'o'); view(2); axis equal;

if skip_finite_ground
   [E,H]= EHfields(el2,fc,points);
   [Ela,Hla]= EHfields(la2,fc,points);
   [Era,Hra]= EHfields(ra2,fc,points);   
else
   [E,H]= EHfields(el,fc,points);
   [Ela,Hla]= EHfields(la,fc,points);
   [Era,Hra]= EHfields(ra,fc,points);
end

Esq= abs(E(1,:)).^2+ abs(E(2,:)).^2 + abs(E(3,:)).^2; 
Hsq= abs(H(1,:)).^2+ abs(H(2,:)).^2 + abs(H(3,:)).^2; 

Esq_la= abs(Ela(1,:)).^2+ abs(Ela(2,:)).^2 + abs(Ela(3,:)).^2; 
Hsq_la= abs(Hla(1,:)).^2+ abs(Hla(2,:)).^2 + abs(Hla(3,:)).^2; 

Esq_ra= abs(Era(1,:)).^2+ abs(Era(2,:)).^2 + abs(Era(3,:)).^2; 
Hsq_ra= abs(Hra(1,:)).^2+ abs(Hra(2,:)).^2 + abs(Hra(3,:)).^2; 

subplot(3,1,1); plot(Esq./Hsq);
subplot(3,1,2); plot(Esq_la./Hsq_la);
subplot(3,1,3); plot(Esq_ra./Hsq_ra);

dth= (elv_grid(end)-elv_grid(1))/(length(elv_grid)-1)*pi/180;  % convert to radians
dphi= (azi_grid(end)-azi_grid(1))/(length(azi_grid)-1)*pi/180; % convert to radians
   
[Azi,~]= cart2sph(X(:),Y(:),Z(:));

% field matrix should have rows corresponding to different elevations and
% columns to different azimuths
Esq= reshape(Esq,length(elv_grid),length(azi_grid));
Esq_la= reshape(Esq_la,length(elv_grid),length(azi_grid));
Esq_ra= reshape(Esq_ra,length(elv_grid),length(azi_grid));

Prad= 0;
Prad_la= 0;
Prad_ra= 0;

for ind=1:length(azi_grid)
   Prad= Prad+ dot(Esq(:,ind),cosd(elv_grid))*dth*dphi;
   Prad_la= Prad_la+ dot(Esq_la(:,ind),cosd(elv_grid))*dth*dphi;
   Prad_ra= Prad_ra+ dot(Esq_ra(:,ind),cosd(elv_grid))*dth*dphi;   
end
   
Dre= 10*log10(Esq*4*pi/Prad); 
Dre_la= 10*log10(Esq_la*4*pi/Prad_la);
Dre_ra= 10*log10(Esq_ra*4*pi/Prad_ra);

if skip_finite_ground
   [D,~,~]= pattern(el2,fc,azi_grid,elv_grid);
   [D_la,~,~]= pattern(la2,fc,azi_grid,elv_grid);
   [D_ra,azi,elv]= pattern(ra2,fc,azi_grid,elv_grid);
else
   [D,~,~]= pattern(el,fc,azi_grid,elv_grid);
   [D_la,~,~]= pattern(la,fc,azi_grid,elv_grid);
   [D_ra,azi,elv]= pattern(ra,fc,azi_grid,elv_grid);    
end

figure;
surf(abs(D-Dre)); view(2); shading flat; colorbar;
title(gca,'Actual vs EHfields-based directivity (diff in dB) for microstrip');

figure;
surf(abs(D_la-Dre_la)); view(2); shading flat; colorbar;
title(gca,'Actual vs EHfields-based directivity (diff in dB) for linear array');

figure;
surf(abs(D_ra-Dre_ra)); view(2); shading flat; colorbar;
title(gca,'Actual vs EHfields-based directivity (diff in dB) for rectangular array');
