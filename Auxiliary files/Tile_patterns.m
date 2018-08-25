close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;
show_only='y';


el= design(patchMicrostripCircular,fc);
el2= copy(el);    % el2 has infinite ground plane to limit memory requirements and computation time
el2.GroundPlaneWidth= inf;

plot_type= 'efield';
assert( strcmp(plot_type,'efield') || strcmp(plot_type,'directivity') );

% these are the Tile PCB parameters ONLY
Tile_xsep= 1.25*lambda/2;
Tile_ysep= 1.25*lambda/2;
Tile_Numx= 2;   % number of elements along x axis
Tile_Numy= 3;   % number of elements along y axis

% finite ground plane
Tile= rectangularArray('Element',el,'Size',[Tile_Numy Tile_Numx],'RowSpacing',Tile_ysep,'ColumnSpacing',Tile_xsep);

% infinite ground plane 
Tile2= rectangularArray('Element',el2,'Size',[Tile_Numy Tile_Numx],'RowSpacing',Tile_ysep,'ColumnSpacing',Tile_xsep);

if (show_only=='y')
   show(Tile);
   figure; show(Tile2);
   return;
end

memf_need= memoryEstimate(Tile,fc);
memi_need= memoryEstimate(Tile2,fc);
mem_avail= memory;
mem_avail= mem_avail.MemAvailableAllArrays;
sf= split(string(memf_need));
szf= str2double(convertStringsToChars(sf(1)));
si= split(string(memi_need));
szi= str2double(convertStringsToChars(si(1)));

skip_finite_ground= false;

fprintf(1,'Memory required for solving microstrip antenna with finite ground plane: %s\n',memf_need);
fprintf(1,'Memory required for solving microstrip antenna with infinite ground plane: %s\n',memi_need);

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

tic;
azi_grid= -180:180;

if ~skip_finite_ground
  elv_grid= -90:90;
else
  elv_grid= 0:90; % only half for infinite ground plane  
end    

% element numbering within Tile is performed columnwise, i.e along y axis first
% phases in rectangularArray are specified in degrees
phase_x= [0 90 180 270];
phase_y= [0 90 180 270];
RF_phase= zeros(Tile_Numy,Tile_Numx);

fprintf(1,'Number of instances to run: %d\n',length(phase_y)*length(phase_x));

num_inst=0;
auxl= length(phase_y)*length(phase_x);

if strcmp(plot_type,'directivity')
  S2= struct('px',nan(1,auxl),'py',nan(1,auxl),'RF_phase',nan(Tile_Numy,Tile_Numx,auxl), ...
             'pat',nan(length(elv_grid),length(azi_grid),auxl));
else
  S2= struct('px',nan(1,auxl),'py',nan(1,auxl),'RF_phase',nan(Tile_Numy,Tile_Numx,auxl), ...
             'efield',nan(length(elv_grid),length(azi_grid),auxl));  
end
       
for py= 1:length(phase_y)
  for px= 1:length(phase_x)
     if num_inst==0
       first_start= tic;
     end
     
     for x=1:Tile_Numx
        RF_phase(:,x)= phase_y(py)*(1:Tile_Numy)'+x*phase_x(px);   
     end
     
     RF_phase= mod(RF_phase,360);   % take module 360 degrees just to make sure phases are still valid
     assert(isempty(find(mod(RF_phase,45)~=0, 1)));
     S2.RF_phase(:,:,num_inst+1)= RF_phase;
     S2.px(num_inst+1)= phase_x(px);
     S2.py(num_inst+1)= phase_y(py);
     Tile.PhaseShift= RF_phase(:); 
     Tile2.PhaseShift= RF_phase(:);
     
     %disp('Using phase distribution:');
     %RF_phase(:),
     fprintf(1,'Running instance: %d\n',num_inst+1);
     
     % compute field for single Tile or Tile2 only
     if ~skip_finite_ground
        [F_Tile,azi_Tile,elv_Tile]= pattern(Tile,fc,azi_grid,elv_grid,'Type',plot_type);  
     else
        [F_Tile,azi_Tile,elv_Tile]= pattern(Tile2,fc,azi_grid,elv_grid,'Type',plot_type);         
     end    

     if strcmp(plot_type,'directivity')
        S2.pat(:,:,num_inst+1)= F_Tile;
     else
        S2.efield(:,:,num_inst+1)= F_Tile;
     end
     
     if num_inst==0 
        first_round= toc(first_start);
        fprintf(1,'First instance completion time (seconds): %d\n',first_round);   
        fprintf(1,'Number of instances to run: %d\n',length(phase_x)*length(phase_y));       
        fprintf(1,'Estimated processing time (seconds): %d\n',first_round*length(phase_x)*length(phase_y));       
     end
     
     num_inst= num_inst+1;
     
     
     %{
     if ~skip_finite_ground
        figure; set(gcf,'name','Elevation plot for phi=0');
        P1=polarpattern([elv_Tile elv_Tile+180], [F_Tile(:,find(azi_Tile==0)); flipud(F_Tile(:,find(azi_Tile==180)))]);               
        P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;        

        figure; set(gcf,'name','Elevation plot for phi=90');
        P2=polarpattern([elv_Tile elv_Tile+180], [F_Tile(:,find(azi_Tile==90)); flipud(F_Tile(:,find(azi_Tile==-90)))]);
        P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;        

        figure; set(gcf,'name','Azimuth plot for elv=20');
        P3= polarpattern(azi_Tile,F_Tile(find(elv_Tile==20),:));
        P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;  
     else
        figure; set(gcf,'name','Elevation plot for phi=0');
        P1=polarpattern([elv_Tile elv_Tile+90], [F_Tile(:,find(azi_Tile==0)); flipud(F_Tile(:,find(azi_Tile==180)))]);               
        P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;        

        figure; set(gcf,'name','Elevation plot for phi=90');
        P2=polarpattern([elv_Tile elv_Tile+90], [F_Tile(:,find(azi_Tile==90)); flipud(F_Tile(:,find(azi_Tile==-90)))]);
        P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;        

        figure; set(gcf,'name','Azimuth plot for elv=20');
        P3= polarpattern(azi_Tile,F_Tile(find(elv_Tile==20),:));
        P3.AngleResolution=30; P3.DrawGridToOrigin= true; P3.LineWidth=2; P3.GridWidth=1.5;     
     end    
     
     pause(1);
     close all;
     %}
  end
end

toc,

savefile= datestr(now,30);
savefile= strcat('Tile_data_',savefile,'.mat');
save(savefile,'el','el2','Tile_xsep','Tile_ysep','Tile_Numx','Tile_Numy','Tile','Tile2', ...
              'azi_grid','elv_grid','phase_x','phase_y','S2');

