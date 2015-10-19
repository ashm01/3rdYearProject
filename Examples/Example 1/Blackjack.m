%Blackjack Simulation Program, main function
%Written by Mike Iori
%Last updated 10/26/07

%Initializing constants
close all;
clear all;
clear global;
clear functions;
clc;

global CARDS;
global BJODDS;
global BANKROLL;
global BJDEALER;
global BJPLAYER;
global BJBOARD;
global QUITGAME;

BJBOARD.MaxDelay = 3;

%Open the gui that allows the user to modify the defaults at the game's start
Init = BJInitValues;
BJBOARD.InitAutoPlay = Init.AutoPlay;
BJBOARD.InitBetSuggest = Init.BetSuggest;
BANKROLL.HandsLeft = Init.NumHands;
BANKROLL.Starting = Init.Bankroll;
BANKROLL.Unit = Init.BetUnit;
CARDS.DecksUsed = Init.NumDecks;
BJBOARD.Delays = BJBOARD.MaxDelay - BJBOARD.MaxDelay*Init.GameSpeed/100;
BJBOARD.PlotResults = Init.PlotResults;
clear Init;

%Use this to determine if it's a multi-deck game
if CARDS.DecksUsed == 1
    CARDS.MultiDeck = 0;
else CARDS.MultiDeck = 1;
end

%Initialize non-user modifiable variables
CARDS.Shuffle = 1;              %Cards Shuffle when = 1

BANKROLL.History = BANKROLL.Starting;   %Maintains Bankroll history
BANKROLL.Bet = BANKROLL.Unit;   %Initial Bet

QUITGAME = 0;                   %Program ends when 1
FirstHand = 1;
AllVisible = 0;                 %When 1, all objects will be displayed on the board (for debug)

BJBOARD.Color = [0 .7 0];         %Defines the background color of the board
BJBOARD.csize = 2;                %Card Size
BJBOARD.xIncrement = .6;          %The increment in x direction between dealt cards

%Call the function that creates the playing board
handles = BJCreateBoard(AllVisible);
pause(.2);
clear AllVisible

try
    while ~QUITGAME
        %Randomly prepares array of cards by suit and value when necessary
        %CardCount keeps track of how many cards of each value remain in the
        %deck.
        if CARDS.Shuffle == 1
            ShuffleCards(CARDS.DecksUsed);
            CARDS.Shuffle = 0;
            CARDS.CardsLeft = CARDS.DecksUsed * 52;
            CARDS.NextCard = 1;                  %Next card to be dealt
            BJODDS.HiLoCount = 0;                %Keeps track of the card counting using
            %the Hi-Lo counting system
            BJODDS.RunningCount = 0;             %Number of Cards that have been distributed
            BJODDS.TrueCount = 0;                %HiLoCount divided by number of remaining decks
        end

        %Variables initialized with every hand
        BJPLAYER.Total = 0;     %Player's Card Total
        BJDEALER.Total = 0;     %Dealer's Card Total
        BJPLAYER.Ace = 0;       %Becomes 1 if Player has an Ace used as 11
        BJDEALER.Ace = 0;       %Becomes 1 if Dealer has an Ace used as 11
        BJPLAYER.Hand=[];       %Player's Hand
        BJDEALER.Hand=[];       %Dealer's Hand
        BJPLAYER.handle=[];     %Player's card handles
        BJDEALER.handle=[];     %Dealer's card handles
        BJPLAYER.Blackjack = 0; %Becomes 1 if Player has Blackjack
        BJDEALER.Blackjack = 0; %Becomes 1 if Dealer has Blackjack
        BJPLAYER.Bust = 0;      %Becomes 1 if Player Busts
        BJDEALER.Bust = 0;      %Becomes 1 if Dealer Busts
        BJPLAYER.NumCards = 0;  %Number of cards the player holds
        BJDEALER.NumCards = 0;  %Number of cards the dealer holds
        endhand = 0;          %If not 0, hand ends
        BJPLAYER.x(1) = 2;      %Initialize Player's Card Coordinates
        BJPLAYER.y(1) = 0;
        BJPLAYER.x(2) = 2;      %Player's 2nd hand coordinates for splitting
        BJPLAYER.y(2) = 1.2;
        BJDEALER.x = 2;         %Initializes Dealer's Card Coordinates
        BJDEALER.y = 3;
        BJPLAYER.Winner = 0;    %0=push, 1=Player wins, 2=Dealer wins
        BJPLAYER.Splits = 0;    %Becomes 1 if the player has used his one split
        BJPLAYER.CurrentHand = 1; %Always 1, unless playing the 2nd hand after a split

        %Wait for the player to press the Deal or Quit button on the first hand
        if FirstHand
            %Set starting money to be the current bankroll
            BANKROLL.Money = BANKROLL.Starting;

            %If not autoplaying, wait for user input.  Otherwise, do nothing to
            %deal
            if ~get(handles.AutoPlayChkbx,'value')
                uiwait(gcf);
            end

            %if get(handles.QuitButton,'UserData')
            %    close all;
            %    return
            %end
            set(handles.DealButton,'visible','off');
            set(handles.QuitButton,'visible','off');
            set(handles.ResultTxt,'visible','off');
        end

        %Determine Player's wager
        if (BANKROLL.Money > 0)
            BANKROLL.Bet = str2double(get(handles.BetBox,'string'));
            if (BANKROLL.Bet > BANKROLL.Money)
                BANKROLL.Bet = BANKROLL.Money;
                set(handles.BetBox,'string',num2str(BANKROLL.Bet));
            elseif (BANKROLL.Bet <= 0) && (BANKROLL.Money >= BANKROLL.Unit)
                BANKROLL.Bet = BANKROLL.Unit;
                set(handles.BetBox,'string',num2str(BANKROLL.Bet));
            elseif (BANKROLL.Bet <= 0)
                BANKROLL.Bet = BANKROLL.Money;
            end
        else
            endhand = 1;
            set(handles.OutofMoneyTxt,'visible','on');
        end

        %This defines the action of each hand
        if ~endhand
            %Deal 2 Cards to player
            %First Card
            BJDealCard('player');
            %Second Card
            BJDealCard('player');

            %Check Player's Hand for ace/blackjack and compensate for it
            if (CARDS.Value(CARDS.NextCard-2) == 1)
                BJPLAYER.Total = BJPLAYER.Total + 10;
                BJPLAYER.Ace = 1;
            elseif (CARDS.Value(CARDS.NextCard-1) == 1)
                BJPLAYER.Total = BJPLAYER.Total + 10;
                BJPLAYER.Ace = 1;
            end
            if BJPLAYER.Total == 21
                set(handles.PlayerBJTxt,'visible','on');
                endhand = 1;
                BJPLAYER.Blackjack = 1;
            end
            set(handles.PlayerTotalTxt, 'string', ['Your Total : ' num2str(BJPLAYER.Total)]);

            %Deal 2 Cards to dealer, first is face down
            %First Card
            BJDealCard('dealer',1);
            %Second Card
            BJDealCard('dealer');

            %Check Dealer's Hand for ace/blackjack and compensate for it
            if (CARDS.Value(CARDS.NextCard-2) == 1)
                BJDEALER.Total = BJDEALER.Total + 10;
                BJDEALER.Ace = 1;
            elseif (CARDS.Value(CARDS.NextCard-1) == 1)
                BJDEALER.Total = BJDEALER.Total + 10;
                BJDEALER.Ace = 1;
            end
            set(handles.DealerTotalTxt,'string',['Dealer''s Total : ' num2str(CARDS.Value(CARDS.NextCard - 1)) '+']);
            if (BJDEALER.Total == 21)
                if BJPLAYER.Blackjack
                    set(handles.BothBJTxt,'visible','on');
                else
                    set(handles.DealerBJTxt,'visible','on');
                end
                %Show down card if dealer has Blackjack
                CardPlot(BJDEALER.handle(1,:),[],[],CARDS.Value(CARDS.NextCard-1),CARDS.Suit(CARDS.NextCard-1));

                set(handles.DealerTotalTxt,'string',['Dealer''s Total : ' num2str(BJDEALER.Total)]);
                endhand = 1;
                BJDEALER.Blackjack = 1;
            end

            %If player has blackjack, show the dealer's down card
            if BJPLAYER.Blackjack == 1
                CardPlot(BJDEALER.handle(1,:),[],[],CARDS.Value(CARDS.NextCard-1),CARDS.Suit(CARDS.NextCard-1));
            end
        end

        %Update Hi-Lo Count with newly distributed cards (except face down
        %card)
        for n = CARDS.NextCard-4 : CARDS.NextCard-1
            if n ~= (CARDS.NextCard-2)
                switch CARDS.Rank(n)
                    case {2, 3, 4, 5, 6}
                        BJODDS.HiLoCount = BJODDS.HiLoCount + 1;
                    case {7, 8, 9}
                        BJODDS.HiLoCount = BJODDS.HiLoCount;
                    case {10, 11, 12, 13, 1}
                        BJODDS.HiLoCount = BJODDS.HiLoCount - 1;
                end
            end
        end

        %Player's Turn
        while ~endhand
            %Display of Probabilities (Hi-Lo Counting System)
            BJUpdateHiLoCount(handles);

            %Determination of Strategy Suggestion.  Value is set to
            %BJODDS.Suggest
            [BJODDS.Suggest, BJODDS.SuggestNum] = BJSuggest(get(handles.UseCountChkbx,'Value'),BJPLAYER.CurrentHand);

            %Output Strategy Suggestion
            set(handles.SuggestionTxt, 'string',['   ',BJODDS.Suggest]);

            %Make Selection Buttons visible
            set(handles.HitButton,'visible','on');
            set(handles.StandButton,'visible','on');
            set(handles.DoubleButton,'visible','off');
            set(handles.SplitButton,'visible','off');
            if BJPLAYER.NumCards(BJPLAYER.CurrentHand) == 2
                if (CARDS.Value(BJPLAYER.Hand(BJPLAYER.CurrentHand,1)) == CARDS.Value(BJPLAYER.Hand(BJPLAYER.CurrentHand,2))) && ~BJPLAYER.Splits
                    set(handles.SplitButton,'visible','on');
                end
                set(handles.DoubleButton,'visible','on');
            end

            %Wait for Hit, Stand, Double, or Split button to be pressed
            if BJPLAYER.Total(BJPLAYER.CurrentHand) < 21
                %If not on autoplay, wait for user input.  Otherwise, use
                %results from BJSuggest
                if ~get(handles.AutoPlayChkbx,'value')
                    uiwait(gcf);
                else
                    pause(BJBOARD.Delays);
                    BJPLAYER.hitorstand = BJODDS.SuggestNum;
                end
            else BJPLAYER.hitorstand = 2; %If player already has 21, just stand
            end

            %If the player hits or doubles down, deal another card
            if (BJPLAYER.hitorstand == 1) || (BJPLAYER.hitorstand == 3)
                %Call the hit function
                BJPlayerHits(handles);

                %Update the count
                BJUpdateHiLoCount(handles,CARDS.NextCard-1)

                %If it was a double down break to end the player's turn
                if BJPLAYER.hitorstand == 3
                    break
                end
            end

            %If the player stands or has already busted or hit 21, player's
            %turn ends unless he split and has another hand to go
            if ((BJPLAYER.hitorstand == 2) || (BJPLAYER.Total(BJPLAYER.CurrentHand) >= 21))
                if (~BJPLAYER.Splits || ((BJPLAYER.Splits+1) == BJPLAYER.CurrentHand))
                    break
                elseif (BJPLAYER.Splits+1) > BJPLAYER.CurrentHand
                    BJPLAYER.CurrentHand = BJPLAYER.CurrentHand + 1;
                    set(handles.PlayerTotalSplitTxt(1),'foregroundcolor',[.5 .5 .5]);
                    set(handles.PlayerTotalSplitTxt(2),'foregroundcolor',[0 0 0]);
                end
            end

            %If the player has split, re-distribute his two cards, and play
            %both new hands
            if (BJPLAYER.hitorstand == 4)
                BJPLAYER.Splits = BJPLAYER.Splits + 1;

                %Double the bet
                BANKROLL.Bet(2) = BANKROLL.Bet(1);
                %Can't get blackjack after a split
                BJPLAYER.Blackjack(1:2) = 0;

                %Move player's two cards
                %First remove the originals
                for index = 1:BJPLAYER.NumCards(BJPLAYER.CurrentHand)
                    CardPlot(BJPLAYER.handle(index,:),[],[],-1,[]);
                end
                BJPLAYER.handle = [];

                %Redraw them smaller
                BJPLAYER.x(1) = BJPLAYER.x(2);
                [BJPLAYER.handle(1,:,1),BJPLAYER.Cardx(1,1),BJPLAYER.Cardy(1,1)]...
                    = CardPlot(BJPLAYER.x(1),BJPLAYER.y(1),BJBOARD.csize/2,CARDS.Rank(CARDS.NextCard-4),CARDS.Suit(CARDS.NextCard-4));
                [BJPLAYER.handle(1,:,2),BJPLAYER.Cardx(2,1),BJPLAYER.Cardy(2,1)]...
                    = CardPlot(BJPLAYER.x(2),BJPLAYER.y(2),BJBOARD.csize/2,CARDS.Rank(CARDS.NextCard-3),CARDS.Suit(CARDS.NextCard-3));
                BJPLAYER.x(1) = BJPLAYER.x(1) + BJBOARD.xIncrement/2;
                BJPLAYER.x(2) = BJPLAYER.x(2) + BJBOARD.xIncrement/2;

                %If aces were split, the hand ends after two new cards are dealt
                %Also, set ace field to 1 and update the totals
                if (CARDS.Rank(BJPLAYER.Hand(1)) == 1) && (CARDS.Rank(BJPLAYER.Hand(2)) == 1)
                    endhand = 1;
                    BJPLAYER.Ace(1) = 1;
                    BJPLAYER.Ace(2) = 1;
                    BJPLAYER.Total(1) = 11;
                    BJPLAYER.Total(2) = 11;
                else
                    BJPLAYER.Ace(1) = 0;
                    BJPLAYER.Ace(2) = 0;
                    BJPLAYER.Total(1) = CARDS.Value(CARDS.NextCard-4);
                    BJPLAYER.Total(2) = CARDS.Value(CARDS.NextCard-3);
                end

                %Update player total outputs
                set(handles.PlayerTotalTxt,'visible','off');
                set(handles.PlayerTotalSplitTxt(1),'string',['Your Total : ' num2str(BJPLAYER.Total(1))],'visible','on','foregroundcolor',[0 0 0]);
                set(handles.PlayerTotalSplitTxt(2),'string',['Your Total : ' num2str(BJPLAYER.Total(2))],'visible','on');

                BJPLAYER.Hand = [];
                BJPLAYER.Hand(1,1) = CARDS.NextCard - 4;
                BJPLAYER.Hand(2,1) = CARDS.NextCard - 3;

                pause(BJBOARD.Delays)

                %Fix BJPLAYER.NumCards
                BJPLAYER.NumCards(1) = 1;
                BJPLAYER.NumCards(2) = 1;

                %Deal next 2 cards
                BJDealCard('player');
                pause(BJBOARD.Delays);
                BJPLAYER.CurrentHand = 2;
                BJDealCard('player');
                BJPLAYER.CurrentHand = 1;

                %Look for aces
                for n = 1:BJPLAYER.Splits+1
                    for m = 1:max(BJPLAYER.NumCards)
                        if (CARDS.Value(BJPLAYER.Hand(n,m)) == 1) && ~BJPLAYER.Ace(n)
                            BJPLAYER.Ace(n) = 1;
                            BJPLAYER.Total(n) = BJPLAYER.Total(n) + 10;
                        end
                    end
                end

                set(handles.PlayerTotalSplitTxt(1),'string',['Your Total : ' num2str(BJPLAYER.Total(1))]);
                set(handles.PlayerTotalSplitTxt(2),'string',['Your Total : ' num2str(BJPLAYER.Total(2))]);
                pause(BJBOARD.Delays);

                %Updates Hi-Lo Count with 2 new cards
                for n = CARDS.NextCard-2 : CARDS.NextCard-1
                    BJUpdateHiLoCount(handles,n);
                end
            end
        end

        for n = 1:BJPLAYER.Splits+1
            if BJPLAYER.Total(n) > 21
                set(handles.PlayerTotalTxt,'string','Your Total : Bust');
                set(handles.PlayerTotalSplitTxt(n),'string','Your Total : Bust');
                BJPLAYER.Bust(n) = 1;
            else
                BJPLAYER.Bust(n) = 0;
            end
        end

        set(handles.HitButton,'visible','off');
        set(handles.StandButton,'visible','off');
        set(handles.DoubleButton,'visible','off');
        set(handles.SplitButton,'visible','off');

        %Dealer's Turn
        %Flip dealer's down card and output his new total
        CardPlot(BJDEALER.handle(1,:),[],[],CARDS.Rank(BJDEALER.Hand(1)),CARDS.Suit(BJDEALER.Hand(1)));
        set(handles.DealerTotalTxt,'string',['Dealer''s Total : ' num2str(BJDEALER.Total)]);

        %Add down card to hi-lo count
        BJUpdateHiLoCount(handles,CARDS.NextCard-sum(BJPLAYER.NumCards));

        %Dealer hits on 16 or less and soft 17 (17 with Ace as 11) unless player
        %has busted or had blackjack
        while ((BJDEALER.Total < 17) || ((BJDEALER.Total == 17) && (BJDEALER.Ace))) && ~all(BJPLAYER.Bust) && ~all(BJPLAYER.Blackjack)
            BJDealerHits(handles);
        end

        %Check for dealer bust
        if BJDEALER.Total > 21
            set(handles.DealerTotalTxt,'string','Dealer''s Total : Bust');
            BJDEALER.Bust = 1;
        end

        %Determine who wins
        BJDetermineWinner;

        %Bankroll changes based on results, and update Result txt
        for n = 1:length(BJPLAYER.Winner)
            switch BJPLAYER.Winner(n)
                case 1
                    BANKROLL.Money = BANKROLL.Money + BANKROLL.Bet(n);
                    set(handles.ResultTxt,'string','You Won!','ForegroundColor',[0 1 0]);
                case 2
                    BANKROLL.Money = BANKROLL.Money - BANKROLL.Bet(n);
                    set(handles.ResultTxt,'string','You Lost!','ForegroundColor',[1 0 0]);
                otherwise
                    set(handles.ResultTxt,'string','It''s a Push','ForegroundColor',[1 1 0]);
            end
        end
        %Update result txt when player split
        if BJPLAYER.Splits
            if all(BJPLAYER.Winner == 1)
                set(handles.ResultTxt,'string','You Win Both!','ForegroundColor',[0 1 0]);
            elseif all(BJPLAYER.Winner == 2)
                set(handles.ResultTxt,'string','You Lose Both!','ForegroundColor',[1 0 0]);
            elseif all(BJPLAYER.Winner == 0)
                set(handles.ResultTxt,'string','You Push Both!','ForegroundColor',[1 1 0]);
            elseif any(BJPLAYER.Winner == 1) && any(BJPLAYER.Winner == 2)
                set(handles.ResultTxt,'string','Win one, Lose one!','ForegroundColor',[1 1 0]);
            elseif any(BJPLAYER.Winner == 1) && any(BJPLAYER.Winner == 0)
                set(handles.ResultTxt,'string','Win one, Push one!','ForegroundColor',[0 1 0]);
            elseif any(BJPLAYER.Winner == 0) && any(BJPLAYER.Winner == 2)
                set(handles.ResultTxt,'string','Push one, Lose one!','ForegroundColor',[1 0 0]);
            end
        end
        set(handles.ResultTxt,'visible','on');

        set(handles.BankrollTxt,'string',['Bankroll : $' num2str(BANKROLL.Money)]);
        if (BANKROLL.Money <= 0)
            QUITGAME = 1;
            set(handles.OutofMoneyTxt,'visible','on');
        end

        %Reduce # of hands to go by 1.  If we're now at 0, set endhand to 1.
        %If we were at 0 before, just keep going since there's no set # of
        %hands
        if BANKROLL.HandsLeft
            BANKROLL.HandsLeft = BANKROLL.HandsLeft - 1;
            set(handles.HandsLeftBox,'string',num2str(BANKROLL.HandsLeft));
            if ~BANKROLL.HandsLeft
                QUITGAME = 1;
            end
        end

        %Get ready for next hand
        if ~QUITGAME
            %Check Card Penetration
            %In single deck, shuffles after 66% of cards are used
            %In multi deck, shuffles after 75% of cards are used
            if (~CARDS.MultiDeck) && (CARDS.CardsLeft < (1/3*CARDS.DecksUsed*52))
                CARDS.Shuffle = 1;
                set(handles.ShuffleTxt,'visible','on');
            end
            if (CARDS.MultiDeck) && (CARDS.CardsLeft < (1/4*CARDS.DecksUsed*52))
                CARDS.Shuffle = 1;
                set(handles.ShuffleTxt,'visible','on');
            end

            %If the suggest bet box is checked, figure out what the next bet should
            %be based on the number of decks, and the true count.  Otherwise, leave
            %it at whatever it was set to before
            if get(handles.BetSuggestChkbx,'value')
                BJBetSuggest(handles);
            end

            %Ask player if he wants to deal again or quit unless we're on
            %autoplay
            if ~get(handles.AutoPlayChkbx,'value')
                set(handles.DealButton,'visible','on');
                set(handles.QuitButton,'visible','on');
                uiwait(gcf);
            else
                pause(BJBOARD.Delays);
            end
            if exist('handles','var') && get(handles.QuitButton,'UserData')
                QUITGAME = 1;
            end
        else
            pause(BJBOARD.Delays*2);
        end

        %Get ready for next hand
        FirstHand = 0;
        BANKROLL.Bet = str2double(get(handles.BetBox,'string'));

        %Clear the extra stuff from the board to prepare for the next hand
        %Remove the player's cards
        for m = 1:length(BJPLAYER.NumCards)
            for n = 1:BJPLAYER.NumCards(m)
                CardPlot(BJPLAYER.handle(n,:,m),[],[],-1,[]);
            end
        end

        %Remove the dealer's cards
        for n = 1:BJDEALER.NumCards
            CardPlot(BJDEALER.handle(n,:),[],[],-1,[]);
        end

        %Clear the hand results
        set(handles.SuggestionTxt,'string','');
        set(handles.ResultTxt,'string','');
        set(handles.PlayerTotalTxt,'string','','visible','on');
        set(handles.PlayerTotalSplitTxt(1),'visible','off');
        set(handles.PlayerTotalSplitTxt(2),'visible','off');
        set(handles.DealerTotalTxt,'string','');
        set(handles.DealButton,'visible','off');
        set(handles.QuitButton,'visible','off');
        set(handles.PlayerBJTxt,'visible','off');
        set(handles.DealerBJTxt,'visible','off');
        set(handles.BothBJTxt,'visible','off');
        set(handles.OutofMoneyTxt,'visible','off');
        set(handles.NoDDMoneyTxt,'visible','off');
        set(handles.ShuffleTxt,'visible','off');

        BANKROLL.History(end+1) = BANKROLL.Money;
    end

    close all;
    delete(gcf); 
catch return
end

%Plot the results if necessary
if BJBOARD.PlotResults
    %Plot the Bankroll vs. Hand Number
    handles.Plot = figure(1);
    subplot(2,1,1);
    plot(0:length(BANKROLL.History)-1,BANKROLL.History,'-','Color',[0 .6 0]);
    hold on;
    plot(0:length(BANKROLL.History)-1,ones(1,length(BANKROLL.History))*BANKROLL.Starting,'--','Color',[1 0 0]);
    title('Player''s Bankroll vs. Hand Number');
    xlabel('Hand Number');
    ylabel('Player Bankroll ($)');

    %Plot a histogram of the amount of money won per hand
    subplot(2,1,2);
    BANKROLL.SortedHistory = sort(diff(BANKROLL.History));
    BANKROLL.SortedHistoryOptions = unique(BANKROLL.SortedHistory);
    for index = 1:length(BANKROLL.SortedHistoryOptions)
        BANKROLL.HistoryBar(index) = length(find(BANKROLL.SortedHistory == BANKROLL.SortedHistoryOptions(index)));
        BANKROLL.HistoryBarIndex(index) = BANKROLL.SortedHistoryOptions(index)/BANKROLL.Unit;
    end
    bar(BANKROLL.HistoryBarIndex,BANKROLL.HistoryBar,1);
    title('Money won per hand, in units')
    xlabel('Amount of Money won (Bet Units)')
    ylabel('Number of Hands')
end
