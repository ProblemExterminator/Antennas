% this script compares the basic AF+individual element trick vs the Matlab-computed 
% solutions for rectangular arrays
close all;
clear variables;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(patchMicrostripCircular,fc);
el2= copy(el);
el2.GroundPlaneWidth= inf;
show(el);

Num_x= 2;
Num_y= 3;
dx= 3*lambda/4;
dy= lambda;


ra= rectangularArray('Element',el,'Size',[Num_y Num_x],'RowSpacing',dy,'ColumnSpacing',dx);
ra2= rectangularArray('Element',el2,'Size',[Num_y Num_x],'RowSpacing',dy,'ColumnSpacing',dx);
figure; show(ra);

memf_need= memoryEstimate(ra,fc);
memi_need= memoryEstimate(ra2,fc);
mem_avail= memory;
mem_avail= mem_avail.MemAvailableAllArrays;
sf= split(string(memf_need));
si= split(string(memi_need));
szf= str2double(convertStringsToChars(sf(1)));
szi= str2double(convertStringsToChars(si(1)));
skip_finite_ground= false;

fprintf('Memory required for solving microstrip antenna with finite ground plane: %s\n',memf_need);
fprintf('Memory required for solving microstrip antenna with infinite ground plane: %s\n',memi_need);

if strcmpi(sf(2),"GB") && (szf> mem_avail*1e-9)
    disp('Insufficient memory for solving finite ground plane. Skipping computation');
    skip_finite_ground= true;
elseif (strcmpi(sf(2),"MB")) && (szf> mem_avail*1e-6)
    disp('Insufficient memory for solving finite ground plane. Skipping computation');
    skip_finite_ground= true;
elseif (~strcmpi(sf(2),"MB")) && (~strcmpi(sf(2),"GB"))
    error('Don''t know how to continue. Skipping computation');    
end

azi_grid= -180:2:180; 


if ~skip_finite_ground
  elv_grid= -90:90;
else
  elv_grid= 0:90;  
end

plot_type= 'directivity';

% CAUTION: AF is always computed in dB by arrayFactor
if ~skip_finite_ground
   [AF,azi,elv]= arrayFactor(ra,fc,azi_grid,elv_grid); 
   [Fs,azis,elvs]= patternMultiply(ra,fc,azi_grid,elv_grid,'Type',plot_type);
   [Fc,azic,elvc]= pattern(ra,fc,azi_grid,elv_grid,'Type',plot_type);
else
   [AF,azi,elv]= arrayFactor(ra2,fc,azi_grid,elv_grid);    
   [Fc,azic,elvc]= pattern(ra2,fc,azi_grid,elv_grid,'Type',plot_type);
end    

[Fi,azii,elvi]= pattern(el,fc,azi_grid,elv_grid,'Type','efield');  
Ftt= Fi.*10.^(AF/10);  % this is proportional to |E|
assert(isempty(find(Ftt<0, 1)));
Ftt= Ftt.^2;   % need |E|^2 for radiation intensity U (check Balanis)
 
dth= (elv_grid(end)-elv_grid(1))/(length(elv_grid)-1)*pi/180;  % convert to radians
dphi= (azi_grid(end)-azi_grid(1))/(length(azi_grid)-1)*pi/180; % convert to radians
   
Prad=0;
for ind=1:length(azi_grid)
   Prad= Prad+ dot(Ftt(:,ind),cosd(elv_grid))*dth*dphi;
end
   
Ft= 10*log10(Ftt*4*pi/Prad);  % keep the name Ft so that plotting commands don't change

if ~skip_finite_ground
   figure; set(gcf,'name','Elevation plot for phi=0');
   P1=polarpattern([elvc elvc+180], [Fc(:,azic==0); flipud(Fc(:,azic==180))], ...
                   [elvs elvs+180], [Fs(:,azis==0); flipud(Fs(:,azis==180))], ...
                   [elvi elvi+180], [Ft(:,azii==0); flipud(Ft(:,azii==180))]);        
            
   P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;        
   legend('full pattern','patternMultiply (no coupling)','pattern (AF+ind)');

   figure; set(gcf,'name','Elevation plot for phi=90');
   P2=polarpattern([elvc elvc+180], [Fc(:,azic==90); flipud(Fc(:,azic==-90))], ...
                   [elvs elvs+180], [Fs(:,azis==90); flipud(Fs(:,azis==-90))], ...
                   [elvi elvi+180], [Ft(:,azii==90); flipud(Ft(:,azii==-90))]);

   P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;        
   legend('full pattern','patternMultiply (no coupling)','pattern (AF+ind)');

   figure; set(gcf,'name','Azimuth plot for elv=20');
   P3= polarpattern(azic,Fc(elvc==20,:),azis,Fs(elvs==20,:),azii,Ft(elvi==20,:));
   P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
   legend('full pattern','patternMultiply (no coupling)','pattern (AF+ind)');

   figure; 
   plot([elvc elvc+180], [Fc(:,azic==0); flipud(Fc(:,azic==180))],'Linewidth',2); hold on;
   plot([elvs elvs+180], [Fs(:,azis==0); flipud(Fs(:,azis==180))],'Linewidth',2,'Color','r');
   plot([elvi elvi+180], [Ft(:,azii==0); flipud(Ft(:,azii==180))],'Linewidth',2,'Color','g'); 
   ylim= get(gca,'ylim'); set(gca,'ylim',[ylim(2)-30 ylim(2)]);
   title('Elevation plane for phi=0');
   legend('full pattern','patternMultiply (no coupling)','pattern (AF+ind)');

   figure; 
   plot([elvc elvc+180], [Fc(:,azic==90); flipud(Fc(:,azic==-90))],'Linewidth',2); hold on;
   plot([elvs elvs+180], [Fs(:,azis==90); flipud(Fs(:,azis==-90))],'Linewidth',2,'Color','r');
   plot([elvi elvi+180], [Ft(:,azii==90); flipud(Ft(:,azii==-90))],'Linewidth',2,'Color','g'); 
   ylim= get(gca,'ylim'); set(gca,'ylim',[ylim(2)-30 ylim(2)]);
   title('Elevation plane for phi=90'); 
   legend('full pattern','patternMultiply (no coupling)','pattern (AF+ind)');

   figure;
   plot(azic,Fc(elvc==20,:),'Linewidth',2); hold on;
   plot(azis,Fs(elvs==20,:),'Linewidth',2,'Color','r');
   plot(azii,Ft(elvi==20,:),'Linewidth',2,'Color','g');
   ylim= get(gca,'ylim'); set(gca,'ylim',[ylim(2)-30 ylim(2)]);
   legend('full pattern','patternMultiply (no coupling)','pattern (AF+ind)');

   figure; plot(abs(Fs(:)-Ft(:)));
else
   figure; set(gcf,'name','Elevation plot for phi=0');
   P1=polarpattern([elvc elvc+90], [Fc(:,azic==0); flipud(Fc(:,azic==180))], ...                  
                   [elvi elvi+90], [Ft(:,azii==0); flipud(Ft(:,azii==180))]);        
            
   P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;        
   legend('full pattern','pattern (AF+ind)');

   figure; set(gcf,'name','Elevation plot for phi=90');
   P2=polarpattern([elvc elvc+90], [Fc(:,azic==90); flipud(Fc(:,azic==-90))], ...                   
                   [elvi elvi+90], [Ft(:,azii==90); flipud(Ft(:,azii==-90))]);

   P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;        
   legend('full pattern','pattern (AF+ind)');

   figure; set(gcf,'name','Azimuth plot for elv=20');
   P3= polarpattern(azic,Fc(elvc==20,:),azii,Ft(elvi==20,:));
   P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
   legend('full pattern','pattern (AF+ind)');

   figure; 
   plot([elvc elvc+90], [Fc(:,azic==0); flipud(Fc(:,azic==180))],'Linewidth',2); hold on;   
   plot([elvi elvi+90], [Ft(:,azii==0); flipud(Ft(:,azii==180))],'Linewidth',2,'Color','r'); 
   ylim= get(gca,'ylim'); set(gca,'ylim',[ylim(2)-30 ylim(2)]);
   title('Elevation plane for phi=0');
   legend('full pattern','pattern (AF+ind)');

   figure; 
   plot([elvc elvc+90], [Fc(:,azic==90); flipud(Fc(:,azic==-90))],'Linewidth',2); hold on; 
   plot([elvi elvi+90], [Ft(:,azii==90); flipud(Ft(:,azii==-90))],'Linewidth',2,'Color','r'); 
   ylim= get(gca,'ylim'); set(gca,'ylim',[ylim(2)-30 ylim(2)]);
   title('Elevation plane for phi=90'); 
   legend('full pattern','pattern (AF+ind)');

   figure;
   plot(azic,Fc(elvc==20,:),'Linewidth',2); hold on;
   plot(azii,Ft(elvi==20,:),'Linewidth',2,'Color','r');
   ylim= get(gca,'ylim'); set(gca,'ylim',[ylim(2)-30 ylim(2)]);
   legend('full pattern','pattern (AF+ind)');

end    

