% Insect Infestation!
% Michael C. Mulcahy
% Created: 11/30/2015
% Updated: 12/01/2015
% Homework #13
% Modeling & Simulation
% Professor: James Rathman
% Due: 12/03/2015

% Special thanks to Dr. Rathmoney for the template (specifically the three
% dimensional moore array). My program would probably be fantastically slow
% otherwise.

% The insect infestation program takes in two inputs, the lattice density
% (0 - 1 scale representing the number of trees over the total grid spots)
% and the neighborhood style (von Neumann or Moore with r = 1). All of the
% center trees in the lattice (33:37, 68:72) are infected a time 0, and infect surrounding
% trees at a n/10 probability. n is the number of infected trees within a
% specific tree's neighborhood. The initial grid size is 70 rows by 140
% columns.

function mulcahy_michael_p13(density,neighborhood)
%% Handle Input Arguments    
if nargin < 2
    neighborhood = 'vonNeumann';
end
if ~strcmp(neighborhood,'vonNeumann') && ~strcmp(neighborhood,'Moore')
    error('Invalid neighborhood type. Please use "vonNeumann" or "Moore".')
end
if density < 0 || density > 1
    error('Invalid density value. Please choose a value between 0 and 1.')
end

% Build and seed inner lattice with trees at specified density
N = 70; % Row Grid Size
totalGrid = zeros(N+2,2*N+2); % Preallocate lattice plus boundary rows and columns
totalGrid(2:N+1,2:N*2+1) = binornd(1,density,N,2*N); % Randomly generated seed pattern

%% Set center trees as infested
intInfest = totalGrid(33:37,68:72);
for i = 1:length(intInfest(:))
    if intInfest(i) == 1
        intInfest(i) = 2;
    end    
end
totalGrid(33:37,68:72) = intInfest;     % Initial grid with boundaries
playGrid = totalGrid(2:end-1,2:end-1);  % Initial grid without boundaries

%% Plot initial grid
h = pcolor(totalGrid(2:end,2:end));
colormap([255 255 255;0 204 0;255 102 0]/255) % white, green, orange
caxis([0 2])
set(h,'LineStyle','-','LineWidth',0.1,'EdgeColor',[212 208 200]/255)
axis equal
titleText{1} = ['Insect Infestation Density = ' num2str(density)];
titleText{2} = 'nSteps = 0';
title(titleText)
pause

%% Initialize variables for run loop
moore = zeros(N,2*N,8); % Preallocate Moore neighborhoods array
nSteps = 0;
stopFlag = false;

%% Run loop!
while ~stopFlag
   % Construct the 3D array of neighborhood matrices. Dead zone boundary
   % conditions, so first and last rows and columns of z are always state
   % 0. The third indice in the moore array corresponds to the value in the
   % square below with relation to the center point, "0".
   % 1 4 6
   % 2 0 7
   % 3 5 8
   
   moore(:,:,1) = totalGrid(1:end-2,1:end-2);    % Position 1
   moore(:,:,2) = totalGrid(1:end-2,2:end-1);    % Position 2
   moore(:,:,3) = totalGrid(1:end-2,3:end);      % Position 3
   moore(:,:,4) = totalGrid(2:end-1,1:end-2);    % Position 4
   moore(:,:,5) = totalGrid(2:end-1,3:end);      % Position 5
   moore(:,:,6) = totalGrid(3:end,1:end-2);      % Position 6
   moore(:,:,7) = totalGrid(3:end,2:end-1);      % Position 7
   moore(:,:,8) = totalGrid(3:end,3:end);        % Position 8
   
   % Determine neighborhood and sum corresponding values to determine
   % infestation probability.
   switch neighborhood
       case 'Moore'
           probInfest = sum(moore==2,3)/10;
       case 'vonNeumann'
           vonNeumann = moore(:,:,[2 4 5 7]);
           probInfest = sum(vonNeumann==2,3)/10;
   end
   
   % Rules - bare sites (value 0) and infested trees (value 2) do not
   % change. Uninfected trees (value 1) have a probability of the number of
   % infested trees in the neighborhood (n) divided by 10 of becoming
   % infected. Probability of infestation = n/10.
   k1 = playGrid==1 & probInfest>0;
   if ~any(k1(:)) % if no sites can change
       stopFlag = true; % end run loop
   else
       nSteps = nSteps + 1;
       positionProbInfest=find(probInfest);             % Find position of sites able to be infested
       randDist = rand(1,length(positionProbInfest));   % Generate random number from 0 - 1 for each site able to be infested
       
       % The Sickening (of trees by bugs)!
       for i = 1:length(positionProbInfest)
           if randDist(i) < probInfest(positionProbInfest(i)) && k1(positionProbInfest(i))
               playGrid(positionProbInfest(i)) = 2;
           end
       end
       
       % Update plot
       totalGrid(2:end-1,2:end-1) = playGrid;
       set(h,'CData',totalGrid(2:end,2:end))
       titleText{2} = ['nSteps = ' num2str(nSteps)];
       title(titleText)
       %pause(0.05)
   end
end   