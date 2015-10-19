function BJUpdateHiLoCount(handles,CardSpot)
%Updates the Hi-Lo count, where CardSpot is the location of the card in the
%Card.Rank array that is to be counted
%If CardSpot does not exist, only the statistics will be updated

global BJODDS
global CARDS

if exist('CardSpot','var')
    switch CARDS.Rank(CardSpot)
        case {2, 3, 4, 5, 6}
            BJODDS.HiLoCount = BJODDS.HiLoCount + 1;
        case {7, 8, 9}
            BJODDS.HiLoCount = BJODDS.HiLoCount;
        case {10, 11, 12, 13, 1}
            BJODDS.HiLoCount = BJODDS.HiLoCount - 1;
    end
end

%Card Count - Hi-Lo Counting System
set(handles.HiLoTxt,'string',['Hi-Lo Count =' num2str(BJODDS.HiLoCount)]);
BJODDS.RunningCount = CARDS.NextCard - 1;
set(handles.RunningCntTxt,'string',['Running Count =' num2str(BJODDS.RunningCount)]);
BJODDS.TrueCount = BJODDS.HiLoCount / (CARDS.CardsLeft/52);
set(handles.TrueCntTxt,'string',['True Count = ' num2str(BJODDS.TrueCount,'%2.3f')]);
BJSetTrueCntColor(handles);