function [D,Prad]=Efield2dir(F,azi,elv)
% this function computes the directivity that corresponds to given field values.
% Typically, F is computed from pattern(...,'Type','efield'); 
% INPUT SEMANTICS:
% F: 2D array containining |E| values (in linear scale)
% azi: azimuth values
% elv: elevation values
% OUTPUT SEMANTICS:
% D: directivity (in dB scale)
% Prad: radiated power (implicitly depends on actual scale of F)

dth= (elv(end)-elv(1))/(length(elv)-1)*pi/180;  % convert to radians
dphi= (azi(end)-azi(1))/(length(azi)-1)*pi/180; % convert to radians

Ftt= F.^2;   % need |E|^2 for radiation intensity U (check Balanis)
Prad=0;

for ind=1:length(azi)
    Prad= Prad+ dot(Ftt(:,ind),cosd(elv))*dth*dphi;
end

D= 10*log10(Ftt*4*pi/Prad);  % this is the directivity computed from e-field
