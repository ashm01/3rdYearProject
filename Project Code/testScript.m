test = zeros(100,100);
for i = 1: 100      
    res = BlackjackBasic(4,100,1);
    test(i,:) = res;
end