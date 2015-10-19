function BJDealCard(recipient,facedown)
%This function will deal a card to the dealer
%recipient will be set to either 'player' or 'dealer'
%facedown should be 1 if dealing the dealer's face down card

global BJPLAYER
global BJDEALER
global CARDS
global BJBOARD

if ~exist('facedown','var') || ~facedown
    Rank = CARDS.Rank(CARDS.NextCard);
else
    Rank = 0;
end

switch recipient
    case 'player'
        BJPLAYER.NumCards(BJPLAYER.CurrentHand) = BJPLAYER.NumCards(BJPLAYER.CurrentHand) + 1;
        BJPLAYER.Hand(BJPLAYER.CurrentHand,BJPLAYER.NumCards(BJPLAYER.CurrentHand)) = CARDS.NextCard;
        [BJPLAYER.handle(BJPLAYER.NumCards(BJPLAYER.CurrentHand),:,BJPLAYER.CurrentHand),BJPLAYER.Cardx(BJPLAYER.NumCards(BJPLAYER.CurrentHand),BJPLAYER.CurrentHand),BJPLAYER.Cardy(BJPLAYER.NumCards(BJPLAYER.CurrentHand),BJPLAYER.CurrentHand)] ...
            = CardPlot(BJPLAYER.x(BJPLAYER.CurrentHand),BJPLAYER.y(BJPLAYER.CurrentHand),BJBOARD.csize/(BJPLAYER.Splits+1),CARDS.Rank(CARDS.NextCard),CARDS.Suit(CARDS.NextCard));           
        CARDS.CardCount(CARDS.Rank(CARDS.NextCard)) = CARDS.CardCount(CARDS.Rank(CARDS.NextCard)) - 1;
        BJPLAYER.x(BJPLAYER.CurrentHand) = BJPLAYER.x(BJPLAYER.CurrentHand) + BJBOARD.xIncrement/(BJPLAYER.Splits+1);
        BJPLAYER.Total(BJPLAYER.CurrentHand) = BJPLAYER.Total(BJPLAYER.CurrentHand) + CARDS.Value(CARDS.NextCard);
    case 'dealer'
        BJDEALER.NumCards = BJDEALER.NumCards + 1;
        BJDEALER.Hand(BJDEALER.NumCards) = CARDS.NextCard;
        [BJDEALER.handle(BJDEALER.NumCards,:),BJDEALER.Cardx(BJDEALER.NumCards),BJDEALER.Cardy(BJDEALER.NumCards)] ...
            = CardPlot(BJDEALER.x,BJDEALER.y,BJBOARD.csize,Rank,CARDS.Suit(CARDS.NextCard));
        CARDS.CardCount(CARDS.Rank(CARDS.NextCard)) = CARDS.CardCount(CARDS.Rank(CARDS.NextCard)) - 1;
        BJDEALER.x = BJDEALER.x+BJBOARD.xIncrement;
        BJDEALER.Total = BJDEALER.Total + CARDS.Value(CARDS.NextCard);
end

CARDS.NextCard = CARDS.NextCard + 1;
CARDS.CardsLeft = CARDS.CardsLeft - 1;