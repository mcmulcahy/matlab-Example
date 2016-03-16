% Random_Walk
% Michael C. Mulcahy
% Created: 11/21/2015
% Updated: 11/21/2015
% Homework #11
% Modeling & Simulation
% Professor: James Rathman
% Due: 11/25/2015

% This program takes in two arguments. The first argument is an n by 2 position vector where each
% row is a player, and columns one and two correspond to the x and y
% coordinates of a player. The second argument is a logical true/false
% value which decides how player 1 moves. True results in a strategic
% method of movement, whereas false results in a randomly decided movement.
% The default value is false. The program runs a game where all players
% move sequentially on a 40x40 grid. The game has periodic boundary
% conditions, and also has a self-avoiding or wall behavior. Once a player
% steps on a space in the grid, that space changes to a wall, and cannot be
% stepped on again. The game runs until all players except one can move.
% The program currently holds a max of 7 players due to color limitations.

function winner = mulcahy_michael_p12(nPosition,flagStrat)

% Handle input arguments
switch nargin
    case 0
        nPosition = [10 30; 30 10];
        flagStrat=logical(false);
    case 1
        if islogical(nPosition)
            flagStrat = nPosition;
            nPosition = [10 30; 30 10];
        else
            flagStrat=logical(false);
        end
    case 2
        % ONWARD TO THE BERMUDA TRIANGLE!
    otherwise
        error('Invalid number of input arguments.')
end

% Initialize variables
nplayers = size(nPosition,1);   % Number of players
xmax=40;                        % Size of grid in the x-direction
ymax=40;                        % Size of grid in the y-direction
gridSpots=zeros(xmax,ymax);     % Initialize grid
colors = 'brgcymk';             % Player colors
hold on

for i=1:nplayers
        flagStop(i) = logical(true);    % Flag to stop game when all values = true
        nSteps(i) = 0;                  % Total number of steps taken
        h(i)=plot(nPosition(i,1),nPosition(i,2),'x','MarkerEdgeColor',colors(i));   % Plot initial player positions
        ht(i)=title(['Steps taken = ' num2str(nSteps(i))]);                         % Graph title
        gridSpots(nPosition(i,1),nPosition(i,2) ) = logical(true);                  % Initialize matrix player positions
end

axis([0 xmax+1 0 ymax+1])
pause

while sum(flagStop) > 1
    for i=1:nplayers
        nx = nPosition(i,1); % Active position place holder x
        ny = nPosition(i,2); % Active position place holder y
        
        flagGrid=zeros(4,1);    % Enables players who have no moves to be removed from the game. Positions 1-4 correspond to the four adjacent grid spots surrounding a player
        stratCounter = 1;       % Counter for strategic mvement switch
        
        while gridSpots(nx,ny) == logical(true) && flagStop(i) == logical(true) % Repeat player movement until player is either on a new grid spot, or is blocked in
            
            if sum(flagGrid(:)) == 4 % Check to see if player is blocked in
                flagStop(i)=logical(false); % Remove player from play if blocked in
            end
            
            nx = nPosition(i,1); % Active position place holder x
            ny = nPosition(i,2); % Active position place holder y
            
            if flagStrat == logical(true) && i == 1 % Conditional if strategic mode is on for player 1
                switch stratCounter
                    case 1
                        ny = ny+1;
                        flagGrid(1)=logical(true);
                    case 2
                        nx = nx+1;
                        flagGrid(2)=logical(true);
                    case 3
                        nx = nx-1;
                        flagGrid(3)=logical(true);
                    case 4
                        ny = ny-1;
                        flagGrid(4)=logical(true);
                end
                stratCounter = stratCounter+1;
            else % Normal decision procedure for players not using strategic mode                
                d=randi(4);
                switch d
                    case 1
                        ny = ny+1;
                        flagGrid(1)=logical(true);
                    case 2
                        nx = nx-1;
                        flagGrid(2)=logical(true);
                    case 3
                        ny = ny-1;
                        flagGrid(3)=logical(true);
                    case 4
                        nx = nx+1;
                        flagGrid(4)=logical(true);
                end
            end
            
            % Handle periodic boundary conditions
            if nx > xmax
                nx = nx - xmax;
            elseif nx < 1
                nx = nx + xmax;
            end
            if ny > ymax
                ny = ny - ymax;
            elseif ny < 1
                ny = ny + ymax;
            end
        end
        
        % Plot new information and exit loop if player is on a valid spot
        if flagStop(i) == logical(true)
            gridSpots(nx,ny) = logical(true);   % Change false grid value (open spot) to true grid value (wall/player taken spot)
            nSteps(i)=nSteps(i)+1;              % Update step count
            
            if ~isempty(h) % Change previous player icon to wall icon
                set(h(i),'Marker','o')
            end
            
            h(i)=plot(nx,ny,'x','MarkerEdgeColor',[colors(i)]);
            set(ht(i),'String',['Steps taken = ' num2str(nSteps(i))])
            
            % Update player position
            nPosition(i,1) = nx;
            nPosition(i,2) = ny;
        end
        pause(0.01);
    end
end
hold off
% ANNOUNCE THE WINNER!
winner = ['Player ' num2str(find(flagStop)) ' wins!'];
