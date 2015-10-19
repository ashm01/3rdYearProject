function [oarg,varargout]=cardplot(varargin)
%CARDPLOT  Plot playing cards for card games.
%   [H,X1,Y1] = CARDPLOT(X0,Y0,CSIZE,VALUE,SUIT)
%   draws a card with left bottom corner at (X0,Y0). The card will
%   have the size (ie height) CSIZE in data units (ticks) and the
%   type of card is given by VALUE and SUIT which can be any of the following:
%
%      VALUE = [ 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
%               'J' | 'Q' | 'K' | 'A' |
%                -1 | 0
%
%      SUIT = [ 'club' | 'diamond' | 'heart' | 'spade' ]
%
%   The value VALUE = 1 is equivalent to 'A', 11 to 'J', 12 to 'Q' and
%   13 to 'K' respectively. VALUE = -1 means that the card is made invisible and
%   VALUE = 0 means that the card is turned (face down).
%   The output argument H is a row vector with 49 columns corresponding to
%   all objects that the card is composed of (see below).
%   The outputs X1 and Y1 is the coordinate for the top right corner of the card.
%   The board on which the cards are placed must be created in advance and should
%   have its size changed after calling this routine, since the axis scaling does
%   not affect the fontsize while it does change the size of the edges of the cards.
%   Each of the 49 sub-objects that a card consists of has a UserData property
%   which is a 3 element cell array of which the first is the name of the type of
%   sub-object, the second cell element consists of the array of all the 49 handles
%   for the card (as given by H = CARDPLOT(...)) and the third cell element is
%   a vector [X0 Y0 X1 Y1] representing the lower left and upper right corner.
%   The card handle vector H has the following sub-objects (first cell element of
%   its UserData property) all in order:
%
%      'card'         x 1    : the card itself (patch)
%      'cornersuit'   x 4    : the suit on each corner (text)
%      'cornervalue'  x 4    : the value on each corner (text)
%      'tile'         x 39   : the value represented as suits (text)
%      'royal'        x 1    : this object is visible if jack, queen or king (text)
%
%   Thus all "tile" objects can be found in H(10:48) and the card patch is found in
%   H(1).
%
%   CARDPLOT(H,X0,Y0,VALUE,SUIT)    changes the card with handles in vector H to the
%   value VALUE and suit SUIT. X0 and Y0 specifies a new position for the lower left
%   corner of the card. If X0 = [] or Y0 = [] then either X0 or Y0 will remain
%   unchanged.
%
%   [VALUE,SUIT] = CARDPLOT(H)   shows VALUE and SUIT for a card given by the
%   handle vector H. VALUE is always a numeric between -1 and 13 and SUIT is
%   either of the strings as given above. Unfortunately, since value is used for
%   both setting the state of the card as well as setting its value, implying
%   that turning a card will result in that it looses its value and it is therefore
%   not possible to check the value of a card that has been turned or made
%   invisible, it will only return either VALUE = 0 or VALUE = -1. Thus it is up
%   to the game programmer to keep track on the values of those cards that has been
%   turned or been disabled.
%
%   CARDPLOT(VALUE,SUIT)  changes the mouse pointer over the current figure (GCF)
%   to look like a playing card of value VALUE and suit SUIT.
%   Convenient for moving cards with the mouse (see demo).
%
%   CARDPLOT(HFIG,VALUE,SUIT)  same as above but for the specified figure handle
%   HFIG.
%
%   CARDPLOT(DIM,COLOR)  creates a board with color COLOR with dimensions DIM on
%   the current axes (GCA). DIM = [Xmin, Xmax, Ymin, Ymax] sets the dimension of
%   the board's axis. If there are no current axes then an axes object will be
%   automatically created. COLOR is either an RGB vector or a character
%   representing a specific color (see PLOT).
%
%   CARDPLOT DEMO         shows a demonstration on how to use this application.
%
%   (NB! Fonts might look somewhat misaligned in Unix systems.)
%
%
%   See also AXIS, PATCH, TEXT, PLOT, GET, SET.

% Copyright (c) 2003-08-05, B. Rasmus Anthin.
% Revision 2003-08-06, 2003-08-07, 2003-08-10, 2003-08-12.


error(nargchk(1,5,nargin))

% x0,y0,csize,value,suit
% h,x0,y0,value,suit
% h
% value,suit
% hfig,value,suit
% dim,color
% 'demo'

facedowncolor=[.6706 .7765 .9059]; %[.8 .8 .8]

action=0;
if nargin==5 && length(varargin{1})==1      %create
   x=varargin{1};
   y=varargin{2};
   csize=varargin{3};
   value=varargin{4};
   suit=varargin{5};
   update=0;
   action=1;
elseif nargin==5                           %change
   h=varargin{1};
   x=varargin{2};
   y=varargin{3};
   value=varargin{4};
   suit=varargin{5};
   action=2;
elseif nargin==1
   if strcmpi(varargin{1},'demo')    %demo
      action=3;
   elseif ~ischar(varargin{1})             %view
      h=varargin{1};
      action=4;
   end
elseif nargin==2
   if length(varargin{1})==4 && ~ischar(varargin{1})     %board
      boardsize=varargin{1};
      color=varargin{2};
      action=6;
   else                                    %pointer
      value=varargin{1};
      suit=varargin{2};
      action=5;
      hfig=gcf;
   end
elseif nargin==3                           %pointer
   hfig=varargin{1};
   value=varargin{2};
   suit=varargin{3};
   action=5;
else
   error('Wrong number of arguments.')
end

%set(gca,'drawmode','fast')

switch(action)
case 1
   
   h0=8.7;  %cm,  total height
   w0=5.75; %cm,  total width
   h1=8;    %cm,  height before arc
   w1=5.05; %cm,  width before arc
   
   h0s=csize;
   w0s=w0/h0*csize;
   h1s=h1/h0*csize;
   w1s=w1/h0*csize;
   dl=(h0s-h1s)/2;   % = (w0s-w1s)/2
   r=dl;
   
   bottom=x+dl+linspace(0,w1s) + ...
      i*y;
   top=x+dl+linspace(0,w1s) + ...
      i*(y+h0s);
   left=x + ...
      i*(y+dl+linspace(0,h1s));
   right=x+w0s + ...
      i*(y+dl+linspace(0,h1s));
   alb=x+dl+r*cos(linspace(pi,pi*3/2)) + ...      %left-bottom arc
      i*(y+dl+r*sin(linspace(pi,pi*3/2)));
   arb=x+w1s+dl+r*cos(linspace(-pi/2,0)) + ...    %right-bottom arc
      i*(y+dl+r*sin(linspace(-pi/2,0)));
   alt=x+dl+r*cos(linspace(pi/2,pi)) + ...        %left-top arc
      i*(y+h1s+dl+r*sin(linspace(pi/2,pi)));
   art=x+w1s+dl+r*cos(linspace(0,pi/2)) + ...     %right-top arc
      i*(y+h1s+dl+r*sin(linspace(0,pi/2)));
   
   L=[bottom arb right art top alt left alb];
   xx=real(L);
   yy=imag(L);
   
   h(1)=patch(xx,yy,'w','userdata',{'card'});
   if any(upper(value)==[1:13 'J' 'Q' 'K' 'A'])
      set(h(1),'facec','w')
   elseif value==0
      set(h(1),'facec',facedowncolor)
   elseif value==-1
      set(h(1),'visible','off')
   end

   ax=axis;
   
   if ~isempty(suit)
      switch(lower(suit(1)))
      case 'c'
         sstr='\clubsuit';
         col='k';
      case 'd'
         sstr='\diamondsuit';
         col='r';
      case 'h'
         sstr='\heartsuit';
         col='r';
      case 's'
         sstr='\spadesuit';
         col='k';
      otherwise
         sstr='';
         col='k';
      end
   else
      sstr='';
      col='k';
   end
   
   switch(upper(value))
   case {1,'A'}, vstr='A';
   case {2,3,4,5,6,7,8,9,10}, vstr=num2str(value);
   case {11,'J'}, vstr='J';
   case {12,'Q'}, vstr='Q';
   case {13,'K'}, vstr='K';
   otherwise, vstr=''; sstr='';
   end
   h=[h plotsuit(x,y,h0,w0s,h1s,dl,csize,sstr,col)];
   h=[h plotvalue(x,y,h0,w0s,h1s,dl,csize,vstr,col)];
      
   
   fsize=2/h0*csize/diff(ax(3:4));
   %tile up as many suit symbols that corresponds to the card's value
   hsc=linspace(.17,.88,13); 
   wsc=linspace(.295,.71,3);
   hh=[];
   for k=1:13
      for j=1:3
         if k>7
            offy=-dl*1.25;
            offx=-dl*0.05;
         else
            offy=0;
            offx=0;
         end
         hh=[hh text(x+w0s*wsc(j)+offx,y+h0s*hsc(14-k)+offy,sstr)];
         set(hh(end),'fontunits','norm','fontsize',fsize,'visible','off','color',col,'horiz','c','vert','m','userdata',{'tile'})
         if k>7, set(hh(end),'rot',180), end
      end
   end
   plottile(hh,value,suit)
   
   hh(40)=text(x+w0s*wsc(2),y+h0s*hsc(6),'');
   set(hh(40),'fontunits','norm','fontsize',5/h0*csize/diff(ax(3:4)),'visible','off','color',col,'horiz','c','vert','m','userdata',{'royal'})
   switch(upper(value))
   case {11,'J'}, set(hh(40),'string','J','visible','on')
   case {12,'Q'}, set(hh(40),'string','Q','visible','on')
   case {13,'K'}, set(hh(40),'string','K','visible','on')
   end
   h=[h hh];
   for k=1:length(h)     %1:49
      userdata=get(h(k),'userdata');
      userdata{2}=h;
      userdata{3}=[x y x+w0s y+h0s];
      set(h(k),'userdata',userdata)
   end
   if nargout, oarg=h;end
   
   varargout={x+w0s,y+h0s};
   
case 2
   if length(h)==49           %sizeof(h) = 312 bytes
      if ~isempty(suit)
         switch(lower(suit(1)))
         case 'c', col='k'; sstr='\clubsuit';
         case 'd', col='r'; sstr='\diamondsuit';
         case 'h', col='r'; sstr='\heartsuit';
         case 's', col='k'; sstr='\spadesuit';
         otherwise, col='k'; sstr='';
         end
      else
         col='k'; sstr='';
      end
      switch(upper(value))
      case {1,'A'}, vstr='A';
      case {2,3,4,5,6,7,8,9,10}, vstr=num2str(value);
      case {11,'J'}, vstr='J';
      case {12,'Q'}, vstr='Q';
      case {13,'K'}, vstr='K';
      otherwise, vstr=''; sstr='';
      end
      switch(value)
      case 0, set(h(1),'visible','on','facecolor',facedowncolor) %card
      case -1, set(h(1),'visible','off')                         %card
      otherwise, set(h(1),'visible','on','facecolor','w')        %card
      end
      plottile(h(10:48),value,suit)                              %tile
      set(h(2:5),'string',sstr,'color',col)                      %cornersuit
      set(h(6:9),'string',vstr,'color',col)                      %cornervalue
      if any(strcmp(vstr,{'J','Q','K'}))
         set(h(49),'string',vstr,'visible','on','color',col)     %royal
      else
         set(h(49),'visible','off')                              %royal
      end
      if ~isempty(x)
         xdata=get(h(1),'xdata');                                %card
         x_old=min(xdata);
         dx=x-x_old;
         set(h(1),'xdata',xdata+dx)                              %card
         h2=h(2:49);                                             %the rest (text)
         for k=1:length(h2)
            pos=get(h2(k),'position');
            set(h2(k),'position',[pos(1)+dx pos(2:3)]);
         end
      end
      if ~isempty(y)
         ydata=get(h(1),'ydata');                                %card
         y_old=min(ydata);
         dy=y-y_old;
         set(h(1),'ydata',ydata+dy)                              %card
         h2=h(2:49);                                             %the rest (text)
         for k=1:length(h2)
            pos=get(h2(k),'position');
            set(h2(k),'position',[pos(1) pos(2)+dy pos(3)]);
         end
      end
   else
      warning('Could not update object (not a card).')
   end
case 3
   % echoing doesn't work inside functions, therefore we have to resort to some other method...
   
   pstr='     Press any key to continue...';
   
   %%%%% DEMO 1 %%%%%
   
   disp(' ')
   disp('%%%%% DEMO 1 %%%%%')
   disp('cardplot([0 7 0 5],[0 .7 0])              %create a green 7x5 board on current axes')
   disp('csize=1;                                  %height of card = 1')
   disp('hold on                                   %so we can draw several cards')
   disp('suit=''cdhs'';                              %the suits c=clubs, d=diamonds,...')
   disp('x0=3.5;                                   %init coordinates')
   disp('y0=0;')
   disp('x=x0;y=y0;                                %set start coordinates')
   disp(pstr)
   
   cardplot([0 7 0 5],[0 .7 0])              %create a green 7x5 board on current axes
   csize=1;                                  %height of card = 1
   hold on                                   %so we can draw several cards
   suit='cdhs';                              %the suits c=clubs, d=diamonds,...
   x0=3.5;                                   %init coordinates
   y0=0;
   x=x0;y=y0;                                %set start coordinates
   pause

   disp('for i=1:15                                %create a table of cards')
   disp('   [h(i,:),x1,y1]=cardplot(x+.05,y+.05,csize,i-2,suit(mod(i,4)+1));')
   disp('   if ~mod(i,4)                           %if row completed, increase y and rewind x')
   disp('      x=x0;')
   disp('      y=y1;')
   disp('   else                                   %else, just increase x')
   disp('      x=x1;')
   disp('   end')
   disp('end')
   disp('shg                                       %show current figure')
   disp(pstr)
   
   for k=1:15                                %create a table of cards
      [h(k,:),x1,y1]=cardplot(x+.05,y+.05,csize,k-2,suit(mod(k,4)+1));
      if ~mod(k,4)                           %if row completed, increase y and rewind x
         x=x0;
         y=y1;
      else                                   %else, just increase x
         x=x1;
      end
   end
   shg                                       %show current figure
   pause
   
   disp('cardplot(h(1,:),[],[],5,''s'')      %change 1:st card to 5 spades')
   disp(pstr)
   
   cardplot(h(1,:),[],[],5,'s')      %change 1:st card to 5 spades
   pause
   
   disp('cardplot(h(2,:),[],[],3,''h'')      %change 2:nd card to 3 hearts')
   disp(pstr)
   
   cardplot(h(2,:),[],[],3,'h')      %change 2:nd card to 3 hearts
   pause
   
   disp('cardplot(h(3,:),[],[],0,''s'')      %change 3:rd card to turned')
   disp(pstr)
   cardplot(h(3,:),[],[],0,'s')      %change 3:rd card to turned
   pause
   
   disp('cardplot(h(4,:),[],[],-1,''d'')     %change 4:th card to invisible')
   disp(pstr)
   
   cardplot(h(4,:),[],[],-1,'d')     %change 4:th card to invisible
   pause
   
   disp('cardplot(h(5,:),[],[],''J'',''c'')    %change 5:th card to jack of clubs')
   disp(pstr)
   
   cardplot(h(5,:),[],[],'J','c')    %change 5:th card to jack of clubs
   pause
   
   %%%%% DEMO 2 %%%%%
   
   disp(' ')
   disp('%%%%% DEMO 2 %%%%%')
   disp('h(6,:)=cardplot(0,0,csize,''K'',''clubs'');         %creating king of clubs')
   disp('h(7,:)=cardplot(.1,.05,csize,''Q'',''clubs'');      %putting queen of clubs on top of the king')
   disp('h(8,:)=cardplot(.2,.1,csize,''J'',''clubs'');       %putting jack of clubs on top of the queen')
   disp('h(9,:)=cardplot(.3,.15,csize,10,''clubs'');       %putting 10 of clubs on top of the jack')
   disp(pstr)
   
   h(6,:)=cardplot(0,0,csize,'K','clubs');         %creating king of clubs
   h(7,:)=cardplot(.1,.05,csize,'Q','clubs');      %putting queen of clubs on top of the king
   h(8,:)=cardplot(.2,.1,csize,'J','clubs');       %putting jack of clubs on top of the queen
   h(9,:)=cardplot(.3,.15,csize,10,'clubs');       %putting 10 of clubs on top of the jack
   pause
   
   disp('for k=6:9, cardplot(h(k,:),[],[],0,''clubs''), end      %turning all four cards')
   disp(pstr)
   
   for k=6:9, cardplot(h(k,:),[],[],0,'clubs'), end      %turning all four cards
   pause
      
   disp('for k=6:9, cardplot(h(k,:),[],[],19-k,''hearts''), end  %turning back cards but changes the suits to hearts')
   disp('[value,suit]=cardplot(h(7,:))                         %show the value and suit for the 2:nd card')
   disp(pstr)
   
   for k=6:9, cardplot(h(k,:),[],[],19-k,'hearts'), end  %turning back cards but changes the suits to hearts
   [value,suit]=cardplot(h(7,:));                        %show the value and suit for the 2:nd card
   pause
   
   disp('cardplot(h(7,:),[],[],-1,''hearts'')                    %making the 2:nd card (queen) invisible')
   disp(pstr)
   
   cardplot(h(7,:),[],[],-1,'hearts')                    %making the 2:nd card (queen) invisible
   pause
   
   disp('cardplot(h(7,:),[],[],''Q'',''hearts'')                   %making the queen visible again')
   disp(pstr)

   cardplot(h(7,:),[],[],'Q','hearts')                   %making the queen visible again
   pause

   %%%%% DEMO 3 %%%%%
   
   disp(' ')
   disp('%%%%% DEMO 3 %%%%%')
   disp('shg                                         %make sure the figure is active')
   disp('while 1                                     %loop until a card is found')
   disp('   waitforbuttonpress                       %halt until mouse click')
   disp('   ud=get(gco,''userdata'');                  %get userdata')
   disp('   if iscell(ud)                            %if userdata is a cellstring then assume it is a card')
   disp('      x0=ud{3}(1);                          %get lower left corner x')
   disp('      y0=ud{3}(2);                          % "    "     "     "   y')
   disp('      x1=ud{3}(3);                          %get upper right corner x')
   disp('      y1=ud{3}(4);                          % "    "     "     "    y')
   disp('      h=ud{2};                              %get the card that the clicked object belongs to')
   disp('      [value,suit]=cardplot(h);             %find out its value and suit')
   disp('      cardplot(value,suit)                  %set mouse pointer to look like the card')
   disp('      cardplot(h,[],[],-1,suit)             %disable card')
   disp('      break                                 %break, since card was found')
   disp('   end')
   disp('end')
   disp('     Now, click on a card to pick it up!')
   
   shg                                         %make sure the figure is active
   while 1                                     %loop until a card is found
      waitforbuttonpress                       %halt until mouse click
      ud=get(gco,'userdata');                  %get userdata
      if iscell(ud)                            %if userdata is a cellstring then assume it is a card
         x0=ud{3}(1);                          %get lower left corner x
         y0=ud{3}(2);                          % "    "     "     "   y
         x1=ud{3}(3);                          %get upper right corner x
         y1=ud{3}(4);                          % "    "     "     "    y
         h=ud{2};                              %get the card that the clicked object belongs to
         [value,suit]=cardplot(h);             %find out its value and suit
         cardplot(value,suit)                  %set mouse pointer to look like the card
         cardplot(h,[],[],-1,suit)             %disable card
         break                                 %break, since card was found
      end
   end
   
   disp('waitforbuttonpress                          %halt until mouse click')
   disp('set(gcf,''pointer'',''arrow'')                  %restore mouse pointer')
   disp('pos=get(gca,''currentpoint'');                %find coordinates of mouse click')
   disp('x=pos(1,1,1);                               %mouse click x')
   disp('y=pos(1,2,1);                               %  "     "   y')
   disp('x0=x-(x1-x0)/2;                             %evaluate new lower left corner x (x0)')
   disp('y0=y-(y1-y0)/2;                             %   "      "    "     "     "   y (y0)')
   disp('cardplot(h,x0,y0,value,suit)                %update the card''s position')
   disp('     Now, click on a spot where to put the card!')

   waitforbuttonpress                          %halt until mouse click
   set(gcf,'pointer','arrow')                  %restore mouse pointer
   pos=get(gca,'currentpoint');                %find coordinates of mouse click
   x=pos(1,1,1);                               %mouse click x
   y=pos(1,2,1);                               %  "     "   y
   x0=x-(x1-x0)/2;                             %evaluate new lower left corner x (x0)
   y0=y-(y1-y0)/2;                             %   "      "    "     "     "   y (y0)
   cardplot(h,x0,y0,value,suit)                %update the card's position
   
   disp(' ')
   %%%%% END DEMO %%%%%%
case 4
   vstr=get(h(6:9),'string');                         %cornervalue
   switch(vstr{1})
   case 'A', value=1;
   case 'J', value=11;
   case 'Q', value=12;
   case 'K', value=13;
   otherwise, value=str2num(vstr{1});
   end
   if all(get(h(1),'facecolor')==facedowncolor)       %card
      value=0;
   elseif strcmp(get(h(1),'visible'),'off')           %card
      value=-1;
   end
   sstr=get(h(2:5),'string');                         %cornersuit
   switch(sstr{1})
   case '\clubsuit', suit='club';
   case '\diamondsuit', suit='diamond';
   case '\heartsuit', suit='heart';
   case '\spadesuit', suit='spade';
   otherwise, suit='';
   end
   oarg=value;
   varargout={suit};
   
case 5
   clubim=[2 2 2 1 2 2 2
           2 2 1 1 1 2 2
           2 2 1 1 1 2 2
           2 1 2 1 2 1 2
           1 1 1 1 1 1 1
           2 1 2 1 2 1 2
           2 2 2 1 2 2 2
           2 2 2 1 2 2 2
           2 2 1 1 1 2 2];
   diamondim=[2 2 2 1 2 2 2
              2 2 2 1 2 2 2
              2 2 1 1 1 2 2
              2 1 1 1 1 1 2
              1 1 1 1 1 1 1
              2 1 1 1 1 1 2
              2 2 1 1 1 2 2
              2 2 2 1 2 2 2
              2 2 2 1 2 2 2];
   heartim=[2 1 2 2 2 1 2
            1 1 1 2 1 1 1
            1 1 1 1 1 1 1
            1 1 1 1 1 1 1
            2 1 1 1 1 1 2
            2 1 1 1 1 1 2
            2 2 1 1 1 2 2
            2 2 2 1 2 2 2
            2 2 2 1 2 2 2];
   spadeim=[2 2 2 1 2 2 2
            2 2 1 1 1 2 2
            2 1 1 1 1 1 2
            1 1 1 1 1 1 1
            1 1 1 1 1 1 1
            2 1 2 1 2 1 2
            2 2 2 1 2 2 2
            2 2 2 1 2 2 2
            2 2 1 1 1 2 2];
   val2im=[2 2 1 1 1 2
           2 1 2 2 2 1
           2 2 2 2 1 2
           2 2 2 1 2 2
           2 2 1 2 2 2
           2 1 1 1 1 1];
   val3im=[2 2 1 1 1 2
           2 1 2 2 2 1
           2 2 2 1 1 2
           2 2 2 2 2 1
           2 1 2 2 2 1
           2 2 1 1 1 2];
   val4im=[2 2 2 1 2 2
           2 2 1 1 2 2
           2 1 2 1 2 2
           1 1 1 1 1 1
           2 2 2 1 2 2
           2 2 2 1 2 2];
   val5im=[2 1 1 1 1 1
           2 1 2 2 2 2
           2 1 1 1 1 2
           2 2 2 2 2 1
           2 1 2 2 2 1
           2 2 1 1 1 2];
   val6im=[2 2 1 1 1 2
           2 1 2 2 2 2
           2 1 1 1 2 2
           2 1 2 2 1 2
           2 1 2 2 1 2
           2 2 1 1 2 2];
   val7im=[2 1 1 1 1 1
           2 2 2 2 2 1
           2 2 2 2 1 2
           2 2 2 1 2 2
           2 2 2 1 2 2
           2 2 2 1 2 2];
   val8im=[2 2 1 1 2 2
           2 1 2 2 1 2
           2 2 1 1 2 2
           2 1 2 2 1 2
           2 1 2 2 1 2
           2 2 1 1 2 2];
   val9im=[2 2 1 1 2 2
           2 1 2 2 1 2
           2 1 2 2 1 2
           2 2 1 1 1 2
           2 2 2 2 1 2
           2 1 1 1 2 2];
   val10im=[2 1 2 2 1 2
            1 1 2 1 2 1
            2 1 2 1 2 1
            2 1 2 1 2 1
            2 1 2 1 2 1
            1 1 1 2 1 2];
   valjim=[2 1 1 1 1 1
           2 2 2 2 2 1
           2 2 2 2 2 1
           2 2 2 2 2 1
           2 1 2 2 2 1
           2 2 1 1 1 2];
   valqim=[2 2 1 1 1 2
           2 1 2 2 2 1
           2 1 2 2 2 1
           2 1 2 1 2 1
           2 1 2 2 1 1
           2 2 1 1 1 1];
   valkim=[2 1 2 2 2 1
           2 1 2 2 1 2
           2 1 2 1 2 2
           2 1 1 2 1 2
           2 1 2 2 2 1
           2 1 2 2 2 1];
   valaim=[2 2 2 1 2 2
           2 2 1 2 1 2
           2 1 2 2 2 1
           2 1 1 1 1 1
           2 1 2 2 2 1
           2 1 2 2 2 1];
   t=nan;
   cdata=[t 1 1 1 1 1 1 1 1 1 1 1 1 1 1 t
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1
          t 1 1 1 1 1 1 1 1 1 1 1 1 1 1 t];
   if ~isempty(suit)
      switch(lower(suit(1)))
      case 'c', cdata(3:11,3:9)=clubim;
      case 'd', cdata(3:11,3:9)=diamondim;
      case 'h', cdata(3:11,3:9)=heartim;
      case 's', cdata(3:11,3:9)=spadeim;
      end
   end
   switch(upper(value))
   case 0
      cdata=ones(16);
      cdata([1 1 16 16],[1 16 16 1])=t;
   case {1,'A'}, cdata(9:14,9:14)=valaim;
   case 2, cdata(9:14,9:14)=val2im;
   case 3, cdata(9:14,9:14)=val3im;
   case 4, cdata(9:14,9:14)=val4im;
   case 5, cdata(9:14,9:14)=val5im;
   case 6, cdata(9:14,9:14)=val6im;
   case 7, cdata(9:14,9:14)=val7im;
   case 8, cdata(9:14,9:14)=val8im;
   case 9, cdata(9:14,9:14)=val9im;
   case 10, cdata(9:14,9:14)=val10im;
   case {11,'J'}, cdata(9:14,9:14)=valjim;
   case {12,'Q'}, cdata(9:14,9:14)=valqim;
   case {13,'K'}, cdata(9:14,9:14)=valkim;
   end
   if value~=-1
      figure(hfig)
      set(gcf,'pointer','custom','pointershapecdata',cdata)
   end
   
case 6
   set(gca,'pos',[0 0 1 1])
   set(gca,'xtick',[],'ytick',[])
   set(gca,'box','on')
   set(gca,'color',color)
   axis equal
   axis(boardsize)
   
otherwise
   error('Unknown operation.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=plotvalue(x,y,h0,w0s,h1s,dl,csize,str,col)
ax=axis;
fsize=1/h0*csize/diff(ax(3:4));
offx1=dl*2.04;
offx2=-dl*1.97;
offx3=dl*2.00;
offx4=-dl*2.00;
h(1)=text(x+offx1,y+dl+h1s,str);
h(2)=text(x+w0s+offx2,y+dl+h1s,str);
h(3)=text(x+offx3,y+dl,str,'rot',180);
h(4)=text(x+w0s+offx4,y+dl,str,'rot',180);
set(h,'fontunits','norm','fontsize',fsize,'fontweight','norm','horiz','c','vert','t','color',col,'userdata',{'cornervalue'})


function h=plotsuit(x,y,h0,w0s,h1s,dl,csize,str,col)
ax=axis;
fsize=1/h0*csize/diff(ax(3:4));
offy=0.8*fsize*diff(ax(3:4));
offx1=dl*2.04;
offx2=-dl*1.97;
offx3=dl*2.00;
offx4=-dl*2.00;
h(1)=text(x+offx1,y+dl+h1s-offy,str);
h(2)=text(x+w0s+offx2,y+dl+h1s-offy,str);
h(3)=text(x+offx3,y+dl+offy,str,'rot',180);
h(4)=text(x+w0s+offx4,y+dl+offy,str,'rot',180);
set(h,'fontunits','norm','fontsize',fsize,'horiz','c','vert','t','color',col,'userdata',{'cornersuit'})


function plottile(h,value,suit)
if ~isempty(suit)
   switch(lower(suit(1)))
   case 'c'
      str='\clubsuit';
      col='k';
   case 'd'
      str='\diamondsuit';
      col='r';
   case 'h'
      str='\heartsuit';
      col='r';
   case 's'
      str='\spadesuit';
      col='k';
   otherwise
      str='';
      col='k';
   end
else
   str='';
   col='k';
end
set(h,'string',str,'color',col,'visible','off')
%  1  2  3 |         |    ^    | ^     ^ | ^     ^ | ^     ^ | ^     ^ | ^     ^ | ^     ^ | ^     ^ |
%  4  5  6 |         |         |         |         |         |         |         |         |         |
%  7  8  9 |         |         |         |         |         |         |         |         |    ^    |
% 10 11 12 |         |         |         |         |         |    ^    |    ^    |         |         |
% 13 14 15 |         |         |         |         |         |         |         | ^     ^ | ^     ^ |
% 16 17 18 |         |         |         |         |         |         |         |         |         |
% 19 20 21 |    ^    |         |         |    ^    | ^     ^ | ^     ^ | ^     ^ |    ^    |         |
% 22 23 24 |         |         |         |         |         |         |         |         |         |
% 25 26 27 |         |         |         |         |         |         |         | v     v | v     v |
% 28 29 30 |         |         |         |         |         |         |    v    |         |         |
% 31 32 33 |         |         |         |         |         |         |         |         |    v    |
% 34 35 36 |         |         |         |         |         |         |         |         |         |
% 37 38 39 |         |    v    | v     v | v     v | v     v | v     v | v     v | v     v | v     v |
if any(upper(value)==[1 'A' 3 5 9])
   set(h(20),'visible','on')
end
if any(value==[2 3])
   set(h([2 38]),'visible','on')
end
if any(value==[4:10])
   set(h([1 3 37 39]),'visible','on')
end
if any(value==[6:8])
   set(h([19 21]),'visible','on')
end
if any(value==[7:8])
   set(h(11),'visible','on')
end
if value==8
   set(h(29),'visible','on')
end
if any(value==[9:10])
   set(h([13 15 25 27]),'visible','on')
end
if value==10
   set(h([8 32]),'visible','on')
end
if any(upper(value)==[11 12 13 'JQK'])
   set(h([1 39]),'visible','on')
end