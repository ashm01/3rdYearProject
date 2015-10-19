function BlackjackBasicKO(numDecks, numHands, numGames)

    
    
    
    %pre allocating the 2d result array
    results = zeros(numHands,numGames);
    for game = 1:numGames;
        %initialising variables for each game session
        deckPosition = 1;
        deck = CreateDeck(numDecks);
        deck = ShuffleDeck(deck);
        player = struct();
        dealer = struct();
        %Variables initialized with every hand
        player.Hand.Total = 0;     %Player's Card Total
        dealer.Hand.Total = 0;     %Dealer's Card Total
        player.Hand.bust = 0;
        player.Hand.Ace = 0;       %Becomes 1 if Player has an Ace used as 11
        player.Hand.betAmount = 1;
        dealer.Ace = 0;       %Becomes 1 if Dealer has an Ace used as 11
        player.Hand.Card=deck(1); %Player's Hand
        dealer.Hand.Card=deck(1); %Dealer's Hand
        player.Blackjack = 0; %Becomes 1 if Player has Blackjack
        dealer.Blackjack = 0; %Becomes 1 if Dealer has Blackjack
        player.splitCounter = 1; % Increases when the player splits his hand
        player.bustHands = 0;
        player.split = 0;
        player.Hand.Stand = 0; %becomes 1 when player stands
        
        %Variables for card counting
        %AS 6 decks will be used the running count will start at -20
        player.runningCount = 0;
        player.trueCount = 0;
        
        
        %end game condition        
        endGame = 0;
        handNumber = 1;
        bankroll = 100;


        while endGame == 0
            %Clearing data from previous game
            for i = 1:player.splitCounter
                player.Hand(i).Card(:) = []; %Initialise Player's Hand
                player.Hand(i).Stand = 0; %becomes 1 when player stands
                player.Hand(i).Ace = 0;       %Becomes 1 if Player has an Ace used as 11
                player.Hand(i).Total = 0;
                %player.Hand(i).betAmount = determineBetAmount;
                player.Hand(i).betAmount = determineBetAmount;
                player.Hand(i).bust = 0;
            end
            player.splitCounter = 1;
            player.bustHands = 0;
            player.split = 0;
            dealer.Hand(1).Card(:) = []; % Initialise Dealer's Hand
            dealer.Total = 0;
            dealer.Ace = 0;
            endHand = 0; %If not 0, hand ends
            
            
            
            %condition to shuffle decks, 75% of the shoe used
            if(deckPosition > 39*numDecks)
                deck = ShuffleDeck(deck);
                deckPosition = 1;
                %Restart the counts
                player.runningCount = 0;
                player.trueCount=0;
                
            end


                player.Hand(1).Card(1) = deck(deckPosition);
                deckPosition = deckPosition +1;
                %increment count
                updateCount(player.Hand(1).Card(1));
                dealer.Hand(1).Card(1) = deck(deckPosition);
                deckPosition = deckPosition +1;
                %increment count
                updateCount(dealer.Hand(1).Card(1));
                player.Hand(1).Card(2) = deck(deckPosition);
                deckPosition = deckPosition +1; 
                %increment count
                updateCount(player.Hand(1).Card(2));
                
                dealer.Total = dealer.Hand(1).Card(1).BJvalue;
                player.Hand(1).Total = player.Hand(1).Card(1).BJvalue + player.Hand(1).Card(2).BJvalue;
                %checking for ace
                if(strcmp(player.Hand(1).Card(1).FaceValue,'A'))
                    %increment the number of aces
                    player.Hand(1).Ace = player.Hand(1).Ace +1;

                end
                if(strcmp(player.Hand(1).Card(2).FaceValue,'A'))
                    %increment num of aces
                     player.Hand(1).Ace = player.Hand(1).Ace +1;

                end
                %Checking for ace on players second card
                if(dealer.Hand(1).Card(1).BJvalue == 11)
                    %increment num of aces
                     dealer.Ace = dealer.Ace +1;

                end
                %Checking for Blackjack
                if(player.Hand(1).Total == 21)
                    
                    if(dealer.Total == 10 || dealer.Total == 11)
                        
                        %Dealer draws cards 
                        dealer.Hand(1).Card(2) = deck(deckPosition);
                        deckPosition = deckPosition +1;
                        %increment count
                        updateCount(dealer.Hand(1).Card(2));
                        %update total
                        dealer.Total = dealer.Total + dealer.Hand(1).Card(2).BJvalue;
                        %Checking for dealer blackjack
                        if(dealer.Total == 21)
                            player.Bankroll(handNumber) = bankroll;
                        else
                            bankroll = bankroll + (player.Hand(1).betAmount * 1.5);
                            player.Bankroll(handNumber) = bankroll;
                        end
                        
                        
                    else
                        bankroll = bankroll + (player.Hand(1).betAmount * 1.5);
                        player.Bankroll(handNumber) = bankroll;
                    end

                    
                    
                else%PLay out hand

                
                %Loop to play through all the player hands incase he has
                %split
                limit = 0;
                while limit ~= player.splitCounter
                    currentHand = limit + 1;
                    while endHand == 0;
                       numCards = length(player.Hand(currentHand).Card);
                        if(player.Hand(currentHand).Stand == 0) 
                            switch dealer.Total
                                %dealer showing a 2
                                case 2
                                    %SPLIT - all pairs apart from 4s 5s and
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total ~= 20 && numCards == 2 ...
                                             && player.Hand(currentHand).Total ~= 10 ...
                                             && player.Hand(currentHand).Total ~= 8 && player.split == 0)
                                        splitHand();
                                    %DOUBLE DOWN - 10 or 11 or a pair of fives
                                    elseif (player.Hand(currentHand).Total > 9 && player.Hand(currentHand).Total < 12 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2)
                                            doubleDown();
                                    %PLAYER HITS - 7,8,9,12
                                    elseif(player.Hand(currentHand).Total < 13 ||...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total < 18)

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %dealer showing a 3    
                                case 3
                                    %SPLIT - all pairs apart from 4s 5s and
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total ~= 20 && numCards == 2 ...
                                             && player.Hand(currentHand).Total ~= 10 ...
                                             && player.Hand(currentHand).Total ~= 8 && player.split == 0)

                                         splitHand();
                                    %DOUBLE DOWN - 9, 10, 11 or a pair of
                                    %fives or soft 17
                                    elseif (player.Hand(currentHand).Total > 8 && player.Hand(currentHand).Total < 12 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2 || ...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total == 17 && numCards == 2)

                                        doubleDown();
                                    %PLAYER HITS - 7,8,,12 and soft 13 - 16
                                    elseif(player.Hand(currentHand).Total < 13 || ...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total < 18)

                                        takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %dealer showing a 4    
                                case 4
                                    %SPLIT - all pairs apart from 4s 5s and
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total ~= 20 && numCards == 2 ...
                                             && player.Hand(currentHand).Total ~= 10 ...
                                             && player.Hand(currentHand).Total ~= 8 && player.split == 0)

                                            splitHand();
                                    %DOUBLE DOWN - 9, 10, 11 or a pair of
                                    %fives or soft 17, 16, 15
                                    elseif (player.Hand(currentHand).Total > 8 && player.Hand(currentHand).Total < 12 && numCards == 2 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2 || ...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total <= 17 && player.Hand(currentHand).Total >= 15 && numCards == 2)

                                            doubleDown();
                                    %PLAYER HITS - 7,8,,12 and soft 13 , 14
                                    elseif(player.Hand(currentHand).Total < 12 ||...
                                        player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total < 18 )

                                           takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %dealer showing a 5    
                                case 5
                                    %SPLIT - all pairs apart from 5s and
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total ~= 20 && numCards == 2 ...
                                             && player.Hand(currentHand).Total ~= 10 && player.split == 0)

                                            splitHand();
                                    %DOUBLE DOWN - 9, 10, 11 or a pair of
                                    %fives or soft 13 - 17
                                    elseif (player.Hand(currentHand).Total > 8 && player.Hand(currentHand).Total < 12 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2|| ...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total <= 17 && player.Hand(currentHand).Total >= 13 && numCards == 2)

                                            doubleDown();
                                    %PLAYER HITS - under 9 only
                                    elseif(player.Hand(currentHand).Total < 12 ||...
                                        player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total < 18 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %dealer showing a 6    
                                case 6
                                    %SPLIT - all pairs apart from 5s and
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total ~= 20 && numCards == 2  ...
                                             && player.Hand(currentHand).Total ~= 10 && player.split == 0)
                                        splitHand();
                                    %DOUBLE DOWN - 9, 10, 11 or a pair of
                                    %fives or soft 13 - 17
                                    elseif (player.Hand(currentHand).Total > 8 && player.Hand(currentHand).Total < 12 && numCards == 2 && numCards == 2||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2 || ...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total <= 17 && player.Hand(currentHand).Total >= 13 && numCards == 2)

                                            doubleDown();
                                    %PLAYER HITS - under 9 only
                                    elseif(player.Hand(currentHand).Total < 12 ||...
                                        player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total < 18 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %dealer showing a 7    
                                case 7
                                    %SPLIT - all pairs apart from 4s 5s 6s and
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total ~= 20 && numCards == 2 ...
                                             && player.Hand(currentHand).Total ~= 10 ...
                                             && player.Hand(currentHand).Total ~= 8  ...
                                             && player.Hand(currentHand).Total ~= 12 && player.split == 0)
                                        splitHand();
                                    %DOUBLE DOWN - 10, 11 or a pair of 5s

                                    elseif (player.Hand(currentHand).Total > 9 && player.Hand(currentHand).Total < 12 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2)

                                            doubleDown();
                                    %PLAYER HITS - under 9...hard 12 - 16
                                    %...soft 13 - 17
                                    elseif(player.Hand(currentHand).Total < 17 ||...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total == 17 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %DEALER SHOWING 8
                                case 8
                                    %SPLIT - only 8, 9 and aces
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 16 && numCards == 2 && player.split == 0 ...
                                             || player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 18 && numCards == 2 && player.split == 0 ...
                                             || player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 22 && numCards == 2 && player.split == 0)
                                        splitHand();
                                    %DOUBLE DOWN - 10, 11 or a pair of 5s

                                    elseif (player.Hand(currentHand).Total > 9 && player.Hand(currentHand).Total < 12 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2)

                                            doubleDown();
                                    %PLAYER HITS - under 9...hard 12 - 16
                                    %...soft 13 - 17
                                    elseif(player.Hand(currentHand).Total < 17 ||...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total == 17 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %DEALER SHOWING 9
                                case 9
                                    %SPLIT - only 8, 9 and aces
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 16 && numCards == 2 && player.split == 0 ...
                                             || player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 18 && numCards == 2 && player.split == 0 ...
                                             || player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 22 && numCards == 2 && player.split == 0)
                                            splitHand();
                                    %DOUBLE DOWN - 10, 11 or a pair of 5s

                                    elseif (player.Hand(currentHand).Total > 9 && player.Hand(currentHand).Total < 12 && numCards == 2 ||...
                                            player.Hand(currentHand).Card(1).Rank == 5 && player.Hand(currentHand).Card(2).Rank == 5 && numCards == 2)
                                            doubleDown();
                                    %PLAYER HITS - under 9...hard 12 - 16
                                    %...soft 13 - 17
                                    elseif(player.Hand(currentHand).Total < 17 ||...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total > 16 && player.Hand(currentHand).Total < 19 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                                %DEALER SHOWING 10, J, Q, K 
                                case 10
                                    %SPLIT - only 8, 9 and aces
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 22 && numCards == 2 && player.split == 0)
                                            splitHand();

                                    %DOUBLE DOWN - 11
                                    %NO DOUBLE DOWN
                                    %****************************
%                                     elseif (player.Hand(currentHand).Total == 11 && numCards == 2)
% 
%                                             doubleDown();
                                    %PLAYER HITS - under 16
                                    %...soft 13 - 18
                                    elseif(player.Hand(currentHand).Total < 17 ||...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total > 16 && player.Hand(currentHand).Total < 19 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                            standTest();
                                    end
                                %DEALER SHOWING ACE 
                                case 11
                                    %SPLIT - only 8, 9 and aces
                                    %Tens(10 J K Q)
                                    if (player.Hand(currentHand).Card(1).BJvalue == player.Hand(currentHand).Card(2).BJvalue && player.Hand(currentHand).Total == 22 && numCards == 2 && player.split == 0)
                                            splitHand();

                                    % NO DOUBLE DOWN

                                    %PLAYER HITS - under 16
                                    %...soft 13 - 18
                                    elseif(player.Hand(currentHand).Total < 17 ||...
                                            player.Hand(currentHand).Ace > 0 && player.Hand(currentHand).Total > 16 && player.Hand(currentHand).Total < 19 )

                                            takeCard();
                                    % For every other combination the
                                    % player will stand
                                    else
                                        standTest();
                                    end
                            end
                        else%End the current hand
                            endHand = 1;
                        end
                        
                        
                    end
                    %incrementing the limit for while loop
                   limit = limit+1;
                   endHand = 0;
                end
                %Dealer only draws cards when all the players hands havent
                %bust
               
                if(player.bustHands ~= player.splitCounter)
                    %Dealer draws cards 
                    dealer.Hand(1).Card(2) = deck(deckPosition);
                    deckPosition = deckPosition +1;
                    dealer.Total = dealer.Total + dealer.Hand(1).Card(2).BJvalue;
                    %Updating card count
                    updateCount(dealer.Hand(1).Card(2));
                    if(dealer.Hand(1).Card(2).BJvalue == 11)
                           dealer.Ace = dealer.Ace +1;
                           %Checking for pair of aces
                           if(dealer.Ace == 2)
                               dealer.Total = dealer.Total - 10;
                               dealer.Ace = dealer.Ace - 1;
                           end
                    end
                    dIndex = 3;
                    while dealer.Total < 17
                        dealer.Hand(1).Card(dIndex) = deck(deckPosition);
                        deckPosition = deckPosition +1;
                        if(dealer.Hand(1).Card(dIndex).BJvalue == 11)
                           dealer.Ace = dealer.Ace +1;
                        end
                        dealer.Total = dealer.Total + dealer.Hand(1).Card(dIndex).BJvalue;
                        %Updating card count
                        updateCount(dealer.Hand(1).Card(dIndex));
                        if(dealer.Total > 21 && dealer.Ace > 0)
                            dealer.Total = dealer.Total - 10;
                            dealer.Ace = dealer.Ace -1;
                        end
                        dIndex = dIndex + 1;
                    end
                    %Checking the dealers total against players hands
                    for currentHand = 1:player.splitCounter
                        %determing the winner of the hand
                        if(player.Hand(currentHand).bust == 1)
                            bankroll = bankroll - player.Hand(currentHand).betAmount;
                            
                        elseif(dealer.Total > 21)
                            bankroll = bankroll + player.Hand(currentHand).betAmount;
                            
                        elseif (dealer.Total < player.Hand(currentHand).Total)
                            bankroll = bankroll + player.Hand(currentHand).betAmount;
                            
                        elseif (dealer.Total > player.Hand(currentHand).Total)
                            bankroll = bankroll - player.Hand(currentHand).betAmount;
                            
                        elseif (dealer.Total == player.Hand(currentHand).Total)
                            
                        end
                    end
                    player.Bankroll(handNumber) = bankroll;
                else
                    %This case is when all hands have been bust
                    for currentHand = 1:player.splitCounter
                        bankroll = bankroll - player.Hand(currentHand).betAmount;
                        player.Bankroll(handNumber) = bankroll;
                    end
                end
                end
%                  printHands;
%                  clc;
            %incrementing hand number
            handNumber = handNumber + 1;
            if(handNumber > numHands)
                results(:,game) = player.Bankroll(:);
                endGame = 1;
            end
        end
    end
    %Graphing the results
    %finding the average
    figure
    avResults = mean(results');
    plot(results)
    title('Basic Strategy with KO Card Counting - 10000, 100 Game Sessions')
    ylabel('Profit/Loss') % x-axis label
    xlabel('Hand Number') % y-axis label
    hold on
    avLine = plot(avResults);
    set(avLine, 'LineWidth', 4);
    legend('Average Gain','Location','southwest')
    
 
    
    
    
function splitHand 
    %Incrementing the split counter
    %which tells me how many hands the
    %player is playing
    player.splitCounter = player.splitCounter +1;
    %special case ACES
    %altering the count for the number
    %of aces in the hands and ensuring they only recieve one card
    if(player.Hand(currentHand).Card(1).BJvalue == 11)
        player.Hand(currentHand).Ace = 1;
        player.Hand(player.splitCounter).Ace = 1;
        player.Hand(currentHand).Stand = 1;
        player.Hand(player.splitCounter).Stand = 1;
        
    else
        player.Hand(currentHand).Ace = 0;
        player.Hand(player.splitCounter).Ace = 0;
        player.Hand(player.splitCounter).Stand = 0;
    end    
    player.Hand(player.splitCounter).Card(1) = player.Hand(currentHand).Card(2);
    player.Hand(currentHand).Card(2) = deck(deckPosition); 
    deckPosition = deckPosition +1;
    if(player.Hand(currentHand).Card(2).BJvalue == 11)
        player.Hand(currentHand).Ace = player.Hand(currentHand).Ace + 1;
    end
    player.Hand(player.splitCounter).Card(2) = deck(deckPosition);
    deckPosition = deckPosition +1;
    if(player.Hand(player.splitCounter).Card(2).BJvalue == 11)
        player.Hand(player.splitCounter).Ace = player.Hand(player.splitCounter).Ace + 1;
    end
    player.Hand(currentHand).Total = player.Hand(currentHand).Card(1).BJvalue + player.Hand(currentHand).Card(2).BJvalue;
    player.Hand(player.splitCounter).Total = player.Hand(player.splitCounter).Card(1).BJvalue + player.Hand(player.splitCounter).Card(2).BJvalue;
    player.Hand(player.splitCounter).betAmount = player.Hand(currentHand).betAmount;
    
    player.split = 1;
    %Updating the running count with the new cards drawn
    updateCount(player.Hand(currentHand).Card(2));
    updateCount(player.Hand(player.splitCounter).Card(2));
    

end

function doubleDown
    
    
    player.Hand(currentHand).Card(3) = deck(deckPosition);
    player.Hand(currentHand).Total = player.Hand(currentHand).Total + player.Hand(currentHand).Card(end).BJvalue;
    deckPosition = deckPosition +1;
    player.Hand(currentHand).betAmount = player.Hand(currentHand).betAmount * 2;
    %Updating the card count
    updateCount(player.Hand(currentHand).Card(3));
    if(player.Hand(currentHand).Card(end).BJvalue == 11)
        player.Hand(currentHand).Ace = player.Hand(currentHand).Ace+ 1;
    end
    %checking if player busts (Doubling soft hands)
    if(player.Hand(currentHand).Total > 21 && player.Hand(currentHand).Ace > 0)
        player.Hand(currentHand).Total = player.Hand(currentHand).Total - 10;
        player.Hand(currentHand).Ace = player.Hand(currentHand).Ace -1;
    elseif (player.Hand(currentHand).Total > 21)
        player.bustHands = player.bustHands + 1;
        player.Hand(currentHand).bust = 1;
    end
    
    player.Hand(currentHand).Stand = 1;

end

function takeCard
    
    
    player.Hand(currentHand).Card(end+1) = deck(deckPosition);
    player.Hand(currentHand).Total = player.Hand(currentHand).Total + player.Hand(currentHand).Card(end).BJvalue;
    deckPosition = deckPosition +1;
    %Incrementing the card count
    updateCount(player.Hand(currentHand).Card(end));
    if(player.Hand(currentHand).Card(end).BJvalue == 11)
        player.Hand(currentHand).Ace = player.Hand(currentHand).Ace + 1;
    end

end 
    
function standTest
    if(player.Hand(currentHand).Total > 21 && player.Hand(currentHand).Ace > 0)
        player.Hand(currentHand).Total = player.Hand(currentHand).Total - 10;
        player.Hand(currentHand).Ace = player.Hand(currentHand).Ace -1;
    elseif (player.Hand(currentHand).Total > 21)
        player.bustHands = player.bustHands + 1;
        player.Hand(currentHand).Stand = 1;
        player.Hand(currentHand).bust = 1;
    else
        player.Hand(currentHand).Stand = 1;
    end    
end

function printHands
    
    
    handNumber
    for handNo = 1:player.splitCounter

        disp(strcat('Players Hand ',num2str(handNo))); 
        disp(strcat('Total = ',num2str(player.Hand(handNo).Total)));
        disp(strcat('Bet Amount = ',num2str(player.Hand(handNo).betAmount)));
        for PHand = 1:length(player.Hand(handNo).Card)

        disp(player.Hand(handNo).Card(PHand).BJvalue);

        end


    end
    disp('Dealer Hand');
    disp(strcat('Dealer Total = ', num2str(dealer.Total)));
    for dHand = 1:length(dealer.Hand(1).Card)

        disp(dealer.Hand(1).Card(dHand).BJvalue);
    end

    if(handNumber == 1)
        disp(strcat('Profit/loss = ',num2str(player.Bankroll(handNumber)-100)));
    else
        disp(strcat('Profit/loss = ',num2str(player.Bankroll(handNumber) - player.Bankroll(handNumber-1))));
    end
        
     
   
end

function updateCount(card)
 
    %ZEN COUNT
    player.runningCount = player.runningCount + card.KOValue;

    end

function betAmount = determineBetAmount

   
    maxBet = 20;
    minBet = 1;
    
    %The bet amount will be a function on the true coount
    %betAmount = round(player.trueCount);
    betAmount = player.runningCount*2;
    %betAmount = round(player.trueCount)^2;
    
    
    %Checking the amount doesnt exceed or go below the min/max bet
    if(betAmount < minBet)
        betAmount = minBet;
    elseif(betAmount > maxBet)
        betAmount = maxBet;
    end

end   

 

end



                                
                                
                            
                            