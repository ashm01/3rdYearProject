function handles = BJCreateBoard(AllVisible)
%Creates the Blackjack Playing Board

global BANKROLL;
global BJBOARD;

Creator = 'Mike Iori';
Date = '02/10/07';

close all;
handles.Main = gcf;

set(handles.Main,'name','Blackjack','menubar','none','numbertitle','off');

BJBOARD.pos=get(gcf,'pos');
BJBOARD.scr=get(0,'screensize');

set(handles.Main,'pos',[BJBOARD.scr(3:4)*.1 760 680]);

CardPlot([0 7 0 5],BJBOARD.Color);
hold on;

handles.Author = uicontrol('style','text','string',strcat('Created By:  ',Creator),'pos',[650 15 115 15],'fontsize',8,'backgroundcolor',get(gcf,'color'));
handles.Date = uicontrol('style','text','string',Date,'pos',[715 0 50 15],'fontsize',8,'backgroundcolor',get(gcf,'color'));
handles.DealerText = text(5,4,'Dealer','fontsize',40,'color',[0 .65 0],'horiz','c','vert','t');
handles.YouText=text(5,.6,'You','fontsize',40,'color',[0 .65 0],'horiz','c','vert','bo');
handles.InfoTxt = uicontrol('style','text','string','Information:','pos',[5 450 120 30],'fontsize',15,'horiz','l','backgroundcolor',BJBOARD.Color);
handles.HiLoTxt = uicontrol('style','text','string','Hi-Lo Count = 0','pos',[5 430 120 20],'horiz','l','backgroundcolor',BJBOARD.Color);
handles.RunningCntTxt = uicontrol('style','text','string','Running Count = 0','pos',[5 410 120 20],'horiz','l','backgroundcolor',BJBOARD.Color);
handles.TrueCntTxt = uicontrol('style','text','string','True Count = 0','pos',[5 390 120 20],'horiz','l','backgroundcolor',BJBOARD.Color);
handles.UseCountChkbx = uicontrol('style','checkbox','string','Use Count','pos',[5 375 85 20],'fontsize',10,'horiz','l','backgroundcolor',BJBOARD.Color,'value',1);
handles.SuggestionTitleTxt = uicontrol('style','text','string','Suggestion:','pos',[5 330 150 20],'fontsize',12,'horiz','l','backgroundcolor',BJBOARD.Color);
handles.SuggestionTxt = uicontrol('style','text','string','...','pos',[5 310 150 20],'fontsize',15,'horiz','l','backgroundcolor',BJBOARD.Color);
handles.HitButton = uicontrol('style','pushbutton','string','Hit','Position', [20 250 80 20],'fontsize',12,'visible','off','Callback','BJActionSelect(1);');
handles.StandButton = uicontrol('style','pushbutton','string','Stand','Position', [20 220 80 20],'fontsize',12,'visible','off','Callback','BJActionSelect(2);');
handles.DoubleButton = uicontrol('style','pushbutton','string','Double','Position', [20 190 80 20],'fontsize',12,'visible','off','Callback','BJActionSelect(3);');
handles.SplitButton = uicontrol('style','pushbutton','string','Split','Position', [20 160 80 20],'fontsize',12,'visible','off','Callback','BJActionSelect(4);');
handles.BetTxt = uicontrol('style','text','string','Bet:        $','pos',[0 20 150 20],'fontsize',15,'horiz','l','backgroundcolor',get(gcf,'color'));    %Bet string
handles.BetBox = uicontrol('style','edit','string',BANKROLL.Bet,'pos',[98 15 60 25],'fontsize',15,'horiz','l','backgroundcolor','white');    %Bet edit box
handles.BetSuggestChkbx = uicontrol('style','checkbox','string','Suggest Bet','pos',[5 70 100 20],'fontsize',10,'horiz','l','backgroundcolor',BJBOARD.Color,'value',BJBOARD.InitBetSuggest,'Callback','BJBetSuggest(handles)');
handles.DealButton = uicontrol('style','pushbutton','string','Deal','pos',[10 170 60 25],'fontsize',20,'horiz','r','backgroundcolor',[0 .8 .5],'Callback','uiresume(gcf)');    %Deal Pushbutton
handles.QuitButton = uicontrol('style','pushbutton','string','Quit','pos',[700 75 60 25],'fontsize',20,'horiz','r','backgroundcolor',[1 0 0],'UserData',0,'Callback','QuitGame');    %Quit Pushbutton
handles.PlayerTotalTxt = uicontrol('style','text','string','Your Total :','pos',[250 300 180 20],'fontsize',15,'horiz','l','backgroundcolor',BJBOARD.Color);   %Player's total
handles.PlayerTotalSplitTxt(1) = uicontrol('style','text','string','Your Total :','pos',[250 180 180 15],'fontsize',10,'horiz','l','foregroundcolor',[.5 .5 .5],'backgroundcolor',BJBOARD.Color,'visible','off');   %Player's total for hand 1 when splitting
handles.PlayerTotalSplitTxt(2) = uicontrol('style','text','string','Your Total :','pos',[250 310 180 15],'fontsize',10,'horiz','l','foregroundcolor',[.5 .5 .5],'backgroundcolor',BJBOARD.Color,'visible','off');   %Player's total for hand 2 when splitting
handles.BankrollTxt = uicontrol('style','text','string',['Bankroll :$ ' num2str(BANKROLL.Starting)],'pos',[0 45 200 20],'fontsize',15,'horiz','l','backgroundcolor',get(gcf,'color'));
handles.DealerTotalTxt = uicontrol('style','text','string','Dealer''s Total :','pos',[220 360 180 20],'fontsize',15,'horiz','l','backgroundcolor',BJBOARD.Color);
handles.ResultTxt = uicontrol('style','text','string','','pos',[230 325 200 25],'fontsize',15,'horiz','c','backgroundcolor',BJBOARD.Color);
handles.PlayerBJTxt = uicontrol('style','text','string','You have BlackJack!','pos',[10 140 205 25],'fontsize',15,'horiz','l','foregroundcolor',[0 1 0],'backgroundcolor',BJBOARD.Color,'visible','off');
handles.DealerBJTxt = uicontrol('style','text','string','Dealer has BlackJack!','pos',[10 140 205 25],'fontsize',15,'horiz','l','foregroundcolor',[1 0 0],'backgroundcolor',BJBOARD.Color,'visible','off');
handles.BothBJTxt = uicontrol('style','text','string','Both players have BJ!','pos',[10 140 205 25],'fontsize',15,'horiz','l','foregroundcolor',[1 1 0],'backgroundcolor',BJBOARD.Color,'visible','off');
handles.OutofMoneyTxt = uicontrol('style','text','string','You''re out of money!','pos',[10 110 205 25],'fontsize',15,'horiz','l','backgroundcolor',BJBOARD.Color,'visible','off');
handles.NoDDMoneyTxt = uicontrol('style','text','string','Can''t Double Down!','pos',[10 110 205 25],'fontsize',15,'horiz','l','backgroundcolor',BJBOARD.Color,'visible','off');
handles.ShuffleTxt = uicontrol('style','text','string','Shuffling...','pos',[320 30 100 25],'fontsize',15,'horiz','l','foregroundcolor',[1 0 1],'backgroundcolor',get(gcf,'color'),'visible','off');
handles.AutoPlayChkbx = uicontrol('style','checkbox','string','AutoPlay','pos',[680 592 85 20],'fontsize',12,'horiz','l','backgroundcolor',BJBOARD.Color,'value',BJBOARD.InitAutoPlay);
handles.HandsLeftBox = uicontrol('style','edit','string',num2str(BANKROLL.HandsLeft),'pos',[720 570 40 20],'Callback','HandsLeft(handles)');
handles.HandsLeftTxt = uicontrol('style','text','string','Hands Left:','pos',[660 570 60 15],'backgroundcolor',BJBOARD.Color);
if ~BANKROLL.HandsLeft
    set(handles.HandsLeftBox,'string','');
end

%This is used for debugging only.  It makes each normally invisible field visible.
if AllVisible
    set(handles.HitButton,'visible','on');
    set(handles.StandButton,'visible','on');
    set(handles.DoubleButton,'visible','on');
    set(handles.DealButton,'visible','on');
    set(handles.QuitButton,'visible','on');
    set(handles.PlayerTotalSplitTxt(1),'visible','on');
    set(handles.PlayerTotalSplitTxt(2),'visible','on');
    set(handles.PlayerBJTxt,'visible','on');
    set(handles.DealerBJTxt,'visible','on');
    set(handles.BothBJTxt,'visible','on');
    set(handles.OutofMoneyTxt,'visible','on');
    set(handles.NoDDMoneyTxt,'visible','on');
    set(handles.ShuffleTxt,'visible','on');
    set(handles.ResultTxt,'visible','on');
end
