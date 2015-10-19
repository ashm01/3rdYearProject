function BJBetSuggest(handles)
%This function uses the True Count and number of decks in use to determine
%a suggestion for the bet to be made

global CARDS
global BJODDS
global BANKROLL

if get(handles.BetSuggestChkbx,'value')   %Only do this if the box is now checked
    if ~CARDS.Shuffle   %If cards aren't going to be shuffled
        if ~CARDS.MultiDeck
            if BJODDS.TrueCount < 1
                BANKROLL.Bet = BANKROLL.Unit;
            elseif BJODDS.TrueCount == 1
                BANKROLL.Bet = BANKROLL.Unit * 2;
            elseif BJODDS.TrueCount == 2
                BANKROLL.Bet = BANKROLL.Unit * 3;
            else BANKROLL.Bet = BANKROLL.Unit * 4;
            end
        else
            if BJODDS.TrueCount < 3
                BANKROLL.Bet = BANKROLL.Unit;
            elseif BJODDS.TrueCount == 3
                BANKROLL.Bet = BANKROLL.Unit * 2;
            elseif BJODDS.TrueCount == 4
                BANKROLL.Bet = BANKROLL.Unit * 3;
            else BANKROLL.Bet = BANKROLL.Unit * 4;
            end
        end
    else    %If cards will be shuffled, TrueCount will be 0
        BANKROLL.Bet = BANKROLL.Unit;
    end

    set(handles.BetBox,'string',num2str(BANKROLL.Bet));
end