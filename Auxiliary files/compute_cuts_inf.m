function [ppsi,Field,vvr,pphir]= compute_cuts_inf(azi_grid,elv_grid,FF,dir,anth,antd,ps)
% SYNTAX: [psi,Field,vvr,pphir]= compute_cuts_inf(azi_grid,elv_grid,FF,dir,anth,antd)
% SUMMARY: this function computes far field data in Cartesian cuts for INFINITE ground plane antennas (see ppt file for exact geometry)
% INPUT ARGUMENT SEMANTICS
% azi_grid: azimuth values for which field has been computed
% elv_grid: elevation values for which field has been computed
% FF: 2D array containing field values (elevation changes vs rows, azimuth vs columns)
% dir: direction of const cut: can be either x,y,z
% anth: antenna height (see ppt file)
% antd: horizontal distance in cut plane (see ppt file)
% ps: character switch indicating whether debugging plots will be displayed
% OUTPUT ARGUMENT SEMANTICS
% ppsi: value of angle in cut plane
% Field: value of directivity in cut plane
% vvr: elevation angle mapping to ppsi value (for debugging purposes only)
% pphir: azimuth angle mapping to ppsi value (for debugging purposes only)
% NOTE1: you MUST make sure that azi_grid, elv_grid are properly specified for FF
% otherwise you will get very subtle logic errors (discontinuous plots etc.)
% NOTE2: currently, FF MUST be squared E-field 


assert(isempty(find(elv_grid<0, 1)));

switch dir
    case 'x'      
       xi= atand(anth/antd);
       ppsi= 0:180;   % ppsi is measured in (z-y) plane starting from y axis
       vv= atand(cosd(xi)./sqrt(sind(xi)^2+cotd(ppsi).^2));   
       fi= find(ppsi<0);
       vv(fi)= -vv(fi); 
   
       pphi= acosd(sind(xi)*sqrt(1+tand(vv).^2));  
       pphi(isnan(pphi))= 0;    % to guard for the case xi=0
       assert(isempty(find(imag(pphi)> 1e-3, 1)));
       fi2= find(cosd(ppsi)<0);
       pphi(fi2)= -pphi(fi2);
       pphi= real(pphi);   
  
       vvr= round(vv);
       pphir= round(pphi);
  
       Field= nan(size(ppsi));
       distance_fix= 10*log10(antd^2/(antd^2+anth^2));
  
       for ii=1:length(ppsi)
          bb= FF(elv_grid==vvr(ii),azi_grid==pphir(ii));
  
          if ~isempty(bb)
             Field(ii)= bb;
          else % interpolate between neighboring values for azi_grid
             Field(ii)= 0.5*( FF(elv_grid==vvr(ii),azi_grid==pphir(ii)-1) + FF(elv_grid==vvr(ii),azi_grid==pphir(ii)+1) );   
          end
  
       end
             
       if (ps=='y')
           figure;
           subplot(2,1,1); plot(ppsi,pphir); title('azimuth vs \psi angle');
           subplot(2,1,2); plot(ppsi,vvr); title('elevation vs \psi angle');
       end
       
       Field= Field+distance_fix;
       
    case 'y'                 
       xi= atand(anth/antd);
       ppsi= 0:180;  % measured in (x,z) plane starting from x axis
       vv= atand(cosd(xi)./sqrt(sind(xi)^2+cotd(ppsi).^2));
       fi= find(ppsi<0);
       vv(fi)= -vv(fi);
   
       if anth==0
          pphi= [repmat(0,[1 90]) 90 repmat(180,[1 90])];
       else
          pphi= sign(anth)*acosd(tand(vv)./tand(ppsi));   
       end
       
       if ~isempty(find(isnan(pphi), 1))   % any NaNs will appear only at psi=0, 90, 180
          if sum(isnan(pphi))==2 
             pphi(isnan(pphi))=[xi sign(xi)*180-xi];
          else
             pphi(isnan(pphi))= [0 90 180]; 
          end
       end
  
       assert(isempty(find(imag(pphi)> 1e-3, 1)));
       pphi= real(pphi);
       Field= nan(size(ppsi));

       vvr= round(vv);
       pphir= round(pphi);
       % have to account for the fact that the non-native plane has different
       % radial distance from origin than native plane
       distance_fix= 10*log10(antd^2/(antd^2+anth^2));
  
       for ii=1:length(ppsi)
          bb= FF(elv_grid==vvr(ii),azi_grid==pphir(ii));
  
          if ~isempty(bb)
             Field(ii)= bb;
          else % interpolate between neighboring values for azi_grid
              
             Field(ii)= 0.5*( FF(elv_grid==vvr(ii),azi_grid==pphir(ii)-1) + FF(elv_grid==vvr(ii),azi_grid==pphir(ii)+1) );                
          end
  
       end 
         
       if (ps=='y')
           figure;
           subplot(2,1,1); plot(ppsi,pphir); title('azimuth vs \psi angle');
           subplot(2,1,2); plot(ppsi,vvr); title('elevation vs \psi angle');
       end       
       
       Field= Field+distance_fix;
       
    case 'z'        
       ppsi= azi_grid;
       Field= nan(size(ppsi));
       vv= repmat(atand(anth/antd),size(ppsi));
  
       pphir= round(azi_grid);
       vvr= round(vv);
       % have to account for the fact that the non-native plane has different
       % radial distance from origin than native plane
       distance_fix= 10*log10(antd^2/(antd^2+anth^2));
  
       for ii=1:length(ppsi)
          bb= FF(elv_grid==vvr(ii),azi_grid==pphir(ii));
  
          if ~isempty(bb)
             Field(ii)= bb;
          else % interpolate between neighboring values for azi_grid
             Field(ii)= 0.5*( FF(elv_grid==vvr(ii),azi_grid==pphir(ii)-1) + FF(elv_grid==vvr(ii),azi_grid==pphir(ii)+1) );   
          end
  
       end
 
       Field= Field+distance_fix;
 
       if (ps=='y')
           figure;
           subplot(2,1,1); plot(ppsi,pphir); title('azimuth vs \psi angle');
           subplot(2,1,2); plot(ppsi,vvr); title('elevation vs \psi angle');
       end
       
    otherwise
      error('Cannot determine cut plane to plot! Aborting');
end


  
  