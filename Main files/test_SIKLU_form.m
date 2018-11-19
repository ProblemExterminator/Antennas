function [pos_vector,mic2,Fel]= test_SIKLU_form(azi_grid,elv_grid)
% INPUT
% azi_grid: the azimuth values where pattern of individual element will be computed
% elv_grid: the elevation values where pattern of individual element will be computed
% OUTPUT
% pos_vector: coordinates of the radiating elements FEED POINTS
% mic2: the radiating element whose individual radiation pattern will be computed
% CRUCIAL NOTE: It is assumed that the array lies on the x-y plane

c= 3e8;
fd= 60e9;
lambda= c/fd;

% horizontant distance between elements and vertical distance between rows
dhor= lambda/2;     
dvert= 1.35*lambda/2;   % this is more than lambda/2, based on the figure in D3.1

mic= design(patchMicrostripCircular,fd);  % finite ground plane

mic2= copy(mic);
mic2.GroundPlaneWidth= inf;  % infinite ground plane

mic3= copy(mic);
mic3.FeedOffset= [-3e-4 0];

% S= sparameters(mic,[57:64]*1e9); 
% S2= sparameters(mic2,[57:64]*1e9); 
% S3= sparameters(mic3,[57:64]*1e9); 
%  
% rfplot(S); title('S11 for finite ground plane');
% figure; rfplot(S2); title('S11 for infinite ground plane');
% figure; rfplot(S3); title('S11 for finite ground plane with different offset');


% R2017b does not allow conformal arrays where more than one elements has
% an infinite ground plane. Will circumvent this with the AF trick (i.e. compute
% pattern without coupling and compare against SIKLU data that includes coupling)

feed_sep= dhor+0.7*abs(mic2.FeedOffset(1));

Numel_row1= 11;
pos_vector1= zeros(Numel_row1,3);
pos_vector1(:,1)= (0:Numel_row1-1)*feed_sep;

Numel_row2= 10;
row_inset= feed_sep/2;   % amount by which second row will be inset relative to first row w.r.t x axis
pos_vector2= zeros(Numel_row2,3);
pos_vector2(:,1)= (0:Numel_row2-1)*feed_sep + row_inset;
pos_vector2(:,2)= repmat(dvert,Numel_row2,1);

Numel_row3= 11;
pos_vector3= zeros(Numel_row3,3);
pos_vector3(:,1)= (0:Numel_row3-1)*feed_sep;
pos_vector3(:,2)= repmat(2*dvert,Numel_row3,1);

pos_vector= [pos_vector1; pos_vector2; pos_vector3];

% CRUCIAL: you must use 'feed' for the Reference so that you can output the
% feedpoint positions
arr= conformalArray('Element',mic,'ElementPosition',pos_vector,'Reference','feed');
show(arr);

figure; layout(arr);

% we next compute the E field of the individual antenna elemen
% For now I will use an infinite ground plane microstrip but in principle
% SIKLU could provide a table showing values for Fel (Directivity values
% but I can convert them to |E| field)
[Fel,~,~]= pattern(mic2,fd,azi_grid,elv_grid,'Type','efield'); 



