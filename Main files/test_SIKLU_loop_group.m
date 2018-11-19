function [Output_pattern,Amplitude_cell,Phase_cell,Description]= test_SIKLU_loop_group(azi_grid,elv_grid)

fd= 60e9;

d= design(dipole,fd);

% we now find the feed points for each element and the individual element
% pattern (E field)
[pos_vector,real_el,Fel]= test_SIKLU_form(azi_grid,elv_grid);   

% since we will only compute AF of arr, we can use any element of our choice, say dipole
arr= conformalArray('Element',d,'Reference','feed','ElementPosition',pos_vector);

show(arr);
figure;  layout(arr);


% create multiple AmplitudeTape and PhaseShift profiles as cell arrays that
% map to struct fields, run them and store results in another cell array for 
% subsequent processing
Srow_nosteer= struct;
Srow_nosteer.Des= { 'top full', 'mid full','bottom full','bottow 6 spread','bottow 5 spread', ...
  'bottom 4 tight','bottom 6 tight','bottom 8 tight' };
    
% to index cell array by name: string(Srow_nosteer.Des)== "mid full"
Srow_nosteer.Amp= { [zeros(1,11) zeros(1,10) ones(1,11)], ...      % top row full
    [zeros(1,11) ones(1,10) zeros(1,11)], ...      % middle row full
    [ones(1,11) zeros(1,10), zeros(1,11)], ...     % bottom row full
    [ [repmat([1 0],1,5) 1] zeros(1,10) zeros(1,11) ], ...  % bottom row energize 6 spread
    [ [repmat([0 1],1,5) 0] zeros(1,10) zeros(1,11) ], ...  % bottow row energize 5 spread
    [ [ones(1,4) zeros(1,7)] zeros(1,10) zeros(1,11) ], ... % bottom row energize 4 tight
    [ [ones(1,6) zeros(1,5)] zeros(1,10) zeros(1,11) ], ... % bottom row energize 6 tight
    [ [ones(1,8) zeros(1,3)] zeros(1,10) zeros(1,11) ] };  % bottom row energize 8 tight
    

Srow_nosteer.Phase= repmat({zeros(1,32)},size(Srow_nosteer.Amp));

assert( (length(Srow_nosteer.Des)== length(Srow_nosteer.Amp))& (length(Srow_nosteer.Des)== length(Srow_nosteer.Phase)) );

Drow_nosteer= struct;
Drow_nosteer.Des= {'bottom+mid full','bottom+top full','top+mid full', ...
    'bottom+top 6 spread','bottom+top 5 spread','bottom 6 spread + top 5 spread' ...    
    'bottom 6 + mid 5 spread(a)','bottom 6 + mid 5 spread(b)', ...
    'bottom full + mid 5 spread(a)','bottom full + mid 5 spread(b)', ...
    'bottom full + top 6 spread','bottom full + top 5 spread','bottom 6 spread + mid 6 full', ...
    'bottom 5 spread + mid 5 full','bottom+mid 4 tight','bottom+top 4 tight', ...
    'bottom+mid 6 tight','bottom+top 6 tight', ...
    'bottom+mid 8 tight','bottom+top 8 tight', ...
    'bottom full + top 4 tight','bottom full + top 6 tight','bottom full + top 8 tight'
    };

Drow_nosteer.Amp= { [ones(1,11) ones(1,10) zeros(1,11)], ...       % bottow+middle
    [ones(1,11) zeros(1,10) ones(1,11)], ...      % bottom+top
    [zeros(1,11) ones(1,10) ones(1,11)], ...       % middle+top    
    [ [repmat([1 0],1,5) 1] zeros(1,10) [repmat([1 0],1,5) 1] ], ...  % bottom+top row energize 6
    [ [repmat([0 1],1,5) 0] zeros(1,10) [repmat([0 1],1,5) 0] ], ...  % bottom+top row energize 5
    [ [repmat([1 0],1,5) 1] zeros(1,10) [repmat([0 1],1,5) 0] ], ...  % bottom 6 spread + top 5 spread            
    [ [repmat([1 0],1,5) 1] repmat([1 0],1,5) zeros(1,11) ], ...      % bottom energize 6, middle energize 5
    [ [repmat([1 0],1,5) 1] repmat([0 1],1,5) zeros(1,11) ], ...     %  bottom energize 6, middle energize 5     
    [ ones(1,11) repmat([0 1],1,5) zeros(1,11) ], ...  % bottom full, middle 5 sparse
    [ ones(1,11) repmat([1 0],1,5) zeros(1,11) ], ...  % bottom full, middle 5 sparse    
    [ ones(1,11) zeros(1,10) [repmat([1 0],1,5) 1] ], ...  % bottom full, top 6 spread
    [ ones(1,11) zeros(1,10) [repmat([0 1],1,5) 0] ], ...  % bottom full, top 5 spread  
    [ [repmat([1 0],1,5) 1] ones(1,10) zeros(1,11) ], ...  % bottom 6, middle full
    [ [repmat([0 1],1,5) 0] ones(1,10) zeros(1,11) ], ...  % bottom 5, middle full
    [ [ones(1,4) zeros(1,7)] [ones(1,4) zeros(1,6)] zeros(1,11)], ... % bottom+mid 4 tight    
    [ [ones(1,4) zeros(1,7)] zeros(1,10) [ones(1,4) zeros(1,7)] ], ... % bottom+top 4 tight
    [ [ones(1,6) zeros(1,5)] [ones(1,6) zeros(1,4)] zeros(1,11)], ... % bottom+mid 6 tight
    [ [ones(1,6) zeros(1,5)] zeros(1,10) [ones(1,6) zeros(1,5)] ], .... % bottom+top 6 tight
    [ [ones(1,8) zeros(1,3)] [ones(1,8) zeros(1,2)] zeros(1,11)], ... % bottom+mid 8 tight
    [ [ones(1,8) zeros(1,3)] zeros(1,10) [ones(1,8) zeros(1,3)] ], ... % bottom+top 8 tight
    [ ones(1,11) zeros(1,10) [ones(1,4) zeros(1,7)] ], ...  % bottom full + top 4 tight    
    [ ones(1,11) zeros(1,10) [ones(1,6) zeros(1,5)] ], ... % bottom full + top 6 tight
    [ ones(1,11) zeros(1,10) [ones(1,8) zeros(1,3)] ], ... % bottom full + top 8 tight
    };          


Drow_nosteer.Phase= repmat({zeros(1,32)},size(Drow_nosteer.Amp));

assert( (length(Drow_nosteer.Des)== length(Drow_nosteer.Amp))& (length(Drow_nosteer.Des)== length(Drow_nosteer.Phase)) );


Trow_nosteer= struct;
Trow_nosteer.Des= {'all rows full','bottom+top 6 spread, mid 5 spread(a)','bottom+top 6 spread, mid 5 spread(b)', ...
    'top+bottom 6 spread, mid full','top+bottom 5 spread, mid full','top 6 spread, bottom 5 spread, mid full', ...
    'top+bottom full, mid 5 spread(a)','top+bottom full, mid 5 spread(b)'};

Trow_nosteer.Amp= {  [ones(1,11) ones(1,10) ones(1,11)], ...   % all rows full
    [ [repmat([1 0],1,5) 1] repmat([1 0],1,5) [repmat([1 0],1,5) 1] ], ... % bottom+top energize 6 + middle energize 5 
    [ [repmat([1 0],1,5) 1] repmat([0 1],1,5) [repmat([1 0],1,5) 1] ], ... % bottom+top energize 6 + middle energize 5    
    [ [repmat([1 0],1,5) 1] ones(1,10) [repmat([1 0],1,5) 1] ], ... % top+bottom sparse 6, middle full
    [ [repmat([0 1],1,5) 0] ones(1,10) [repmat([0 1],1,5) 0] ], ... % top+bottom sparse 5, middle full
    [ [repmat([1 0],1,5) 1] ones(1,10) [repmat([0 1],1,5) 0] ], ... % top+bottom sparse 6,5, middle full    
    [ ones(1,11) repmat([1 0],1,5) ones(1,11)], ...  % top+bottom full, middle 5 spread    
    [ ones(1,11) repmat([0 1],1,5) ones(1,11)] };    % top+bottom full, middle 5 spread
    
Trow_nosteer.Phase= repmat({zeros(1,32)}, size(Trow_nosteer.Amp));
    
assert( (length(Trow_nosteer.Des)== length(Trow_nosteer.Amp))& (length(Trow_nosteer.Des)== length(Trow_nosteer.Phase)) );

Srow_steer= struct;
Srow_steer.Des= { 'bottom full +90','bottom full -90','bottom full +180','bottom 6 spread +90', ...
    'bottom 5 spread +90','bottom 6 spread -90','bottom 5 spread -90','bottom 4 tight +90', ...
    'bottom 6 tight +90','bottom 8 tight +90' };
    
Srow_steer.Amp= { [ones(1,11) zeros(1,10) zeros(1,11)], ... % bottom full +90
                  [ones(1,11) zeros(1,10) zeros(1,11)], ... % bottom full -90
                  [ones(1,11) zeros(1,10) zeros(1,11)], ... % bottom full +180                
                  [ [repmat([1 0],1,5) 1] zeros(1,10) zeros(1,11)], ... % bottom 6 spread +90
                  [ [repmat([0 1],1,5) 0] zeros(1,10) zeros(1,11)], ... % bottom 5 spread +90
                  [ [repmat([1 0],1,5) 1] zeros(1,10) zeros(1,11)], ... % bottom 6 spread -90
                  [ [repmat([0 1],1,5) 0] zeros(1,10) zeros(1,11)], ... % bottom 5 spread -90
                  [ [ones(1,4) zeros(1,7)] zeros(1,10) zeros(1,11) ], ... % bottom 4 tight + 90
                  [ [ones(1,6) zeros(1,5)] zeros(1,10) zeros(1,11) ], ... % bottom 6 tight +90
                  [ [ones(1,8) zeros(1,3)] zeros(1,10) zeros(1,11) ] };  % bottom 8 tight +90


Srow_steer.Phase= { [mod(90*(0:10),360) zeros(1,10) zeros(1,11)], ...  % bottom full +90
                    [mod(-90*(0:10),360) zeros(1,10) zeros(1,11)], ... % bottom full -90
                    [mod(180*(0:10),360) zeros(1,10) zeros(1,11)], ... % bottom full +180
                    [ [0 0 90 0 180 0 270 0 0 0 90] zeros(1,10) zeros(1,11) ], ... % bottom 6 spread +90
                    [ [0 0 0 90 0 180 0 270 0 0 0] zeros(1,10) zeros(1,11) ], ... % bottom 5 spread +90
                    [ [0 0 -90 0 -180 0 -270 0 0 0 -90] zeros(1,10) zeros(1,11) ], ... % bottom 6 spread -90
                    [ [0 0 0 -90 0 -180 0 -270 0 0 0] zeros(1,10) zeros(1,11) ], ... % bottom 5 spread -90 
                    [ [[0 90 180 270] zeros(1,7)] zeros(1,10) zeros(1,11) ], ... % bottom 4 tight +90
                    [ [[0 90 180 270 0 90] zeros(1,5)] zeros(1,10) zeros(1,11) ], ... % bottom 6 tight +90
                    [ [[0 90 180 270 0 90 180 270] zeros(1,3)] zeros(1,10) zeros(1,11) ] };  % bottom 8 tight +90


Drow_steer= struct;

Drow_steer.Des= { 'bottom+top +90','bottom +90, top -90','bottom +90, middle +90','bottom +90, middle -90', ...
                  'bottom+top +90, Voff+90' };


Drow_steer.Amp= { [ones(1,11) zeros(1,10) ones(1,11)], ...  % bottom+top +90
                  [ones(1,11) zeros(1,10) ones(1,11)], ...  % bottom +90, top -90
                  [ones(1,11) ones(1,10) zeros(1,11)], ...  % bottom +90, middle +90
                  [ones(1,11) ones(1,10) zeros(1,11)], ...  % bottom +90, middle -90
                  [ones(1,11) zeros(1,10) ones(1,11)] };    % bottom+top +90, Voff+90
                                  

Drow_steer.Phase= { [mod(90*(0:10),360) zeros(1,10) mod(90*(0:10),360)], ...  % bottom+top +90
                    [mod(90*(0:10),360) zeros(1,10) mod(-90*(0:10),360)], ...  % bottom +90, top -90
                    [mod(90*(0:10),360) mod(90*(0:9),360) zeros(1,11)], ...    % bottom +90, middle +90
                    [mod(90*(0:10),360) mod(-90*(0:9),360) zeros(1,11)], ...   % bottom +90, middle -90
                    [mod(90*(0:10),360) zeros(1,10) 90+mod(90*(0:10),360)]     % bottom+top +90, Voff+90
                    };
                    
                
Amplitude_cell= [Srow_nosteer.Amp Drow_nosteer.Amp];   % Drow_nosteer.Amp Trow_nosteer.Amp];          
Phase_cell= [Srow_nosteer.Phase Drow_nosteer.Phase];   % Drow_nosteer.Phase Trow_nosteer.Phase];
Description= [Srow_nosteer.Des Drow_nosteer.Des];    % Drow_nosteer.Des Trow_nosteer.Des];


assert( length(Amplitude_cell) == length(Phase_cell) );
Output_pattern= cell(size(Phase_cell));

for ll=1:length(Amplitude_cell)
   arr.AmplitudeTaper= Amplitude_cell{ll};
   arr.PhaseShift= Phase_cell{ll};

   [AF_SIK,azi,elv]= arrayFactor(arr,fd,azi_grid,elv_grid);  

   Ftot= Fel.*10.^(AF_SIK/10);  % this is proportional to |E|
   assert(isempty(find(Ftot<0, 1)));
   Ftot= Ftot.^2;   % need |E|^2 for radiation intensity U (check Balanis)
  
   dth= (elv_grid(end)-elv_grid(1))/(length(elv_grid)-1)*pi/180;  % convert to radians
   dphi= (azi_grid(end)-azi_grid(1))/(length(azi_grid)-1)*pi/180; % convert to radians
   Prad=0;

   for ind=1:length(azi_grid)
      Prad= Prad+ dot(Ftot(:,ind),cosd(elv_grid))*dth*dphi;   
   end
   
   Ftot_dB= 10*log10(Ftot*4*pi/Prad);  

   Output_pattern{ll}= Ftot_dB;
   
end


