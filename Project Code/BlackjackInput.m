function BlackjackInput

    deck = CreateDeck(1);
    deck = ShuffleDeck(deck);
    
    deckPosition = 1;
    
    player = struct();
    dealer = struct();
    
    %Variables initialized with every hand
    player.Total = 0;     %Player's Card Total
    dealer.Total = 0;     %Dealer's Card Total
    player.Ace = 0;       %Becomes 1 if Player has an Ace used as 11
    dealer.Ace = 0;       %Becomes 1 if Dealer has an Ace used as 11
    %player.Hand=deck(1); %Player's Hand
    %dealer.Hand=struct(); %Dealer's Hand
    player.Blackjack = 0; %Becomes 1 if Player has Blackjack
    dealer.Blackjack = 0; %Becomes 1 if Dealer has Blackjack
    player.Bust = 0;      %Becomes 1 if Player Busts
    dealer.Bust = 0;      %Becomes 1 if Dealer Busts
    %end game condition        
    endGame = 0;
    
    
    while endGame == 0
       
        endHand = 0; %If not 0, hand ends
        promt = 'Play Game? Y or N : ';
        result = input(promt, 's');
        
        if(strcmp(result,'y'))||(strcmp(result,'Y'))
            
            player.Hand(1) = deck(deckPosition);
            deckPosition = deckPosition +1; 
            dealer.Hand(1) = deck(deckPosition);
            deckPosition = deckPosition +1;
            player.Hand(2) = deck(deckPosition);
            deckPosition = deckPosition +1;  
            disp(sprintf('%s %s%s %s%s','Your Hand is :',...
                player.Hand(1).FaceValue,player.Hand(1).Suit,...
                player.Hand(2).FaceValue,player.Hand(2).Suit));
            player.Total = player.Hand(1).BJvalue + player.Hand(2).BJvalue;
            %Checking for Blackjack
            disp(sprintf('%s %s','Hand Value is :',num2str(player.Total)));
            if(player.Total == 21)
                display('You have Blackjack! You Win!');
                endHand = 1; 
            end
            disp(sprintf('%s %s%s','Dealer Showing :',...
                dealer.Hand(1).FaceValue,dealer.Hand(1).Suit));
            dealer.Total = dealer.Hand(1).BJvalue;
            while endHand == 0;
                promt = 'Hit or stick? H or S : ';
                result = input(promt, 's');
                % IF player decides to stay with his current hand
                if(strcmp(result,'s'))||(strcmp(result,'S'))

                    dealer.Hand(2) = deck(deckPosition);
                    deckPosition = deckPosition +1;
                    disp(sprintf('%s %s%s','Dealer Drew :',...
                            dealer.Hand(end).FaceValue,dealer.Hand(end).Suit));
                    dealer.Total = dealer.Total + dealer.Hand(2).BJvalue;
                    disp(sprintf('%s %s','Dealers Hand Value is :',num2str(dealer.Total)));
                    while dealer.Total < 17
                        dealer.Hand(end+1) = deck(deckPosition);
                        deckPosition = deckPosition +1;
                        disp(sprintf('%s %s%s','Dealer Drew :',...
                            dealer.Hand(end).FaceValue,dealer.Hand(end).Suit));
                        dealer.Total = dealer.Total + dealer.Hand(end).BJvalue;
                    end
                    %determing the winner of the hand
                    if(dealer.Total > 21)
                        display('Dealer Bust. You Won!');
                        endHand = 1;
                    elseif (dealer.Total > player.Total)
                        display('Dealer Won. You Lost!');
                        endHand = 1;
                    elseif(dealer.Total < player.Total)
                        display('You Won!');
                        endHand = 1;
                    else
                        display('Stand!');
                        endHand = 1;
                    end
                    % If player draws another cards
                elseif (strcmp(result,'h'))||(strcmp(result,'H'))
                    
                    player.Hand(end+1) = deck(deckPosition);
                    deckPosition = deckPosition +1; 
                    disp(sprintf('%s %s%s','You Drew :',...
                            player.Hand(end).FaceValue,player.Hand(end).Suit));
                    player.Total = player.Hand(end).BJvalue + player.Total;
                    disp(sprintf('%s %s','Hand Value is :',num2str(player.Total)));
                    %Checking if player bust
                    if(player.Total > 21)
                        display('You Bust. You Lost!');
                        endHand = 1;
                    end

                else
                    warning('Invalid Input');
                end
            end
        
        elseif (strcmp(result,'n'))||(strcmp(result,'N'))
            endGame = 1;
        else
            warning('Invalid Input');
        end
            
    end
    
end