function BJSetTrueCntColor(handles)
%Sets the color of the True Count string that is output to the screen based
%on the value of it.  If it's very positive, it becomes more green.  If
%it's very negative, it becomes more red.  Near 0 it's yellow.

global BJODDS
peak = 10;  %Color will be most red/green when the count hits +/- of this value
red = 1;
green = 1;

if BJODDS.TrueCount < 0
    %decrease green content
    green = max(1-abs(BJODDS.TrueCount)/peak,0);
elseif BJODDS.TrueCount > 0
    %decrease red content
    red = max(1-BJODDS.TrueCount/peak,0);
end
    
set(handles.TrueCntTxt,'foregroundcolor',[red green 0]);