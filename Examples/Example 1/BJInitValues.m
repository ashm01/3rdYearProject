function Init = BJInitValues
%Creates a GUI that allows the player to determine the initial values to be
%used in the game

%Initialize Default values
Init.AutoPlay = 0;
Init.BetSuggest = 0;
Init.NumHands = 0;
Init.Bankroll = 5000;
Init.BetUnit = 5;
Init.NumDecks = 1;
Init.GameSpeed = 50; %As a percentage
Init.PlotResults = 1;

BoxSize = [500 380 180 340];

%Initialize the box
color = [.2 .4 .6];
handles.IntroBox = gcf;
set(handles.IntroBox,'name','Blackjack Setup','menubar','none','numbertitle','off','color',color,'pos',BoxSize);

%Display the appropriate options and wait for the player to press Begin
handles.InitAutoPlayOpTxt = uicontrol('style','text','string','Autoplay Options:','fontsize',12,'pos',[5 BoxSize(4)-20 200 20],'backgroundcolor',color,'horiz','l');
handles.InitAutoPlayChkbx = uicontrol('style','checkbox','string','Autoplay','fontsize',8,'pos',[50 BoxSize(4)-40 100 20],'backgroundcolor',color,'value',Init.AutoPlay);
handles.InitBetSuggestChkbx = uicontrol('style','checkbox','string','Suggest Bet','fontsize',8,'pos',[50 BoxSize(4)-60 100 20],'value',Init.BetSuggest,'backgroundcolor',color);
handles.InitNumHandsTxt = uicontrol('style','text','string','Number of Hands:','fontsize',8,'pos',[0 BoxSize(4)-80 98 15],'backgroundcolor',color,'horiz','r');
handles.InitNumHandsBox = uicontrol('style','edit','string',num2str(Init.NumHands),'pos',[110 BoxSize(4)-80 50 18]);

handles.InitBankrollOpTxt = uicontrol('style','text','string','Bankroll Options:','fontsize',12,'pos',[5 BoxSize(4)-110 200 20],'backgroundcolor',color,'horiz','l');
handles.InitBankrollTxt = uicontrol('style','text','string','Bankroll:','fontsize',8,'pos',[0 BoxSize(4)-130 98 15],'backgroundcolor',color,'horiz','r');
handles.InitBankrollBox = uicontrol('style','edit','string',num2str(Init.Bankroll),'pos',[110 BoxSize(4)-130 50 18]);
handles.InitBetUnitTxt = uicontrol('style','text','string','Bet Unit:','fontsize',8,'pos',[0 BoxSize(4)-150 98 15],'backgroundcolor',color,'horiz','r');
handles.InitBetUnitBox = uicontrol('style','edit','string',num2str(Init.BetUnit),'pos',[110 BoxSize(4)-150 50 18]);

handles.InitCardOpTxt = uicontrol('style','text','string','Card Options:','fontsize',12,'pos',[5 BoxSize(4)-180 200 20],'background',color,'horiz','l');
handles.InitNumDecksTxt = uicontrol('style','text','string','Number of Decks:','fontsize',8','pos',[0 BoxSize(4)-200 98 15],'backgroundcolor',color,'horiz','r');
handles.InitNumDecksBox = uicontrol('style','edit','string',num2str(Init.NumDecks),'pos',[110 BoxSize(4)-200 50 18]);

handles.InitGamePlayOpTxt = uicontrol('style','text','string','Gameplay Options:','fontsize',12,'pos',[5 BoxSize(4)-230 200 20],'background',color,'horiz','l');
handles.InitGameSpeedTxt = uicontrol('style','text','string','Game Speed:','fontsize',8','pos',[0 BoxSize(4)-250 98 15],'backgroundcolor',color,'horiz','r');
handles.InitGameSpeedBox = uicontrol('style','edit','string',num2str(Init.GameSpeed),'pos',[110 BoxSize(4)-250 30 18],'horiz','l');
handles.InitGameSpeedTxt2 = uicontrol('style','text','string','%','fontsize',8','pos',[140 BoxSize(4)-250 20 15],'backgroundcolor',color);

handles.InitResultsOpTxt = uicontrol('style','text','string','Result Options:','fontsize',12,'pos',[5 BoxSize(4)-280 200 20],'background',color,'horiz','l');
handles.InitPlotResultsChkbx = uicontrol('style','checkbox','string','Plot Results','fontsize',8,'pos',[50 BoxSize(4)-300 100 20],'value',Init.PlotResults,'backgroundcolor',color);

handles.InitBegin = uicontrol('style','pushbutton','string','B E G I N','fontsize',12,'pos',[10 10 160 20],'callback','uiresume;');

uiwait;

%When begin is pressed, save the values to the appropriate place, while
%checking to make sure all inputs are numeric
Init.AutoPlay = get(handles.InitAutoPlayChkbx,'value');
Init.BetSuggest = get(handles.InitBetSuggestChkbx,'value');
if ~isempty(str2num(get(handles.InitNumHandsBox,'string')))
    Init.NumHands = str2num(get(handles.InitNumHandsBox,'string'));
end
if ~isempty(str2num(get(handles.InitBankrollBox,'string')))
    Init.StartingBankroll = str2num(get(handles.InitBankrollBox,'string'));
end
if ~isempty(str2num(get(handles.InitBetUnitBox,'string')))
    Init.BetUnit = str2num(get(handles.InitBetUnitBox,'string'));
end
if ~isempty(str2num(get(handles.InitNumDecksBox,'string')))
    Init.NumDecks = str2num(get(handles.InitNumDecksBox,'string'));
end
if ~isempty(str2num(get(handles.InitGameSpeedBox,'string')))
    Init.GameSpeed = str2num(get(handles.InitGameSpeedBox,'string'));
end
Init.PlotResults = get(handles.InitPlotResultsChkbx,'value');
close all;
