%%
close all;

Output_pattern= Out;
azi= azi_grid;
elv= elv_grid;
plot_increment= 90;

% group cases for easier reference. You need {{ }} to create cell array as
% contents of single field
Srow_nosteer= struct('Des', {{'top full', 'mid full','bottom full','bottow 6 spread','bottow 5 spread', ...
     'bottom 4 tight','bottom 6 tight','bottom 8 tight' }} );

Srow_steer= struct('Des', {{ 'bottom full +90','bottom full -90','bottom full +180','bottom 6 spread +90', ...
     'bottom 5 spread +90','bottom 6 spread -90','bottom 5 spread -90','bottom 4 tight +90', ...
     'bottom 6 tight +90','bottom 8 tight +90' }} );

 
Drow_nosteer= struct('Des', {{'bottom+mid full','bottom+top full','top+mid full', ...
    'bottom+top 6 spread','bottom+top 5 spread','bottom 6 spread + top 5 spread' ...    
    'bottom 6 + mid 5 spread(a)','bottom 6 + mid 5 spread(b)', ...
    'bottom full + mid 5 spread(a)','bottom full + mid 5 spread(b)', ...
    'bottom full + top 6 spread','bottom full + top 5 spread','bottom 6 spread + mid 6 full', ...
    'bottom 5 spread + mid 5 full', ...
    'bottom+mid 4 tight','bottom+top 4 tight','bottom+mid 6 tight','bottom+top 6 tight', ...
    'bottom+mid 8 tight','bottom+top 8 tight','bottom full + top 4 tight', ...   
    'bottom full + top 6 tight','bottom full + top 8 tight' }} );

Drow_steer= struct('Des', {{ 'bottom+top +90','bottom +90, top -90','bottom +90, middle +90', ...
    'bottom +90, middle +90','bottom+top +90, Voff+90' }} );
    
Trow_nosteer= struct('Des', {{'all rows full','bottom+top 6 spread, mid 5 spread(a)','bottom+top 6 spread, mid 5 spread(b)', ...
    'top+bottom 6 spread, mid full','top+bottom 5 spread, mid full','top 6 spread, bottom 5 spread, mid full', ...
    'top+bottom full, mid 5 spread(a)','top+bottom full, mid 5 spread(b)'}} );


%% single row: no steering, all cases in single figure
legend_index= exact_cases(Des,Srow_nosteer.Des);

if length(legend_index) <= 7
   legend_index= plot_plane_phi0_gather(Des,Srow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=0');

   figure;
   legend_index= plot_plane_phi90_gather(Des,Srow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=90');
end


% single row: no steering, each case in separate subplot
case_ind= legend_index( string(Des(legend_index)) ~= 'top full' );   % take all cases except for 'top full'
plot_plane_phi0_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=0');

plot_plane_phi90_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=90');

%% double row: no steering, gather all cases (if less than 8)
legend_index= exact_cases(Des,Drow_nosteer.Des);

if length(legend_index) <= 7   % the human brain cannot process more than 8 colors
   figure;
   legend_index= plot_plane_phi0_gather(Des,Drow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=0');
    
   figure;
   legend_index= plot_plane_phi90_gather(Des,Drow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=90');
end

% double row: no steering, each case in separate subplot
case_ind= legend_index;
plot_plane_phi0_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=0');

plot_plane_phi90_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=90');
    
%% triple row: no steering, gather all cases (if less than 8)
legend_index= exact_cases(Des,Trow_nosteer.Des);

if length(legend_index) <= 7   % the human brain cannot process more than 8 colors
    figure;
    legend_index= plot_plane_phi0_gather(Des,Trow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
    legend(Des(legend_index));
    set(gcf,'Name','Pattern for phi=0');
    
    figure;
    legend_index= plot_plane_phi90_gather(Des,Trow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
    legend(Des(legend_index));
    set(gcf,'Name','Pattern for phi=90');
end

% triple row: no steering, each case in separate subplot
case_ind= legend_index;
plot_plane_phi0_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=0');

plot_plane_phi90_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=90');
    

legend_index= exact_cases(Des,Srow_nosteer.Des);

if length(legend_index) <= 7
   legend_index= plot_plane_phi0_gather(Des,Srow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=0');

   figure;
   legend_index= plot_plane_phi90_gather(Des,Srow_nosteer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=90');
end


%% single row: steering, each case in separate subplot
legend_index= exact_cases(Des,Srow_steer.Des);

if length(legend_index) <= 7
   legend_index= plot_plane_phi0_gather(Des,Srow_steer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=0');

   figure;
   legend_index= plot_plane_phi90_gather(Des,Srow_steer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=90');
end

% single row: steering, each case in separate subplot
case_ind= legend_index;   
plot_plane_phi0_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=0');

plot_plane_phi90_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=90');




%% double row: steering, gather all cases (if less than 8)
legend_index= exact_cases(Des,Drow_steer.Des);

if length(legend_index) <= 7   % the human brain cannot process more than 8 colors
   figure;
   legend_index= plot_plane_phi0_gather(Des,Drow_steer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=0');
    
   figure;
   legend_index= plot_plane_phi90_gather(Des,Drow_steer.Des,azi,elv,Output_pattern,plot_increment);
   legend(Des(legend_index));
   set(gcf,'Name','Pattern for phi=90');
end

% double row: steering, each case in separate subplot
case_ind= legend_index;
plot_plane_phi0_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=0');

plot_plane_phi90_subplot(Des,case_ind,azi,elv,Output_pattern,plot_increment);
set(gcf,'Name','Pattern for phi=90');





% % two rows with phase progression
% P1= polarpattern([elv elv+plot_increment], [Output_pattern{1}(:,azi==0); flipud(Output_pattern{1}(:,azi==180))], ...
%                  [elv elv+plot_increment], [Output_pattern{2}(:,azi==0); flipud(Output_pattern{2}(:,azi==180))], ...
%                  [elv elv+plot_increment], [Output_pattern{3}(:,azi==0); flipud(Output_pattern{3}(:,azi==180))], ...
%                  [elv elv+plot_increment], [Output_pattern{4}(:,azi==0); flipud(Output_pattern{4}(:,azi==180))] );
%                                      
% legend_text=  {'bottom+top +90','bottom +90, top -90','bottom+90, middle +90','bottom +90, middle -90'};
% legend(legend_text);
% P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;  
% P1.MagnitudeLimBounds= [-60 inf];
% set(gcf,'Name','Pattern at phi=0');
% 
% 
% figure;
% P2= polarpattern([elv elv+plot_increment], [Output_pattern{1}(:,azi==90); flipud(Output_pattern{1}(:,azi==-90))], ...
%                  [elv elv+plot_increment], [Output_pattern{2}(:,azi==90); flipud(Output_pattern{2}(:,azi==-90))], ...
%                  [elv elv+plot_increment], [Output_pattern{3}(:,azi==90); flipud(Output_pattern{3}(:,azi==-90))], ...
%                  [elv elv+plot_increment], [Output_pattern{4}(:,azi==90); flipud(Output_pattern{4}(:,azi==-90))] );
% 
% legend('bottom+top +90','bottom +90, top -90','bottom+90, middle +90','bottom +90, middle -90');
% P2.AngleResolution=30; P2.DrawGridToOrigin= true; P2.LineWidth=2; P2.GridWidth=1.5;  
% P2.MagnitudeLimBounds= [-60 inf];
% set(gcf,'Name','Pattern at phi=90');
% 


%% local functions
function [legend_index]= exact_cases(Output_Des, Scenario_Des)
   legend_index= [];
   
   for ii=1:length(Scenario_Des)
      output_ind= find(Output_Des== string(Scenario_Des{ii}) );  % index of scenario contained in output cell array
      assert(length(output_ind)<=1);
      
      if ~isempty(output_ind)      
        legend_index= [ legend_index output_ind];
      end
   end

end


function [legend_index]= plot_plane_phi0_gather(Output_Des,Scenario_Des,azi,elv,Output_pattern,plot_increment)

legend_index= [];
for ii=1:length(Scenario_Des)
    output_ind= find(Output_Des== string(Scenario_Des{ii}) );  % index of scenario contained in output cell array
    
    if ~isempty(output_ind)      
        legend_index= [ legend_index output_ind];
        P1= polarpattern([elv elv+plot_increment], [Output_pattern{output_ind}(:,azi==0); ...
                          flipud(Output_pattern{output_ind}(:,azi==180))] );
        
        P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;  
        P1.MagnitudeLimBounds= [-60 inf];
        P1.NextPlot= 'add';
    end
end 

end


function [legend_index]= plot_plane_phi90_gather(Output_Des,Scenario_Des,azi,elv,Output_pattern,plot_increment)

legend_index= [];
for ii=1:length(Scenario_Des)
    output_ind= find(Output_Des== string(Scenario_Des{ii}) );  % index of scenario contained in output cell array
    
    if ~isempty(output_ind)      
        legend_index= [ legend_index output_ind];
        P1= polarpattern([elv elv+plot_increment], [Output_pattern{output_ind}(:,azi==90); ...
                          flipud(Output_pattern{output_ind}(:,azi==-90))] );
        
        P1.AngleResolution=30; P1.DrawGridToOrigin= true; P1.LineWidth=2; P1.GridWidth=1.5;  
        P1.MagnitudeLimBounds= [-60 inf];
        P1.NextPlot= 'add';
    end
end 

end


function []= plot_plane_phi0_subplot(Output_Des,case_ind,azi,elv,Output_pattern,plot_increment)

subp_index= 1;
M= 2;
num_inst= length(case_ind);
legend_text= Output_Des(case_ind);

for indf=1:ceil(num_inst/M^2)
   figure;
   
   for ii=0:M-1
      for jj= M-1:-1:0
         if subp_index<= num_inst
            h=subplot('Position',[(ii+0.1)/M (jj+0.1)/M 0.9/M 0.9/M]);
            P=polarpattern(h,[elv elv+plot_increment], [Output_pattern{case_ind(subp_index)}(:,azi==0); ...
                               flipud(Output_pattern{case_ind(subp_index)}(:,azi==180))] );                                             

            P.AngleResolution=30; P.DrawGridToOrigin=true; P.LineWidth=2; P.GridWidth=1.5; P.FontSize=11;                                       
            P.TitleTop= sprintf('Inst %d: %s',case_ind(subp_index),legend_text{subp_index});
            P.MagnitudeLimBounds= [-60 inf];
            subp_index= subp_index+1;
         end
      end
   end  
   
   set(gcf,'Name','Pattern for phi=0');
end


end


function []= plot_plane_phi90_subplot(Output_Des,case_ind,azi,elv,Output_pattern,plot_increment)

subp_index= 1;
M= 2;
num_inst= length(case_ind);
legend_text= Output_Des(case_ind);

for indf=1:ceil(num_inst/M^2)
   figure;
   
   for ii=0:M-1
      for jj= M-1:-1:0
         if subp_index<= num_inst
            h=subplot('Position',[(ii+0.1)/M (jj+0.1)/M 0.9/M 0.9/M]);
            P=polarpattern(h,[elv elv+plot_increment], [Output_pattern{case_ind(subp_index)}(:,azi==90); ...
                               flipud(Output_pattern{case_ind(subp_index)}(:,azi==-90))] );                                             

            P.AngleResolution=30; P.DrawGridToOrigin=true; P.LineWidth=2; P.GridWidth=1.5; P.FontSize=11;                                       
            P.TitleTop= sprintf('Inst %d: %s',case_ind(subp_index),legend_text{subp_index});
            P.MagnitudeLimBounds= [-60 inf];
            subp_index= subp_index+1;
         end
      end
   end   
   
   set(gcf,'Name','Pattern for phi=90');
end


end
