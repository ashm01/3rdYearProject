function deck = CreateDeck(numOfDecks)
numOfCards = numOfDecks*52;
deck(numOfCards) = struct ('Rank', [], 'Suit',[]);

for deckNum = 1:52:numOfCards
    for suit = 0:3   
        for rank=0:12
            position = deckNum+(suit*13)+rank;
            deck(position).SuitValue = suit+1;
            deck(position).Rank = rank+1;
            %I chage the the ace and 10's in the switch statement
            deck(position).BJvalue = rank+1;
            switch suit
                case 0
                    deck(position).Suit = 'c';
                case 1
                    deck(position).Suit = 'd';
                case 2
                    deck(position).Suit = 'h';
                case 3
                    deck(position).Suit = 's';
            end
                    
            switch rank
                case 0
                    deck(position).FaceValue = 'A';
                    deck(position).BJvalue = 11;
                    deck(position).ZenValue = -1;
                    deck(position).HiLoValue = -1;
                    deck(position).KISSValue = -1;
                    deck(position).KOValue = -1;
                    deck(position).OmegaValue = 0;
                    deck(position).WongValue = -1;
                case 1
                    deck(position).FaceValue = '2';
                    deck(position).ZenValue = 1;
                    deck(position).HiLoValue = 1;
                    deck(position).KOValue = 1;
                    deck(position).OmegaValue = 1;
                    deck(position).WongValue = 0.5;
                    %KISS card counting has different values dependant on
                    %the suits of decues
                    if(deck(position).Suit == 'c' || deck(position).Suit == 's')
                        deck(position).KISSValue = 1;
                    else
                        deck(position).KISSValue = 0;
                    end
                case 2
                    deck(position).FaceValue = '3';
                    deck(position).ZenValue = 1;
                    deck(position).HiLoValue = 1;
                    deck(position).KISSValue = 1;
                    deck(position).KOValue = 1;
                    deck(position).OmegaValue = 1;
                    deck(position).WongValue = 1;
                case 3
                    deck(position).FaceValue = '4';
                    deck(position).ZenValue = 2;
                    deck(position).HiLoValue = 1;
                    deck(position).KISSValue = 1;
                    deck(position).KOValue = 1;
                    deck(position).OmegaValue = 2;
                    deck(position).WongValue = 1;
                case 4
                    deck(position).FaceValue = '5';
                    deck(position).ZenValue = 2;
                    deck(position).HiLoValue = 1;
                    deck(position).KISSValue = 1;
                    deck(position).KOValue = 1;
                    deck(position).OmegaValue = 2;
                    deck(position).WongValue = 1.5;
                case 5
                    deck(position).FaceValue = '6';
                    deck(position).ZenValue = 2;
                    deck(position).HiLoValue = 1;
                    deck(position).KISSValue = 1;
                    deck(position).KOValue = 1;
                    deck(position).OmegaValue = 2;
                    deck(position).WongValue = 1;
                case 6
                    deck(position).FaceValue = '7';
                    deck(position).ZenValue = 1;
                    deck(position).HiLoValue = 0;
                    deck(position).KISSValue = 1;
                    deck(position).KOValue = 1;
                    deck(position).OmegaValue = 1;
                    deck(position).WongValue = 0.5;
                case 7
                    deck(position).FaceValue = '8';
                    deck(position).ZenValue = 0;
                    deck(position).HiLoValue = 0;
                    deck(position).KISSValue = 0;
                    deck(position).KOValue = 0;
                    deck(position).OmegaValue = 0;
                    deck(position).WongValue = 0;
                case 8
                    deck(position).FaceValue = '9';
                    deck(position).ZenValue = 0;
                    deck(position).HiLoValue = 0;
                    deck(position).KISSValue = 0;
                    deck(position).KOValue = 0;
                    deck(position).OmegaValue = -1;
                    deck(position).WongValue = -0.5;
                case 9
                    deck(position).FaceValue = '10';
                    deck(position).ZenValue = -2;
                    deck(position).HiLoValue = -1;
                    deck(position).KISSValue = -1;
                    deck(position).KOValue = -1;
                    deck(position).OmegaValue = -2;
                    deck(position).WongValue = -1;
                case 10
                    deck(position).FaceValue = 'J';
                    deck(position).BJvalue = 10;
                    deck(position).ZenValue = -2;
                    deck(position).HiLoValue = -1;
                    deck(position).KISSValue = -1;
                    deck(position).KOValue = -1;
                    deck(position).OmegaValue = -2;
                    deck(position).WongValue = -1;
                case 11
                    deck(position).FaceValue = 'Q';
                    deck(position).BJvalue = 10;
                    deck(position).ZenValue = -2;
                    deck(position).HiLoValue = -1;
                    deck(position).KISSValue = -1;
                    deck(position).KOValue = -1;
                    deck(position).OmegaValue = -2;
                    deck(position).WongValue = -1;
                case 12
                    deck(position).FaceValue = 'K';
                    deck(position).BJvalue = 10;
                    deck(position).ZenValue = -2;
                    deck(position).HiLoValue = -1;
                    deck(position).KISSValue = -1;
                    deck(position).KOValue = -1;
                    deck(position).OmegaValue = -2;
                    deck(position).WongValue = -1;
            end
            
            
        end
    end
end
end