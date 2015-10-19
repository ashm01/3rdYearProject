function [Suggest,SuggestNum] = BJSuggest(UseCount, varargin)
%This function uses the Player, Dealer, BJOdds and Cards structures to determine
%the ideal course of action for the player.  Suggestions can be to Hit,
%Stand, Double Down, or Split
%If UseCount is 1, then the suggestion will be made taking the Card Count
%into consideration.  Otherwise, it won't.
%varargin is an optional input.  If the player has split, this will be
%either a 1 or 2 to determine which hand needs to be analyzed.  Otherwise,
%it is assumed that there was no split and hand 1 will be analyzed.

global BJPLAYER
global BJDEALER
global CARDS
global BJODDS

if nargin > 1
    x = double(cell2mat(varargin));
else x = 1;
end

BJDEALER.Card = CARDS.Value(BJDEALER.Hand(2));
BJPLAYER.Card1(x) = CARDS.Value(BJPLAYER.Hand(x,1));
BJPLAYER.Card2(x) = CARDS.Value(BJPLAYER.Hand(x,2));

%Strategy for Player Pairs
if (BJPLAYER.NumCards(x) == 2) && (BJPLAYER.Card1(x) == BJPLAYER.Card2(x)) && ~BJPLAYER.Splits
    if (BJPLAYER.Card1(x) == 1) && (BJPLAYER.Card2(x) == 1)
        Suggest = 'Split';
    elseif ((BJPLAYER.Card1(x) == 2) && (BJPLAYER.Card2(x) == 2)) || ((BJPLAYER.Card1(x) == 3) && (BJPLAYER.Card2(x) == 3))
        if (BJDEALER.Card >= 2) && (BJDEALER.Card <= 7)
            Suggest = 'Split';
        else Suggest = 'Hit';
        end
    elseif ((BJPLAYER.Card1(x) == 4) && (BJPLAYER.Card2(x) == 4))
        Suggest = 'Hit';
    elseif ((BJPLAYER.Card1(x) == 5) && (BJPLAYER.Card2(x) == 5))
        if (BJDEALER.Card >= 2) && (BJDEALER.Card <= 9)
            Suggest = 'Double';
        else Suggest = 'Hit';
        end
    elseif ((BJPLAYER.Card1(x) == 6) && (BJPLAYER.Card2(x) == 6))
        if (BJDEALER.Card >= 2) && (BJDEALER.Card <= 6)
            Suggest = 'Split';
        else Suggest = 'Hit';
        end
    elseif ((BJPLAYER.Card1(x) == 7) && (BJPLAYER.Card2(x) == 7))
        if (BJDEALER.Card >= 2) && (BJDEALER.Card <= 7)
            Suggest = 'Split';
        else Suggest = 'Hit';
        end
    elseif ((BJPLAYER.Card1(x) == 8) && (BJPLAYER.Card2(x) == 8))
        Suggest = 'Split';
    elseif ((BJPLAYER.Card1(x) == 9) && (BJPLAYER.Card2(x) == 9))
        if ((BJDEALER.Card >= 2) && (BJDEALER.Card <= 6)) || (BJDEALER.Card == 8) || (BJDEALER.Card == 9)
            Suggest = 'Split';
        else Suggest = 'Stand';
        end
    elseif ((BJPLAYER.Card1(x) == 10) && (BJPLAYER.Card2(x) == 10))
        Suggest = 'Stand';
    end

    %Strategy for Player's Soft Hands
elseif (BJPLAYER.NumCards(x) == 2) && ((BJPLAYER.Card1(x) == 1) || (BJPLAYER.Card2(x) == 1))
    %Sets non-Ace to BJPLAYER.Card4
    if (BJPLAYER.Card1(x) == 1)
        BJPLAYER.Card3(x) = 1;
        BJPLAYER.Card4(x) = BJPLAYER.Card2(x);
    else BJPLAYER.Card3(x) = 1;
        BJPLAYER.Card4(x) = BJPLAYER.Card1(x);
    end
    
    if (BJPLAYER.Card4(x) == 1)
        Suggest = 'Hit';
    elseif (BJPLAYER.Card4(x) == 2) || (BJPLAYER.Card4(x) == 3)
        if (BJDEALER.Card == 5) || (BJDEALER.Card == 6)
            Suggest = 'Double';
        else Suggest = 'Hit';
        end
    elseif (BJPLAYER.Card4(x) == 4) || (BJPLAYER.Card4(x) == 5)
        if (BJDEALER.Card == 4) || (BJDEALER.Card == 5) || (BJDEALER.Card == 6)
            Suggest = 'Double';
        else Suggest = 'Hit';
        end
    elseif (BJPLAYER.Card4(x) == 6)
        if (BJDEALER.Card >= 3) && (BJDEALER.Card <= 6)
            Suggest = 'Double';
        else Suggest = 'Hit';
        end
    elseif (BJPLAYER.Card4(x) == 7)
        if (BJDEALER.Card >= 3) && (BJDEALER.Card <= 6)
            Suggest = 'Double';
        elseif (BJDEALER.Card == 1) || (BJDEALER.Card == 2) || (BJDEALER.Card == 7) || (BJDEALER.Card == 8)
            Suggest = 'Stand';
        else Suggest = 'Hit';
        end
    elseif (BJPLAYER.Card4(x) == 8) || (BJPLAYER.Card4(x) == 9)
        Suggest = 'Stand';
    end

    %Strategy for Player's Hard Hands
elseif (BJPLAYER.Total(x) == 8) && (BJODDS.TrueCount >= 2) && (BJDEALER.Card == 6) && (BJPLAYER.NumCards(x) == 2) && UseCount
    Suggest = 'Double';
elseif (BJPLAYER.Total(x) == 8) && (BJODDS.TrueCount >= 3) && (BJDEALER.Card == 5) && (BJPLAYER.NumCards(x) == 2) && UseCount
    Suggest = 'Double';
elseif BJPLAYER.Total(x) <= 8
    Suggest = 'Hit';
elseif (BJPLAYER.Total(x) == 9) && (BJODDS.TrueCount >= 3) && (BJDEALER.Card == 2) && (BJPLAYER.NumCards(x) == 2) && UseCount
    Suggest = 'Double';
elseif BJPLAYER.Total(x) == 9
    if (BJDEALER.Card >= 3) && (BJDEALER.Card <= 6) && (BJPLAYER.NumCards(x) == 2)
        Suggest = 'Double';
    else Suggest = 'Hit';
    end
elseif (BJPLAYER.Total(x) == 10) && (BJODDS.TrueCount >= 3) && (BJDEALER.Card == 1) && (BJPLAYER.NumCards(x) == 2) && UseCount
    Suggest = 'Double';
elseif BJPLAYER.Total(x) == 10
    if (BJDEALER.Card >= 2) && (BJDEALER.Card <= 9) && (BJPLAYER.NumCards(x) == 2)
        Suggest = 'Double';
    else Suggest = 'Hit';
    end
elseif (BJPLAYER.Total(x) == 11) && (BJODDS.TrueCount >= 2) && (BJDEALER.Card == 1) && (BJPLAYER.NumCards(x) == 2) && UseCount
    Suggest = 'Double';
elseif BJPLAYER.Total(x) == 11
    if (BJDEALER.Card == 1) || (BJPLAYER.NumCards(x) ~= 2)
        Suggest = 'Hit';
    else Suggest = 'Double';
    end
elseif (BJPLAYER.Total(x) == 12) && (BJODDS.TrueCount >= 2) && ((BJDEALER.Card == 2) || (BJDEALER.Card == 3)) && UseCount
    Suggest = 'Stand';
elseif BJPLAYER.Total(x) == 12
    if (BJDEALER.Card == 4) || (BJDEALER.Card == 5) || (BJDEALER.Card == 6)
        Suggest = 'Stand';
    else Suggest = 'Hit';
    end
elseif (BJPLAYER.Total(x) == 13) && (BJODDS.TrueCount <= -1) && ((BJDEALER.Card == 2) || (BJDEALER.Card == 3)) && UseCount
    Suggest = 'Hit';
elseif (BJPLAYER.Total(x) == 16) && (BJPLAYER.NumCards(x) >= 3) && (BJODDS.TrueCount >= 2) && (BJDEALER.Card == 10) && UseCount
    Suggest = 'Stand';
elseif (BJPLAYER.Total(x) >= 13) && (BJPLAYER.Total(x) <= 16)
    if (BJDEALER.Card >= 2) && (BJDEALER.Card <= 6)
        Suggest = 'Stand';
    else Suggest = 'Hit';
    end
end

if ~exist('Suggest','var')
    Suggest = 'Stand';
end

switch Suggest
    case 'Hit'
        SuggestNum = 1;
    case 'Stand'
        SuggestNum = 2;        
    case 'Double'
        SuggestNum = 3;
    case 'Split'
        SuggestNum = 4;
end