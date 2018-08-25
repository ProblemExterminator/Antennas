% this script verifies that elevation angles > 90 are NOT needed when computing patterns
% for antennas that radiate in a half-plane
close all;
clearvars;

c= 3e8;
fc= 60e9;
lambda= c/fc;

el= design(patchMicrostripCircular,fc);
show(el);

el2= copy(el);
el2.GroundPlaneWidth= inf;  % infinite ground plane to reduce memory and time

xsep= 1.5*lambda/2;
ysep= 1.5*lambda/2;
Numx= 2;
Numy= 3;

ra= rectangularArray('Element',el,'Size',[Numx Numy],'RowSpacing',ysep,'ColumnSpacing',xsep);
ra2= rectangularArray('Element',el2,'Size',[Numx Numy],'RowSpacing',ysep,'ColumnSpacing',xsep);

memf_need= memoryEstimate(ra,fc);
memi_need= memoryEstimate(ra2,fc);
mem_avail= memory;
mem_avail= mem_avail.MemAvailableAllArrays;

fprintf('Memory required for solving antenna with finite ground plane: %s\n',memf_need);
fprintf('Memory required for solving antenna with infinite ground plane: %s\n',memi_need);

s= split(string(memi_need));
sz= str2double(convertStringsToChars(s(1)));

if strcmpi(s(2),"GB") && (sz> mem_avail*1e-9)
    error('Insufficient memory for solving finite ground plane. Skipping computation');    
elseif (strcmpi(s(2),"MB")) && (sz> mem_avail*1e-6)
    error('Insufficient memory for solving finite ground plane. Skipping computation');    
elseif (~strcmpi(s(2),"MB")) && (~strcmpi(s(2),"GB"))
    error('Don''t know how to continue. Skipping computation');    
end

figure; show(ra2);

tic,
% validate that there is no need to compute field beyond infinite ground plane
% WARNING: DON'T change the values of the1, the2, pphi as the test depends crucially on them
the1= 0:2:180;
the2= 0:90;
pphi= -180:2:180;

[F1,azi1,elv1]= pattern(ra2,fc,-180:2:180,the1);
[F2,azi2,elv2]= pattern(ra2,fc,-180:2:180,the2);
toc,

figure(3);
patternCustom(F1',elv1,azi1,'Slice','phi','SliceValue',0);

logical_ind1= ismember(the1,the2);  % this index shows which rows of F1 to use for comparison with F2
logical_ind2= ismember(the2,the1);  % this index shows which rows of F2 to use for comparison with F1

dF= F1(logical_ind1,:)- F2(logical_ind2,:);
assert( isequal(dF, zeros(size(dF))) );   % since they are based on the same calculation, results should be identical

ext_the= the1(the1>90);
ext_new= 180-ext_the;   % get antipodal point w.r.t. elevation
AA= F1(the1>90,:);

ext_new= fliplr(ext_new);  AA= flipud(AA);   % need to flip arrays because we want ext_new values to increase
% each row of AA now has the same elevation as appears in the index of ext_new

N= 90;
pphi2= zeros(size(pphi));
pphi2(pphi<=0)= pphi(pphi<=0)+180;
pphi2(pphi>0)= pphi(pphi>0)-180;

new_phi_ind= [92:181 2:91];
BB= nan(size(AA,1), size(AA,2)-1);

for ii=1:size(AA,1)
    BB(ii,:)= AA(ii,new_phi_ind);
end

CC= F2;
CC(:,1)= [];  % throw away first column of CC (i.e. F2) which contains phi value of -180

% need to compare matching values of CC and BB
logical_ind3= ismember(ext_new,the2);  % this index shows which rows of BB to use for comparison with CC
logical_ind4= ismember(the2,ext_new);  % this index shows which rows of CC to use for comparison with BB

ddF= BB(logical_ind3,:)-CC(logical_ind4,:);

% if following assertion passes, it means that values of elevation > 90
% give the same results as values of elevation < 90 with antipodal phi
fprintf(1,['If values of elevation>90 give the same results as <90 with antipodal azimuth, ' ...
          'the number in this line should be 1: %d\n'],isequal(ddF, zeros(size(ddF))));

