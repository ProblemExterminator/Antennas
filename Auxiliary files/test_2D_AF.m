% this script file examines whether we can treat a 2D antenna array as an array of 1D arrays and 
% compares different ways of finding the patterns of 2D arrays
close all;
clear variables;

c= 3e8;
fc= 60e9;
lambda= c/fc;

d= design(dipole,fc);
el= design(patchMicrostripCircular,fc);

el2= copy(el);    % el2 has infinite ground plane to limit memory requirements and computation time
el2.GroundPlaneWidth= inf;

xsep= 1.25*lambda/2;
ysep= 1.25*lambda/2;
Numx= 3;   % number of elements along x axis
Numy= 4;   % number of elements along y axis

% finite ground plane
ra= rectangularArray('Element',el,'Size',[Numy Numx],'RowSpacing',ysep,'ColumnSpacing',xsep);
la= linearArray('Element',el,'NumElements',Numy,'ElementSpacing',ysep,'TiltAxis',[0 0 1],'Tilt',90);

% infinite ground plane 
ra2= rectangularArray('Element',el2,'Size',[Numy Numx],'RowSpacing',ysep,'ColumnSpacing',xsep);
la2= linearArray('Element',el2,'NumElements',Numy,'ElementSpacing',ysep,'TiltAxis',[0 0 1],'Tilt',90);

% this is the second linear array, whose AF will be used to treat rectangularArray as linear array
% of linear arrays
new_la= linearArray('Element',el,'NumElements',Numx,'ElementSpacing',xsep);
new_la2= linearArray('Element',el2,'NumElements',Numx,'ElementSpacing',xsep);

show(la2); 
figure(2); show(new_la2); 
figure(3); show(ra2); 

memf_need= memoryEstimate(ra,fc);
memi_need= memoryEstimate(ra2,fc);
mem_avail= memory;
mem_avail= mem_avail.MemAvailableAllArrays;
sf= split(string(memf_need));
szf= str2double(convertStringsToChars(sf(1)));
si= split(string(memi_need));
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

rr= input('Although you have sufficient memory, do you want to run only infinite ground plane geometries?(y/n)','s');

if rr=='y'
   skip_finite_ground= true;
end

azi_grid= -180:2:180;

if ~skip_finite_ground
   elv_grid= -90:90;
   [AF,azi,elv]=arrayFactor(la,fc,azi_grid,elv_grid);
   [AF_2D,azi_2D,elv_2D]= arrayFactor(ra,fc,azi_grid,elv_grid);
   [Fi,azii,elvi]= pattern(new_la,fc,azi_grid,elv_grid,'Type','efield');
   [Fr,azir,elvr]= patternMultiply(ra,fc,azi_grid,elv_grid);
   [Fc,azic,elvc]= pattern(ra,fc,azi_grid,elv_grid);
   [Fel,azil,elvl]= pattern(el,fc,azi_grid,elv_grid,'Type','efield');
else
   elv_grid= 0:90;
   [AF,azi,elv]=arrayFactor(la2,fc,azi_grid,elv_grid);
   [AF_2D,azi_2D,elv_2D]= arrayFactor(ra2,fc,azi_grid,elv_grid);
   [Fi,azii,elvi]= pattern(new_la2,fc,azi_grid,elv_grid,'Type','efield');
   [Fc,azic,elvc]= pattern(ra2,fc,azi_grid,elv_grid);   
   [Fel,azil,elvl]= pattern(el2,fc,azi_grid,elv_grid,'Type','efield');
end    

Ftt= Fi.*10.^(AF/10);  % this is proportional to |E|
assert(isempty(find(Ftt<0, 1)));
Ftt= Ftt.^2;   % need |E|^2 for radiation intensity U (check Balanis)
 
Ftt_2D= Fel.*10.^(AF_2D/10);  
assert(isempty(find(Ftt_2D<0, 1)));
Ftt_2D= Ftt_2D.^2;   

dth= (elv_grid(end)-elv_grid(1))/(length(elv_grid)-1)*pi/180;  % convert to radians
dphi= (azi_grid(end)-azi_grid(1))/(length(azi_grid)-1)*pi/180; % convert to radians
   
Prad=0;
Prad_2D=0;

for ind=1:length(azi_grid)
   Prad= Prad+ dot(Ftt(:,ind),cosd(elv_grid))*dth*dphi;
   Prad_2D= Prad_2D+ dot(Ftt_2D(:,ind),cosd(elv_grid))*dth*dphi;
end
   
if ~skip_finite_ground
   plot_increment= 180;
else
   plot_increment= 90;
end

Ft= 10*log10(Ftt*4*pi/Prad);  
Ft_2D= 10*log10(Ftt_2D*4*pi/Prad_2D);  
warning('OFF','MATLAB:legend:IgnoringExtraEntries');

figure; set(gcf,'name','Elevation plot for phi=0');

if ~skip_finite_ground
   P1=polarpattern([elvc elvc+plot_increment], [Fc(:,azic==0); flipud(Fc(:,azic==180))], ...
                   [elvr elvr+plot_increment], [Fr(:,azic==0); flipud(Fr(:,azic==180))], ...         
                   [elvc elvc+plot_increment], [Ft(:,azic==0); flipud(Ft(:,azic==180))], ...
                   [elv_2D elv_2D+plot_increment], [Ft_2D(:,azi_2D==0); flipud(Ft_2D(:,azi_2D==180))]);        
else
   P1=polarpattern([elvc elvc+plot_increment], [Fc(:,azic==0); flipud(Fc(:,azic==180))], ...                        
                   [elvc elvc+plot_increment], [Ft(:,azic==0); flipud(Ft(:,azic==180))], ...
                   [elv_2D elv_2D+plot_increment], [Ft_2D(:,azi_2D==0); flipud(Ft_2D(:,azi_2D==180))]);                   
end

P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;        

if ~skip_finite_ground
  legend('full pattern (full coupling)','multiplied pattern (no coupling)', ...
         'array of arrays (partial coupling)','AF 2D array (no coupling)');
else
  legend('full pattern (full coupling)','array of arrays (partial coupling)',' AF 2D array (no coupling)');
end    

figure; set(gcf,'name','Elevation plot for phi=90');

if ~skip_finite_ground
    P2=polarpattern([elvc elvc+plot_increment], [Fc(:,azic==90); flipud(Fc(:,azic==-90))], ...
                    [elvr elvr+plot_increment], [Fr(:,azic==90); flipud(Fr(:,azic==-90))], ...         
                    [elvc elvc+plot_increment], [Ft(:,azic==90); flipud(Ft(:,azic==-90))], ...
                    [elv_2D elv_2D+plot_increment], [Ft_2D(:,azi_2D==90); flipud(Ft_2D(:,azi_2D==-90))]);                
else
    P2=polarpattern([elvc elvc+plot_increment], [Fc(:,azic==90); flipud(Fc(:,azic==-90))], ...                     
                    [elvc elvc+plot_increment], [Ft(:,azic==90); flipud(Ft(:,azic==-90))], ...
                    [elv_2D elv_2D+plot_increment], [Ft_2D(:,azi_2D==90); flipud(Ft_2D(:,azi_2D==-90))]); 
end
            
P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;

if ~skip_finite_ground
  legend('full pattern (full coupling)','multiplied pattern (no coupling)', ...
         'array of arrays (partial coupling)','AF 2D array (no coupling)');
else
  legend('full pattern (full coupling)','array of arrays (partial coupling)','AF 2D array (no coupling)');
end 


figure; set(gcf,'name','Azimuth plot for elv=20');
if ~skip_finite_ground
    P3= polarpattern(azic,Fc(elvc==20,:),azir,Fr(elvc==20,:),azic,Ft(elvc==20,:),azi_2D,Ft_2D(elv_2D==20,:));
else
    P3= polarpattern(azic,Fc(elvc==20,:),azic,Ft(elvc==20,:),azi_2D,Ft_2D(elv_2D==20,:));
end

P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
       
if ~skip_finite_ground
  legend('full pattern (full coupling)','multiplied pattern (no coupling)', ...
         'array of arrays (partial coupling)','AF 2D array (no coupling)');
else
  legend('full pattern (full coupling)','array of arrays (partial coupling)','AF 2D array (no coupling)');
end 

