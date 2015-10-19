function shuffledDeck = ShuffleDeck(deck)

randPosition = randperm(length(deck));
shuffledDeck = deck;
for i =1:length(deck)
    shuffledDeck(i) = deck(randPosition(i));
end
