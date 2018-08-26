close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;
show_only='n';

el= design(patchMicrostripCircular,fc);
el2= copy(el);    % el2 has infinite ground plane to limit memory requirements and computation time
el2.GroundPlaneWidth= inf;

% these are the Tile PCB parameters ONLY
Tile_xsep= 1.25*lambda/2;
Tile_ysep= 1.25*lambda/2;
Tile_Numx= 3;   % number of elements along x axis
Tile_Numy= 4;   % number of elements along y axis

% 2D tiles only used to verify no overlapping
Tile= rectangularArray('Element',el,'Size',[Tile_Numy Tile_Numx],'RowSpacing',Tile_ysep,'ColumnSpacing',Tile_xsep);
Tile2= rectangularArray('Element',el2,'Size',[Tile_Numy Tile_Numx],'RowSpacing',Tile_ysep,'ColumnSpacing',Tile_xsep);

if (show_only=='y')
   show(Tile);
   figure; show(Tile2);   % visually determine that there is no overlapping
   return;
end

% 1D array in x direction with finite ground plane
Arr_x= linearArray('Element',el,'NumElements',Tile_Numx,'ElementSpacing',Tile_xsep);

% 1D array in x direction with infinite ground plane
Arr2_x= linearArray('Element',el2,'NumElements',Tile_Numx,'ElementSpacing',Tile_xsep);

tic;

memf_need= memoryEstimate(el,fc);
memi_need= memoryEstimate(el2,fc);
mem_avail= memory;
mem_avail= mem_avail.MemAvailableAllArrays;
sf= split(string(memf_need));
szf= str2double(convertStringsToChars(sf(1)));
si= split(string(memi_need));
szi= str2double(convertStringsToChars(si(1)));

skip_finite_ground= true;

fprintf(1,'Memory required for solving single microstrip antenna with finite ground plane: %s\n',memf_need);
fprintf(1,'Memory required for solving single microstrip antenna with infinite ground plane: %s\n',memi_need);

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

% run individual element once and store to use later with AF

if skip_finite_ground
   [Fi,azii,elvi]= pattern(el2,fc,azi_grid,elv_grid,'type','efield');
else
   [Fi,azii,elvi]= pattern(el,fc,azi_grid,elv_grid,'type','efield');
end


phase_x= [nan 0 90 180 270];   % nan indicates deactivated element
num_inst= length(phase_x)^Tile_Numx;

% it is easier to treat the id of each index as a number in the base system of size
% equal to phase_x
ids= dec2base(1:num_inst-1,length(phase_x),Tile_Numx);

phase_conf= repmat(-1,size(ids));   % use -1 as sentinel value to be overwritten

for ii=1:size(ids,1)
   tt= split(ids(ii,:),'');  % split on boundary, NOT on space
   tt([1 length(tt)])= [];   % remove first and last elements of cell since they are empty
   
   % tt now contains respective configuration for each element
   phase_conf(ii,:)= str2num(cell2mat(tt))';
   phase_conf(ii,:)= phase_x(1+phase_conf(ii,:));   % remember: indexing starts at 1
end

assert(isempty(find(phase_conf==1, 1)));
% at this point phase_conf contains all information needed. We must now
% construct the phase and amplitude distributions from it

% cell array has 5 columns of the form:
% phase_conf | Amplitude Taper | Phase Shift | AF | Array_x Directivity pattern (AF-based) 
%   | Array_x Directivity pattern
CC= cell(size(phase_conf,1), 6);

return;

%for ii=1:size(phase_conf,1)
for ii=5:12
   CC{ii,1}= phase_conf(ii,:);
   Amp= ones(1,Tile_Numx);
   Pha= CC{ii,1};
   Amp(isnan(CC{ii,1}))=0;   % deactivate elements with nan phase
   Pha(isnan(Pha))= 0;       % any deactivated elements can have arbitrary phase (say, 0)
   
   CC{ii,2}= Amp;
   CC{ii,3}= Pha;     
   
   % find AF of linear x-array
   Arr_x.AmplitudeTaper= Amp;
   Arr_x.PhaseShift= Pha;
   
   Arr2_x.AmplitudeTaper= Amp;
   Arr2_x.PhaseShift= Pha;
   
   if skip_finite_ground
      [CC{ii,4},azi,elv]= arrayFactor(Arr2_x,fc,azi_grid,elv_grid);
   else
      [CC{ii,4},azi,elv]= arrayFactor(Arr_x,fc,azi_grid,elv_grid);
   end
   
   
   Ftt= Fi.*10.^(CC{ii,4}/10);  % this is where the magic happens!
   assert(isempty(find(Ftt<0, 1)));
   
   Ft= Efield2dir(Ftt,azi_grid,elv_grid);  % this is the directivity for the entire x array
      
   CC{ii,5}= Ft;
   
   if skip_finite_ground
       [CC{ii,6},azi,elv]= pattern(Arr2_x,fc,azi_grid,elv_grid);
   else
       [CC{ii,6},azi,elv]= pattern(Arr_x,fc,azi_grid,elv_grid);
   end
      
end   
   
toc,


return;

Nfig= 3;
global_inst=1;
      
for iplot=1:Nfig  
   local_inst=1;
   
   figure;
   for jj=1:4
        subplot(4,3,local_inst);   
        plot([elv elv+90], [CC{global_inst,5}(:,azi==0); flipud(CC{global_inst,5}(:,azi==180))], ...                   
              [elv elv+90], [CC{global_inst,6}(:,azi==0); flipud(CC{global_inst,6}(:,azi==180))],'Linewidth',2);        
        title(gca,'Elevation pattern at phi=0');  
        legend('AF-based pattern','full pattern','Location','Best');
        local_inst= local_inst+1;
        
        subplot(4,3,local_inst);    
        plot([elv elv+90], [CC{global_inst,5}(:,azi==90); flipud(CC{global_inst,5}(:,azi==-90))], ...         
             [elv elv+90], [CC{global_inst,6}(:,azi==90); flipud(CC{global_inst,6}(:,azi==-90))],'Linewidth',2);
        title('Elevation pattern at phi=90');  
        legend('AF-based pattern','full pattern','Location','Best');
        local_inst= local_inst+1;
        
        subplot(4,3,local_inst);
        plot(azi,CC{global_inst,5}(elv==0,:),azi,CC{global_inst,6}(elv==0,:),'Linewidth',2);
        title('Azimuth pattern at elv=0');  
        legend('AF-based pattern','full pattern','Location','Best');
        local_inst= local_inst+1;
        
        global_inst= global_inst+1;
   end
   
    %{
   for jj=1:4
      subplot(2,2,jj); surf(CC{inst,5}-CC{inst,6}); view(2); shading flat; colorbar;
      title(gca,sprintf('Instance number: %d',inst));
      inst= inst+1;
   end
   %}
end    
   

    


