% this script compute array factors for different radiating elements and different configuration of 
% arrays and shows that AF does not depend on radiating element
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(dipole,fc);
el2= design(patchMicrostripCircular,fc);

show(el);

Num_x= 4;
Num_y= 8;
dx= lambda;
dy= 3*lambda/2;

ra= rectangularArray('Element',el,'Size',[Num_y Num_x],'RowSpacing',dy,'ColumnSpacing',dx);
show(ra);

x= (0:Num_x-1)*dx;
y= (0:Num_y-1)*dy;
[Xp,Yp]= meshgrid(x,y);

Feed_positions= [Xp(:) Yp(:) repmat(el.FeedOffset,Num_x*Num_y,1)];

ca= conformalArray('Element',el,'ElementPosition',Feed_positions,'Reference','feed');
figure; show(ca);

ca2= conformalArray('Element',el2,'ElementPosition',Feed_positions,'Reference','feed');
show(ca2);

memf_need= memoryEstimate(ca2,fc);
mem_avail= memory;
mem_avail= mem_avail.MemAvailableAllArrays;
sf= split(string(memf_need));
szf= str2double(convertStringsToChars(sf(1)));
skip_finite_ground= false;

fprintf('Memory required for solving microstrip antenna with finite ground plane: %s\n',memf_need);

if strcmpi(sf(2),"GB") && (szf> mem_avail*1e-9)
    disp('Insufficient memory for solving finite ground plane. Skipping computation');
    skip_finite_ground= true;
elseif (strcmpi(sf(2),"MB")) && (szf> mem_avail*1e-6)
    disp('Insufficient memory for solving finite ground plane. Skipping computation');
    skip_finite_ground= true;
elseif (~strcmpi(sf(2),"MB")) && (~strcmpi(sf(2),"GB"))
    disp('Don''t know how to continue. Skipping computation');
    skip_finite_ground= true;
end

azi_grid= -180:2:180;
elv_grid= 0:2:180;

EM_solve_function= @arrayFactor;

[AFr,azir,elvr]= feval(EM_solve_function,ra,fc,azi_grid,elv_grid);
[AFc,azic,elvc]= feval(EM_solve_function,ca,fc,azi_grid,elv_grid);

ca_shifted= copy(ca);
ca2_shifted= copy(ca2);

for i=1:10
   ranshift= lambda*randn(1,2);
   ranshift2= 1.5*lambda*randn(1,2);
   
   ca_shifted.ElementPosition= ca.ElementPosition + repmat([ranshift 0],Num_x*Num_y,1);
   ca2_shifted.ElementPosition= ca2.ElementPosition + repmat([ranshift2 0],Num_x*Num_y,1);
   figure; show(ca_shifted);
   figure; show(ca2_shifted);
   
   [AF,azi,elv]= feval(EM_solve_function,ca_shifted,fc,azi_grid,elv_grid);
   
   if ~skip_finite_ground
      [AFm,azim,elvm]= feval(EM_solve_function,ca2_shifted,fc,azi_grid,elv_grid);   % microstrip shifted
   end    
   
   figure; P1=polarpattern([elvr elvr+180],[AFr(:,azir==0); flipud(AFr(:,azir==180))], ...
                        [elvc elvc+180],[AFc(:,azic==0); flipud(AFc(:,azic==180))], ...
                        [elv elv+180],[AF(:,azi==0); flipud(AF(:,azi==180))], ...
                        [elvm elvm+180],[AFm(:,azim==0); flipud(AFm(:,azim==180))]);
                    
   P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;  
   set(gcf,'name','Elevation plot for phi=0');
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
   
   figure; P2=polarpattern([elvr elvr+180],[AFr(:,azir==90); flipud(AFr(:,azir==-90))], ...
                        [elvc elvc+180],[AFc(:,azic==90); flipud(AFc(:,azic==-90))], ...
                        [elv elv+180],[AF(:,azi==90); flipud(AF(:,azi==-90))], ...
                        [elvm elvm+180],[AFm(:,azim==90); flipud(AFm(:,azim==-90))]);                    
       
   P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;  
   set(gcf,'name','Elevation plot for phi=90');
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
   
   figure; 
   P3= polarpattern(azir,AFr(elvr==20,:),azic,AFc(elvc==20,:),azi,AF(elv==20,:),azim,AFm(elvm==20,:));
   P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
   set(gcf,'name','Azimuth plot for elevation=20');
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
   
   figure; 
   P4= polarpattern(azir,AFr(elvr==0,:),azic,AFc(elvc==0,:),azi,AF(elv==0,:),azim,AFm(elvm==0,:));
   P4.AngleResolution=30; P4.DrawGridToOrigin= true; P4.LineWidth=2; P4.GridWidth=1.5;  
   set(gcf,'name','Azimuth plot for elevation=0');
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
   
   figure;
   subplot(3,1,1);
   plot([elvr elvr+180],[AFr(:,azir==0); flipud(AFr(:,azir==180))]); hold on;
   plot([elvc elvc+180],[AFc(:,azic==0); flipud(AFc(:,azic==180))],'r');
   plot([elv elv+180],[AF(:,azi==0); flipud(AF(:,azi==180))],'g');
   plot([elvm elvm+180],[AFm(:,azim==0); flipud(AFm(:,azim==180))],'m');
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
    
   subplot(3,1,2);
   plot([elvr elvr+180],[AFr(:,azir==90); flipud(AFr(:,azir==-90))]); hold on;
   plot([elvc elvc+180],[AFc(:,azic==90); flipud(AFc(:,azic==-90))],'r');
   plot([elv elv+180],[AF(:,azi==90); flipud(AF(:,azi==-90))],'g');
   plot([elvm elvm+180],[AFm(:,azim==90); flipud(AFm(:,azim==-90))],'m');  
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
   
   subplot(3,1,3);
   plot(azir,AFr(elvr==0,:)); hold on;
   plot(azic,AFc(elvc==0,:),'r');
   plot(azi,AF(elv==0,:),'g');
   plot(azim,AFm(elvm==0,:),'m');
   legend('rectangular dipole','conformal dipole','shifted dipole','shifted microstrip');
   
   disp('If the arrayFactor is plotted, all plots should coincide');
   disp('Press any key to continue');
   pause;
   
   close all;
end



