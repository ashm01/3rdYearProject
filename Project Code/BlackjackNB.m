function BlackjackNB(numDecks, numHands, numGames)

    deck = CreateDeck(numDecks);
    
    betAmount = 1;
    %pre allocating the 2d result array
    results = zeros(numHands,numGames);
    for game = 1:numGames;
        %initialising variables for each game session
        deckPosition = 1;
        deck = ShuffleDeck(deck);
        player = struct();
        dealer = struct();
        player.Bankroll(1) = 0;
        %Variables initialized with every hand
        player.Total = 0;     %Player's Card Total
        dealer.Total = 0;     %Dealer's Card Total
        player.Ace = 0;       %Becomes 1 if Player has an Ace used as 11
        dealer.Ace = 0;       %Becomes 1 if Dealer has an Ace used as 11
        player.Hand=deck(1); %Player's Hand
        dealer.Hand=deck(1); %Dealer's Hand
        player.Blackjack = 0; %Becomes 1 if Player has Blackjack
        dealer.Blackjack = 0; %Becomes 1 if Dealer has Blackjack
        player.Bust = 0;      %Becomes 1 if Player Busts
        dealer.Bust = 0;      %Becomes 1 if Dealer Busts
        %end game condition        
        endGame = 0;
        handNumber = 1;
        bankroll = 100;


        while endGame == 0

            player.Hand(:) = []; %Initialise Player's Hand
            dealer.Hand(:) = []; % Initialise Dealer's Hand
            endHand = 0; %If not 0, hand ends
            player.Ace = 0;       %Becomes 1 if Player has an Ace used as 11
            dealer.Ace = 0;
            %condition to shuffle decks, 75% of the shoe used
            if(deckPosition > 39*numDecks)
                deck = ShuffleDeck(deck);
                deckPosition = 1;
            end


                player.Hand(1) = deck(deckPosition);
                deckPosition = deckPosition +1; 
                dealer.Hand(1) = deck(deckPosition);
                deckPosition = deckPosition +1;
                player.Hand(2) = deck(deckPosition);
                deckPosition = deckPosition +1; 
                dealer.Total = dealer.Hand(1).BJvalue;
                player.Total = player.Hand(1).BJvalue + player.Hand(2).BJvalue;
                %checking for ace
                if(strcmp(player.Hand(1).FaceValue,'A'))
                    %increment the number of aces
                    player.Ace = player.Ace +1;

                end
                if(strcmp(player.Hand(2).FaceValue,'A'))
                    %increment num of aces
                     player.Ace = player.Ace +1;

                end
                if(strcmp(dealer.Hand(1).FaceValue,'A'))
                    %increment num of aces
                     dealer.Ace = dealer.Ace +1;

                end
                %checking for the case when the player is dealt two aces
                %which would bust as the value would be 22
                if(player.Ace == 2)
                    %taking 10 away from value as one ace will have to be
                    %used as one
                    player.Total = player.Total - 10;
                    %decreasing the ace count as one has to have the value
                    %of 1
                    player.Ace = player.Ace -1;
                end
                
                %Checking for Blackjack
                if(player.Total == 21)

                    if(dealer.Total == 10 || dealer.Total == 11)
                        
                        %Dealer draws cards 
                        dealer.Hand(2) = deck(deckPosition);
                        deckPosition = deckPosition +1;
                        dealer.Total = dealer.Total + dealer.Hand(2).BJvalue;
                        %Checking for dealer blackjack
                        if(dealer.Total == 21)
                            player.Bankroll(handNumber) = bankroll;
                        else
                            bankroll = bankroll + (betAmount * 1.5);
                            player.Bankroll(handNumber) = bankroll;
                        end
                        
                        
                    else
                        bankroll = bankroll + (betAmount * 1.5);
                        player.Bankroll(handNumber) = bankroll;
                    end
                    
                else

                   
                    while endHand == 0;

                        % IF player decides to stay with his current hand
                        %This will happen as soon as there is a chance of
                        %busting
                        %if the player doesnt have an ace and could bust by
                        %drawing another card he will stick
                        %ensuring the play sticks when he has a soft 17 and
                        %above
                        if(player.Ace == 0  && player.Total + 10 > 21 ||...
                                player.Ace > 0 && player.Total > 16)
                            dealer.Hand(2) = deck(deckPosition);
                            deckPosition = deckPosition +1;
                            dealer.Total = dealer.Total + dealer.Hand(2).BJvalue;
                            if(dealer.Hand(2).BJvalue == 11)
                                   dealer.Ace = dealer.Ace +1;
                                   %Checking for pair of aces
                                   if(dealer.Ace == 2)
                                       dealer.Total = dealer.Total - 10;
                                       dealer.Ace = dealer.Ace - 1;
                                   end
                            end
                            while dealer.Total < 17
                                dealer.Hand(end+1) = deck(deckPosition);
                                deckPosition = deckPosition +1;
                                if(dealer.Hand(end).BJvalue == 11)
                                   dealer.Ace = dealer.Ace +1;
                                end
                                dealer.Total = dealer.Total + dealer.Hand(end).BJvalue;
                                if(dealer.Total > 21 && dealer.Ace > 0)
                                    dealer.Total = dealer.Total - 10;
                                    dealer.Ace = dealer.Ace -1;
                                end
                            end
                            %determing the winner of the hand
                            if(dealer.Total > 21 || dealer.Total < player.Total)
                                bankroll = bankroll + 1;
                                player.Bankroll(handNumber) = bankroll;
                                endHand = 1;
                            elseif (dealer.Total > player.Total)
                                bankroll = bankroll - 1;
                                player.Bankroll(handNumber) = bankroll;
                                endHand = 1;
                            elseif (dealer.Total == player.Total)
                                player.Bankroll(handNumber) = bankroll;
                                endHand = 1;
                            end

                        else

                            player.Hand(end+1) = deck(deckPosition);
                            deckPosition = deckPosition +1; 
                            %checking if its an ace
                            if(strcmp(player.Hand(end).FaceValue, 'A'))
                                player.Ace = player.Ace +1;
                            end
                            player.Total = player.Hand(end).BJvalue + player.Total;
                            if(player.Total > 21 && player.Ace > 0)
                                player.Total = player.Total - 10;
                                player.Ace = player.Ace -1;
                            end

                        end
                    end
                end
            h = 1;
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
    title('Blackjack with Never Bust Strategy - 10000, 100 Game Sessions')
    ylabel('Profit/Loss') % x-axis label
    xlabel('Hand Number') % y-axis label
    hold on
    avLine = plot(avResults);
    set(avLine, 'LineWidth', 4);
    legend('Average Gain','Location','southwest')
    
end