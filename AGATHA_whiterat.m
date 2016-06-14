% function AGATHA_whiterat(VideoName,TrialIDName,Xstart,Xend,vid_fps,sample_fps,rownum,trouble,dilaterat,Red_Level,toplabel,vid,video)

% % % HEK 7-24-2014
% % HEK Variables
VideoName = 'F:\Week 2 Gait\05-03-16_001\r09_t03_.00.avi'; 

TrialIDName = 'Becky Tester 9_t03';
Xstart = 1;
Xend = 0;

rownum = 11;
trouble = 'Quiet';
dilaterat = 2;

Red_Level = .1;
vid_fps = 250;
sample_fps = 250;
toplabel = 1;


% % % % % % % vid;
% % % % % % % video;

nargin = 11;



% Last edited by HEK on 03/21/16
%% Warning Section
warning('off', 'MATLAB:xlswrite:AddSheet');

close all

% display('CORRECT!!!');
% display('_____________________________________________________________________________________________');
% display(' ');

display(['AGATHA_v1 Running -- ',TrialIDName]);
display(['Figures will be saved with the leader -- ',TrialIDName]);

% check on the current values for "rownum" to see if they overwrite something.
% it may be OK if you are for instance running avideo file for the
% second time.  But a  warning will output to command line.
if exist('Master_spreadsheet_AGATHA_v1.xlsx','file')==2
    CASELOGIC=xlsread('Master_spreadsheet_AGATHA_v1.xlsx','Hindpaws');
    if rownum<size(CASELOGIC,1)+1;%one row for new, one row for header
        display(' ');
        display('! **Warning** !');
        display(['! This program will overwrite row ',int2str(rownum),' in the Master_Spreadsheet_AGATHA_v1.xlsx']);
        display('! This file should be located in Current Folder.');
        display('! You hit *CONTROL-C* now or anytime before the completion of');
        display('! "Tracking of the Animal Frame By Frame" to preserve this file.');
    end;
end

%new "filename" will append to figures, xls outs, etc.
lim=size(TrialIDName,2);
TrialIDName(TrialIDName=='.')=[];
name=TrialIDName;
name(name=='\')='/';
name(name=='_')='-';       %this "name" will name plot titles
% Trouble shooting mode
if nargin < 12
    display (' ');
    display('Loading video... 1-2 minutes processing time');
    
    % Looks to see if the target video is even there, then makes mock-up
    % names if the video was split into multiple files.
    if exist(VideoName)
        v1 = VideoName;
        VideoName(end-4) = '1';
        v2 = VideoName;
        VideoName(end-4) = '2';
        v3 = VideoName;
        VideoName(end-4) = '3';
        v4 = VideoName;
        VideoName(end-4) = '4';
        v5 = VideoName;
    else
        display('Error - Video does not exist within the directory');
    end
    
    % If there are multiple files for a single video, this code determines
    % how many (up to 5) and then reads them in and concatenates them.
    if exist(v5)
        v1 = VideoReader(v1);
        v2 = VideoReader(v2);
        v3 = VideoReader(v3);
        v4 = VideoReader(v4);
        v5 = VideoReader(v5);
        
        vid1 = read(v1);
        vid2 = read(v2);
        vid3 = read(v3);
        vid4 = read(v4);
        vid5 = read(v5);
        
        vid = cat(4,vid1,vid2,vid3,vid4,vid5);
        
    elseif exist(v4)
        v1 = VideoReader(v1);
        v2 = VideoReader(v2);
        v3 = VideoReader(v3);
        v4 = VideoReader(v4);
        
        vid1 = read(v1);
        vid2 = read(v2);
        vid3 = read(v3);
        vid4 = read(v4);
        
        vid = cat(4,vid1,vid2,vid3,vid4);
    elseif exist(v3)
        v1 = VideoReader(v1);
        v2 = VideoReader(v2);
        v3 = VideoReader(v3);
        
        vid1 = read(v1);
        vid2 = read(v2);
        vid3 = read(v3);
        
        vid = cat(4,vid1,vid2,vid3);
    elseif exist(v2)
        v1 = VideoReader(v1);
        v2 = VideoReader(v2);
        
        vid1 = read(v1);
        vid2 = read(v2);
        
        vid = cat(4,vid1,vid2);
    else
        v1 = VideoReader(v1);  
        vid = read(v1);
    end
    
    clear v1 v2 v3 v4 v5 vid1 vid2 vid3 vid4 vid5
    
    display('Video loaded');
else
    display (' ');
    display('Video Preloaded');
end
% clear vid;

video = vid;
frameskip = round(vid_fps/sample_fps);
video = video(:,:,:,1:frameskip:end);
[ZMAX XMAX colorchannel frames] = size(video);


%% Read in Section
% this block to fool proof x-coordinates. Xend must > Xstart and > 100
if nargin<4
    Xstart=1;
    Xend=XMAX;
end

if (Xend>=XMAX) || (Xend<=Xstart) || (Xend<=100)
    Xend=XMAX;
end;
if Xstart<=1 || Xstart>=Xend
    Xstart=1;
end;
Xend=round(Xend);
Xstart=round(Xstart);

% Plot Option
plotoption='Quiet';

PO_ShowAll = strcmp(plotoption,'ShowAll');
PO_Direction = strcmp(plotoption,'Direction');
PO_FSTO = strcmp(trouble,'FSTO');
PO_PawPrint = strcmp(trouble,'PawPrint');
colorscheme='T';



% HEK Fix 3-23-2015
% General Case for setting foot smudge criteria in FSTO plot (in figure eroded)


areahi = (18+dilaterat*0.2)*sample_fps;
arealo = (1.5+dilaterat*0.1)*sample_fps;
pitchmin = sample_fps/10;
arealimit = sample_fps/2;




% Criteria Option
criteriaoption='D';
criteriaoption=criteriaoption(1);


% Create master sheet
if nargin< 7 %  7th argument is the row_number for master caselogic file,
    % can assign manually if you want batch file to remember where to write,
    % for instance, running a batch file many times.
    if exist('Master_spreadsheet_AGATHA_v1.xlsx','file')==2
        %if there is already a file for this, write to the last row
        CASELOGIC=xlsread('Master_spreadsheet_AGATHA_v1.xlsx','Hindpaws');
        rownum=size(CASELOGIC,1)+2;%one row for new, one row for header that is not read by "xls read"
    else
        rownum=2;% if case logic files non existant, row num=2,
        % row 1 reserved for header.
    end
end

% Troubleshooting
if nargin < 8
    trouble = 'Quiet';
end

if nargin < 9
    dilaterat = 1;
end

% Red Line subtractor
Lines = 'AutoDetectLinesOn';
CheckLines = strcmp(Lines,'AutoDetectLinesOn');


% Distortion Check

DistortionCall = 'On';
Distortion_Switch = strcmp(DistortionCall,'AutoDetectDistortionOff');


if nargin < 10
    Red_Level = 0.08;
end
if Red_Level == 0
    Red_Level = 0.08;
end

if nargin < 11
    toplabel = 1;
end


TF_ShowAll = strcmp(trouble,'ShowAll');
TF_HindPaw = strcmp(trouble,'HindPaw');
TF_ForePaw = strcmp(trouble,'ForePaw');
TF_Tracker = strcmp(trouble,'Tracker');
TF_TopTracker = strcmp(trouble,'TopTracker');
TF_BottomTracker = strcmp(trouble,'BottomTracker');
TF_ShowBothFeet = strcmp(trouble, 'ShowBothPaws');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%new block of code written april 24th 2013: this is to auto find the top/
%bottom image. if XYfraction and XZfraction do not exist.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('XZfraction','var')==0||exist('XYfraction','var')==0
    %if this fraction already exists, OK, but if not, use auto-fiind below:
    %to split the ROI into top nad bottom image
    
    %     HEK Added case because the video label can also be put above the screen
    %     which messes up the finding function to split the screen.
    
    
    
    if toplabel
        IM=ones( size( video(40:end,:,1,10)  ));
        %take a picture, all white, at size of single frame of video, called "IM"
        IM( video(40:end,:,2,10)*1.0 > video(40:end,:,1,10) & video(40:end,:,1,10)< 255 )=0;
        % lines on either eide of this comment look for pixels that are more
        % green than red or more blue than green.
        IM( video(40:end,:,3,10)*1.0 > video(40:end,:,1,10) & video(40:end,:,1,10)< 255 )=0;
        
        KDA_FindRow = sum(IM(:,:)');
        KDA_id = find(KDA_FindRow >= XMAX*9/10);
        %     XZfraction = ZMAX/(min(KDA_id)-10);
        XZfraction = ZMAX/(min(KDA_id+50));
        XYfraction = ZMAX/(min(KDA_id)+50);
%         
        
        
        %HEK crappy patch for the animal being on the screen
        %Animal on Right Side:
%         IM=ones( size( video(40:end,1:round(XMAX/2),1,10)  ));
%         %take a picture, all white, at size of single frame of video, called "IM"
%         IM( video(40:end,1:round(XMAX/2),2,10)*1.0 > video(40:end,1:round(XMAX/2),1,10) & video(40:end,1:round(XMAX/2),1,10)< 255 )=0;
%         % lines on either eide of this comment look for pixels that are more
%         % green than red or more blue than green.
%         IM( video(40:end,1:round(XMAX/2),3,10)*1.0 > video(40:end,1:round(XMAX/2),1,10) & video(40:end,1:round(XMAX/2),1,10)< 255 )=0;
%         
%         KDA_FindRow = sum(IM(:,:)');
%         KDA_id = find(KDA_FindRow >= .5*XMAX*9/10);
%         %     XZfraction = ZMAX/(min(KDA_id)-10);
%         XZfraction = ZMAX/(min(KDA_id+50));
%         XYfraction = ZMAX/(min(KDA_id)+50);
        
%         %Animal on Left Side:        
%         IM=ones( size( video(40:end,round(end/2):end,1,10)  ));
%         %take a picture, all white, at size of single frame of video, called "IM"
%         IM( video(40:end,round(end/2):end,2,10)*1.0 > video(40:end,round(end/2):end,1,10) & video(40:end,round(end/2):end,1,10)< 255 )=0;
%         % lines on either eide of this comment look for pixels that are more
%         % green than red or more blue than green.
%         IM( video(40:end,round(end/2):end,3,10)*1.0 > video(40:end,round(end/2):end,1,10) & video(40:end,round(end/2):end,1,10)< 255 )=0;
%         
%         KDA_FindRow = sum(IM(:,:)');
%         KDA_id = find(KDA_FindRow >= .5*XMAX*9/10);
%         %     XZfraction = ZMAX/(min(KDA_id)-10);
%         XZfraction = ZMAX/(min(KDA_id+50));
%         XYfraction = ZMAX/(min(KDA_id)+50);
%         
        
        
    else
        IM=ones( size( video(:,:,1,10)  ));
        %take a picture, all white, at size of single frame of video, called "IM"
        IM( video(:,:,2,10)*1.0 > video(:,:,1,10) & video(:,:,1,10)< 255 )=0;
        % lines on either eide of this comment look for pixels that are more
        % green than red or more blue than green.
        IM( video(:,:,3,10)*1.0 > video(:,:,1,10) & video(:,:,1,10)< 255 )=0;
        
        KDA_FindRow = sum(IM(:,:)');
        KDA_id = find(KDA_FindRow >= XMAX*9/10);
        %     XZfraction = ZMAX/(min(KDA_id)-10);
        XZfraction = ZMAX/(min(KDA_id+10));
        XYfraction = ZMAX/(min(KDA_id)+10);
    end
end

%% Direction Finder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% block below will allow code to find velocity = +1 or -1 based on
% which frames have the most white in them for a given segment of veiw.
% white means rat. the whole backdrop is green, which goes to black as a
% black - white transformation in the for loop below.
% this block also creats a background image "base" of the field of veiw.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% "XZfraction" is used below to throw away the bottom part of image (ROI)
xqts=round(XMAX/2);  zqs=round(ZMAX/XZfraction);   % read: "x-quarters, z-quarters"
tqts=round(frames/9);frst=round(tqts/4);           % read "t-quarters, first".
% T is a time vector for a subset of ten still frames of vid. use this to
% find the direction of rats travel
T=[frst tqts 2*tqts 3*tqts 4*tqts 5*tqts 6*tqts 7*tqts 8*tqts frames-frst];
% T=[frst:tqts:frames-frst];

avglox = zeros(1,10);
avghix = zeros(1,10);

for j=1:10
        binlox=ones( size( video(1:zqs,1:xqts,1,T(j))  ));
        binlox( video(1:zqs,1:xqts,2,T(j))*1.1 > video(1:zqs,1:xqts,1,T(j)) & video(1:zqs,1:xqts,1,T(j))< 255 )=0;
        binlox( video(1:zqs,1:xqts,3,T(j))*1.2 > video(1:zqs,1:xqts,1,T(j)) & video(1:zqs,1:xqts,1,T(j))< 255 )=0;
    %     figure(100); imshow(binlox);
        binhix=ones(size( video(1:zqs,xqts:XMAX,1,T(j)) ));
        binhix( video( 1:zqs,xqts:XMAX,2,T(j))*1.1 > video(1:zqs,xqts:XMAX,1,T(j)) & video(1:zqs,xqts:XMAX,1,T(j))< 255 )=0;
        binhix( video( 1:zqs,xqts:XMAX,3,T(j))*1.2 > video(1:zqs,xqts:XMAX,1,T(j)) & video(1:zqs,xqts:XMAX,1,T(j))< 255 )=0;
    
        
        
        
       
%     im_lox = rgb2hsv(video(1:zqs,1:xqts,:,T(j)));
%     binlox = ~(im2bw(im_lox(:,:,1)) + ~(im2bw(im_lox(:,:,3))));
%     holdlox = ~(im2bw(im_lox(:,:,1)) + ~(im2bw(im_lox(:,:,3))));
%     
%     
%     binlox=imerode(binlox,strel('line',5,0));
%     im_hix = rgb2hsv(video(1:zqs,xqts:XMAX,:,T(j)));
%     binhix = ~(im2bw(im_hix(:,:,1)) + ~(im2bw(im_hix(:,:,3))));
%     binhix = imerode(binhix,strel('line',5,0));
    
    
    
    
    
    avglox(j)=mean2(binlox(:,:)); % array of intensities vs time, low-x quarter
    avghix(j)=mean2(binhix(:,:));
    % "low x" and "high x" are two halves of the ROI. Code will take the
    % low half and find when the rat is there, then the high half and look
    % for when the rat is there. Then infer which dirrection the rat has
    % moved and assign vel=-1 or vel=+1.
end

framelox=find(avglox==max(avglox), 1 ); % "base- low -x" & " base high x"
framehix=find(avghix==max(avghix), 1 ); % will concatenate into base of all x.
Yst=round(ZMAX/XYfraction); %Y-start for lower image.
Xcut=round(XMAX/2);%cut for concatenation of base frames.

% HEK
% framelox = 8;

if framelox > framehix
    baselox=ones( size( video(:,1:Xcut,1,1)  ));
    baselox( video(:,1:Xcut,2,10)*1.1 > video(:,1:Xcut,1,10) & video(:,1:Xcut,1,10)< 255 )=0;
    baselox( video(:,1:Xcut,3,10)*1.2 > video(:,1:Xcut,1,10) & video(:,1:Xcut,1,10)< 255 )=0;
    basehix=ones( size( video(:,1:Xcut,1,frames-10)  ));
    basehix( video(:,Xcut+1:XMAX,2,frames-10)*1.1 > video(:,Xcut+1:XMAX,1,frames-10) & video(:,Xcut+1:XMAX,1,frames-10)< 255 )=0;
    basehix( video(:,Xcut+1:XMAX,3,frames-10)*1.2 > video(:,Xcut+1:XMAX,1,frames-10) & video(:,Xcut+1:XMAX,1,frames-10)< 255 )=0;
    
    %     im_baselox = rgb2hsv(video(:,1:Xcut,:,10));
    %     KKbaselox = ~(im2bw(im_baselox(:,:,1)) + ~(im2bw(im_baselox(:,:,3))));
    %     im_basehix = rgb2hsv(video(:,Xcut+1:XMAX,:,frames-10));
    %     KKbasehix = ~(im2bw(im_basehix(:,:,1)) + ~(im2bw(im_basehix(:,:,3))));
    
    vel=-1;% rat moving to the right. use early frame for lower x.

elseif framelox < framehix
    baselox=ones( size( video(:,1:Xcut,1,frames-10)  ));
    baselox( video(:,1:Xcut,2,frames-10)*1.1 > video(:,1:Xcut,1,frames-10) & video(:,1:Xcut,1,frames-10)< 255 )=0;
    baselox( video(:,1:Xcut,3,frames-10)*1.2 > video(:,1:Xcut,1,frames-10) & video(:,1:Xcut,1,frames-10)< 255 )=0;
    basehix=ones( size( video(:,1:Xcut,1,10)  ));
    basehix( video(:,Xcut+1:XMAX,2,10)*1.1 > video(:,Xcut+1:XMAX,1,10) & video(:,Xcut+1:XMAX,1,10)< 255 )=0;
    basehix( video(:,Xcut+1:XMAX,3,10)*1.2 > video(:,Xcut+1:XMAX,1,10) & video(:,Xcut+1:XMAX,1,10)< 255 )=0;
    
    vel=1;% rat moving to the left, use a late frame for low x.
else
    display('Error in Direction Tracker');
end
%input('press any key to continue');

base=cat(2,baselox,basehix);
% KKbase=cat(2,KKbaselox,KKbasehix);

% concatenate the two halves of the ROI backdrop together after finding the
% direction of travel and finding the best backdrop frames to use.

% figure(115); imshow(base);
% figure(116); imshow(KKbase);


framemid=round(frames*((framelox+framehix)/2) / 10 );
% framemid finds rat's area in XYplane. when the whole rat is on camera
% this is used in the centriod tracker to approximate off camera centriods
% it is valuble for aproximating the rat's area in pixels.

%string=cat(2,TrialIDName,': process time is about 2 min. per video');
%display(string); % print a line to show where the batch process is.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the output above is a full base frame to cancel backgnd and leave only
% the rat himself. With bwlabel and erode code can eliminate other noise and find
% just the rat. Rat's feet define floor as max Z row where image==1.
% in this block the floor is found as a funcitn of X and Time, code will
% make that a function of x and NOT time later, after the centriod tracker block.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zqs=round(ZMAX/XZfraction);
floor=zeros(frames,XMAX);

%% Frame by Frame
clear allarea AREA area Area
nox=zeros(frames,1); nosey=nox;  caprox=nox;     caproy=nox;
cenx=nox; ceny=nosey; onleft=nox; onright=nox;   ratwide=nox;
L=zeros(  size(base(Yst:end,:)) );
TEND=framemid+5;TBG=framemid-5;TEND(TEND>frames)=frames;TBG(TBG<1)=1;
AREA = zeros(1, TEND-TBG);
for t=TBG:TEND% "time-begin and time-end".
    % this loop uses frame-mid to find the rat in the very middle of the track
    % the reason we do this is to estimate the rat's area and then estimate
    % the centroid when the rat is partly off screen.
    clear stats allarea
    
    %Yst is "Y-Start" and is defined by the XYfraction, the denominator
    %to tell us where the screen splits between top and bottom.
    L=ones( size( video(Yst:end,:,1,t)  ));
    L( video(Yst:end,:,2,t)*1.1 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
    L( video(Yst:end,:,3,t)*1.2 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
    
    L=imerode(L,strel('square',3))-imerode(base(Yst:end,:),strel('square',3));
    
    L( L<0)=0;
    
    [L num]=bwlabel(L);
    stats=regionprops(L,'area');
    allarea=[stats.Area]';
    AREA(t)=max(allarea);%find the biggest object on screen, assign as an elemnet of array: AREA
    
end;
AREA(AREA==0)=[];
Area=mean(AREA);%average girth of the rat. used below to aproximate center when partly off screen.

display('Tracking Animal Frame By Frame')

frames10 = round(0.1*frames);
frames20 = round(0.2*frames);
frames25 = round(0.25*frames);
frames30 = round(0.3*frames);
frames40 = round(0.4*frames);
frames50 = round(0.5*frames);
frames60 = round(0.6*frames);
frames70 = round(0.7*frames);
frames75 = round(0.75*frames);
frames80 = round(0.8*frames);
frames90 = round(0.9*frames);

im_firstframe = video(1:zqs,:,:,1);
im_lastframe = video(1:zqs,:,:,frames);
im_bottomfirstframe = video(Yst:end,:,:,1);
im_bottomlastframe = video(Yst:end,:,:,frames);

if vel == -1
    Cutter_background = round(XMAX/2);
    im_background = [im_firstframe(:,1:Cutter_background,:,1),im_lastframe(:,Cutter_background+1:XMAX,:,1)];
    im_bottombackground = [im_bottomfirstframe(:,1:Cutter_background,:,1),im_bottomlastframe(:,Cutter_background+1:XMAX,:,1)];
else
    Cutter_background = round(XMAX/2);
    im_background = [im_lastframe(:,1:Cutter_background,:,1),im_firstframe(:,Cutter_background+1:XMAX,:,1)];
    im_bottombackground = [im_bottomlastframe(:,1:Cutter_background,:,1),im_bottomfirstframe(:,Cutter_background+1:XMAX,:,1)];
end
if TF_ShowAll == 1
    figure(18); imshow(im_background);
    figure(19); imshow(im_bottombackground);
end

clear topnosevel

topnose = [];


% if exist('eroded');
% else
    for t=1:frames
        
        if t == frames10
            display('10% Complete');
        elseif t == frames20
            display('20% Complete');
        elseif t == frames30
            display('30% Complete');
        elseif t == frames40
            display('40% Complete');
        elseif t == frames50
            display('50% Complete');
        elseif t == frames60
            display('60% Complete');
        elseif t == frames70
            display('70% Complete');
        elseif t == frames80
            display('80% Complete');
        elseif t == frames90
            display('90% Complete');
        elseif t == frames
            display('100% Complete');
        end
        
        %     L=ones( size( video(1:zqs,:,1,t)  ));
        %     L( video(1:zqs,:,2,t)*1.1 > video(1:zqs,:,1,t) & video(1:zqs,:,1,t)< 255 )=0;
        %     L( video(1:zqs,:,3,t)*1.2 > video(1:zqs,:,1,t) & video(1:zqs,:,1,t)< 255 )=0;
        % lines on either eide of this comment look for pixels that are more
        % green than red or more blue than green, or pixels that are within 1.1
        % or 1.2 respectively. Such pixels are set to zero, black.
        
        %     figure(199); imshow(L);
        
        im = video(1:zqs,:,:,t);
        
        
        
        
        
        
        %         redback = round(mode(mean(im_background(:,:,1))));
        %         greenback = round(mode(mean(im_background(:,:,2))));
        %         blueback = round(mode(mean(im_background(:,:,2))));
        %
        %         tester = im;
        %         tester(:,:,1) = tester(:,:,1)-redback;
        %         tester(:,:,2) = tester(:,:,2)-greenback;
        %         tester(:,:,3) = tester(:,:,3)-blueback;
        
        im_L = im - im_background;
        
        
        %%
        % EDIT FROM HEK APRIL 21, 2014
        % The following line was added to eliminate noise beyond the rat and
        % help clarify each frame. What appears to happen in some videos is a
        % "splotchiness" of what should be completely black background.
        % Instead, what should be close to [0,0,0] is approaching [15,15,15]
        % and is enough to mess up the background substraction method. The
        % following line eliminates rgb values of less than [10,10,10] to
        % preserve the solid black background. The animal outline does not seem
        % to suffer any degradation.
        
        im_L = uint8(im_L(:,:,:)>10).*im_L;
        
        im_L(1:22,:) = 0;
        %     figure(99); imshow(im);
        im_L = rgb2hsv(im_L);
        %             figure(100); imshow(im_L);
        %         im_L= rgb2hsv(im_L);
        %         im_LChannel1 = im_L(:,:,1);
        im_LChannel3 = im_L(:,:,3);
        
      
        GT = graythresh(im_LChannel3);
        %         figure(101); imshow(im_LChannel1);
        %         figure(102); imshow(im_LChannel3);
        %     L = im2bw(im_LChannel3,GT/2);
        
%         L = im2bw(im_LChannel3,GT/2); %TRADITIONAL WAY
        L = im2bw(im_LChannel3,GT/2.5); % FOR WHEN THE ANIMAL IS NOT LIT WELL FROM BELOW
        L = imdilate(L,strel('square',dilaterat));
        
        %L=L-base(1:zqs,:);
        %    % one line above commented off jan fourth 2013, becuase the green screen
        %    % works well enough, and someitmes you actually get saturation lines in
        %    % the back that will cause part of the rats foot to get subtracted. this
        %    % is a  disaster for tracking feet. The line was originally intended to
        %    % clean out things inthe back that are white... there arent any, really.
        
        %    L (L < 0) =0;	% this line probably redundant without base subtraction above.
        
        [L num]=bwlabel(L);
        stats=regionprops(L,'area','centroid');
        area=[stats.Area]';
        
        
        
        areacatch = size(area);
        if areacatch(1)~=0
            L (L(:) ~= find(area(:)==max(area(:)), 1 ) )=0;
            L (L(:) ~= 0 )=1; % this block finds only the largest object on screen.
            % sets rest to zero, or black.
        else
            L(:) = 0;
        end
        
        if TF_ShowAll == 1 || TF_TopTracker == 1 || TF_Tracker == 1
            figure(20); imshow(im);
            figure(21); imshow(L);
        end
        
        %this image processing is designed to minimize the presence of glare;
        %ideally the foot will be a flat plane when it is done.
        L=imfill(L,'holes');   L=bwmorph(L,'spur');
        ste=strel('line',5,0); %L=imerode(L,(ste));   L=imdilate(L,(ste));
        
        %input('Press Any Key to Continue');
        
        %this block creates 3 still images of rat and saves them, to verify ROI.
        %( "range of interest" is "ROI" )
        if  t==framemid
            figure2=L;
        end
        if  t==framemid+round(frames/4)
            figure3=L;
        end
        if  t==framemid-round(frames/4)
            figure1=L;
        end
        if (t==1) && (framemid-round(frames/4) < 1)
            figure1=L;
        end
        
        L=bwperim(L);
        [Z X]=(find(L==1));
        Zt = Z(Z >= max(Z)-3 );% Zt is "Z truncated"
        Xt = X(Z >= max(Z)-3 );% Xt is "X truncated"
        % block defines first cut of floor as within 4 pixels, will later make
        % the floor a funciton of X only, within three pixels;
        % right now floor is a functoin of X as well as Time. see below:
        
        if vel>0
            nox_top = max(X);
        elseif vel<0
            nox_top = min(X);
        end
        
        if TF_ShowAll == 1 || TF_TopTracker == 1 || TF_Tracker == 1
            figure(22); imshow(L);
        end
        
        clear im
        
        for j=1:numel(Xt)
            floor(t,Xt(j))=Zt(j);
            % for now the floor is a function of time as well as space(X), will later depend only on x.
            % floor(t,x)  is an array of z values vs Time (row) by X (col)
            % for repeted X coordinates the higher Z (lowest on still image) is written.
        end
        
        clear stats allarea
        
        %L_nose=ones( size( video(Yst:end,:,1,t)  ));
        im_nose = video(Yst:end,:,:,t);
        im_nose_L = im_nose - im_bottombackground;
        im_nose_L = rgb2hsv(im_nose_L);
        im_nose_LChannel3 = im_nose_L(:,:,3);
        GT = graythresh(im_nose_LChannel3);
        L_nose = im2bw(im_nose_LChannel3,GT/4);
        
        %     L_nose( video(Yst:end,:,2,t)*1.1 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
        %     L_nose( video(Yst:end,:,3,t)*1.2 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
        
        L_nose=imerode(L_nose,strel('square',3))-imerode(base(Yst:end,:),strel('square',3));
        %L=L-base(Yst:end,:);
        %above line is commented off in favor of the line two above. seems to
        %work just fine. circa jan 17th.
        L_nose( L_nose<0)=0;
        
        L_nose=imerode(L_nose ,strel('disk',2));      [L_nose num]=bwlabel(L_nose);
        stats=regionprops(L_nose,'area');        allarea=[stats.Area]';
        
        if allarea>0
            L_nose(L_nose(:)~= find(allarea(:)==max(allarea(:)), 1 ))=0;
            L_nose(L_nose(:)~=0)=1;
            L_nose=imdilate(L_nose,strel('disk',2));
            L_nose=imfill(L_nose,'holes');
            % This block finds the largest object on screen. set rest to zero.
            
            
            % imshow(L);getframe;
            % uncomment line above to watch a movie of XY plane.
            
            clear allarea stats cent ratbox
            
            stats=regionprops(L_nose,'area','centroid','BoundingBox');
            allarea=max([stats.Area]);
            cent=[stats.Centroid];
            ratbox=[stats.BoundingBox];
            ratwide(t)=ratbox(4);
            % this block defines an area close to the foot strike. use this area to
            % find a paw when the paw tracker is invoked later on in code. "cent"
            % is the variable that carries forward. short for "center".
            
            % determine if the rat is on the screen completely
            onleft(t)=sum(L_nose(:,1));
            onright(t)=sum(L_nose(:,XMAX));
            
            [Y X]=find(L_nose==1);
            if vel>0 && onright(t)==0 && allarea>200
                nox(t)=max(X);
                nosey(t)=mode(Y(X==max(X)));
            end
            if vel<0 && onleft(t)==0 && allarea>200
                nox(t)=min(X);
                nosey(t)=mode(Y(X==max(X)));
            end
            
            if onleft(t)==0 && onright(t)==0
                cenx(t)= cent(1); ceny(t) = cent(2);
                caprox(t)=cent(1); caproy(t)=cent(2);
            end;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % statements below to find the aproximate center when not
            % onscreen, in the interest of getting all foot strikes.
            % caprox/caproy is short for "center aproximate_x/y"
            
            if (onleft(t)>0 && vel<0) ||(onright(t)>0 && vel>0)
                lth=(Area- allarea) / max(onright(t),onleft(t));
                lth(lth<0)=0;
                caprox(t)= cent(1) + (vel*lth/2) ; caproy(t)=cent(2);
            end
            if (onleft(t)>0 && vel>0)|| (onright(t)>0 && vel<0)
                lth=(Area- allarea) / max(onright(t), onleft(t));
                lth(lth<0)=0;
                caprox(t)= cent(1) - (vel*lth/2) ; caproy(t)=cent(2);
            end % note that some aproxoimate centriods will be off screen.
            %         distorted(t) = abs(nox_top - nox(t));
        end % end  the if-statement for: allarea>0
        if TF_ShowAll == 1 || TF_BottomTracker == 1 || TF_Tracker == 1
            figure(23); imshow(im_nose);
            figure(24); imshow(im_nose_LChannel3);
            figure(25); imshow(L_nose);
        end
        
        
        % CODE AUGMENTED by HEK april 24 2014
        % The distortion code was altered to take into account cases where the
        % animal disappears early or arrives late into the ROI. This new distortion
        % code limits the distortion calculations to only the range in which the
        % animal is present on the screen. This helps the pawfinder lines later.
        
        % Previous distortion calculation by KDA
        %     if t == frames25
        %         distorted25 = abs(nox_top - nox(t));
        %     elseif t == frames75
        %         distorted75 = abs(nox_top - nox(t));
        %     end
        
        topnose = [topnose;nox_top];
        if t>1 && sum(max(L))>0
            topnosevel(t) = topnose(t)-topnose(t-1);
            
        else
            topnosevel(t) = 0;
            topnose = [topnose;0];
        end
        
    end;
    
    
    
    
    onscreen = min(find(topnose>0));
    % topnose = topnose(topnose>0);
    topnosevel = abs(topnosevel);
    topnosevel(topnosevel>1.25*mean(topnosevel)) = 0;
    topnosevel(topnosevel<.75*mean(topnosevel)) = 0;
    topnosevel=topnosevel(topnosevel~=0);
    % topnose = topnose(1:length(topnosevel));
    offscreen = onscreen+length(topnosevel);
    framesinview = [onscreen, offscreen];
    if length(framesinview)<2
        framesinview(2) = frames;
    end
    framesinview25 = framesinview(1) + round(.25*(framesinview(2)-framesinview(1)));
    framesinview75 = framesinview(2) - round(.25*(framesinview(2)-framesinview(1)));
    % distorted25 = abs(topnose(framesinview05-onscreen)-nox(framesinview05));
    % distorted75 = abs(topnose(framesinview95-onscreen)-nox(framesinview95));
    
    distorted25 = abs(topnose(framesinview25)-nox(framesinview25));
    distorted75 = abs(topnose(framesinview75)-nox(framesinview75));
    
    
    
    
% end














%continuation of previous code
if Distortion_Switch == 0
    distorted = round((distorted25+distorted75)/2);
    display(' ');
    if max(distorted) > 10
        display('**WARNING**');
        display(['Bottom image distortion of ',int2str(distorted), ' pixels detected.']);
        display('AGATHA_v1 will attempt to account for the distortion, but please');
        display('check the paw print output file to insure paw prints are accurate.');
    else
        display('No major distortion detected');
    end
end

if TF_ShowAll == 1 || TF_TopTracker == 1 || TF_Tracker == 1
    input('Press Any Key To Continue')
    close(20);
    close(21);
    close(22);
end
if TF_ShowAll == 1 || TF_BottomTracker == 1 || TF_Tracker == 1
    close(23);
    close(24);
    close(25);
end



%%%%%%this block moved out side loop to create montage april 22, 2013%%%%%%
figure(1);
divider=ones(2,size(figure1,2));% print out a line of two pixel wide between frames in a montage
Fig1=imshow(vertcat(figure1,divider, figure2,divider, figure3));
%TRAVIS CODE ABOVE
%divider=ones(2,size(L,2));% print out a line of two pixel wide between frames in a montage
%Fig=imshow(vertcat(L,divider,L,divider,L));
%Kyle's Fix Above
title(name);%"name" is a version of "TrialIDName" suited for strings in matlab
if vel== 1; xlabel('Rat should be moving from left to right. The lowest white areas on this image will be considered feet'); end
if vel==-1; xlabel('Rat should be moving from right to left. The lowest white areas on this image will be considered feet'); end

picname=cat(2,TrialIDName,'Stillframe Montage Output Image');

% HEK 5-8-14
saveas(Fig1,picname,'tif');
if PO_ShowAll == 0 && PO_Direction == 0
    close(1);
end;% 'VERBOSE' option for output to workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%  Creating FSTO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We will leave the floor to be for now. Below is the centriod tracker:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % clear allarea AREA area Area
% % % % nox=zeros(frames,1); nosey=nox;  caprox=nox;     caproy=nox;
% % % % cenx=nox; ceny=nosey; onleft=nox; onright=nox;   ratwide=nox;
% % % % L=zeros(  size(base(Yst:end,:)) );
% % % % TEND=framemid+5;TBG=framemid-5;TEND(TEND>frames)=frames;TBG(TBG<1)=1;

% % % % for t=TBG:TEND% "time-begin and time-end".
% % % %     % this loop uses frame-mid to find the rat in the very middle of the track
% % % %     % the reason we do this is to estimate the rat's area and then estimate
% % % %     % the centroid when the rat is partly off screen.
% % % %     clear stats allarea
% % % %
% % % %     %Yst is "Y-Start" and is defined by the XYfraction, the denominator
% % % %     %to tell us where the screen splits between top and bottom.
% % % %     L=ones( size( video(Yst:end,:,1,t)  ));
% % % %     L( video(Yst:end,:,2,t)*1.1 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
% % % %     L( video(Yst:end,:,3,t)*1.2 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
% % % %
% % % %     L=imerode(L,strel('square',3))-imerode(base(Yst:end,:),strel('square',3));
% % % %     %L=L-base(Yst:end,:);
% % % %     %above line is commented off in favor of the line two above. seems to
% % % %     %work just fine. circa jan 17th 2013.
% % % %     L( L<0)=0;
% % % %
% % % %     [L num]=bwlabel(L);
% % % %     stats=regionprops(L,'area');
% % % %     allarea=[stats.Area]';
% % % %     AREA(t)=max(allarea);%find the biggest object on screen, assign as an elemnet of array: AREA
% % % % end;
% % % % AREA(AREA==0)=[];
% % % % Area=mean(AREA);%average girth of the rat. used below to aproximate center when partly off screen.



% % % % for t=1:1:frames
% % % %     clear stats allarea
% % % %
% % % %     L=ones( size( video(Yst:end,:,1,t)  ));
% % % %     L( video(Yst:end,:,2,t)*1.1 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
% % % %     L( video(Yst:end,:,3,t)*1.2 > video(Yst:end,:,1,t) & video(Yst:end,:,1,t)< 255 )=0;
% % % %     figure(101); imshow(L);
% % % %
% % % %     L=imerode(L,strel('square',3))-imerode(base(Yst:end,:),strel('square',3));
% % % %     figure(104); imshow(L);
% % % %     L=L-base(Yst:end,:);
% % % %     above line is commented off in favor of the line two above. seems to
% % % %     work just fine. circa jan 17th.
% % % %     L( L<0)=0;
% % % %
% % % %     L=imerode(L ,strel('disk',2));      [L num]=bwlabel(L);
% % % %     stats=regionprops(L,'area');        allarea=[stats.Area]';
% % % %
% % % %     if allarea>0
% % % %         L(L(:)~= find(allarea(:)==max(allarea(:)), 1 ))=0;
% % % %         L(L(:)~=0)=1;
% % % %         L=imdilate(L,strel('disk',2));
% % % %         L=imfill(L,'holes');
% % % %         This block finds the largest object on screen. set rest to zero.
% % % %
% % % %
% % % %         imshow(L);getframe;
% % % %         uncomment line above to watch a movie of XY plane.
% % % %
% % % %         clear allarea stats cent ratbox
% % % %
% % % %         stats=regionprops(L,'area','centroid','BoundingBox');
% % % %         allarea=max([stats.Area]);
% % % %         cent=[stats.Centroid];
% % % %         ratbox=[stats.BoundingBox];
% % % %         ratwide(t)=ratbox(4);
% % % %         this block defines an area close to the foot strike. use this area to
% % % %         find a paw when the paw tracker is invoked later on in code. "cent"
% % % %         is the variable that carries forward. short for "center".
% % % %
% % % %         determine if the rat is on the screen completely
% % % %         onleft(t)=sum(L(:,1));
% % % %         onright(t)=sum(L(:,XMAX));
% % % %
% % % %         [Y X]=find(L==1);
% % % %         if vel>0 && onright(t)==0 && allarea>200
% % % %             nox(t)=max(X);
% % % %             nosey(t)=mode(Y(X==max(X)));
% % % %         end
% % % %         if vel<0 && onleft(t)==0 && allarea>200
% % % %             nox(t)=min(X);
% % % %             nosey(t)=mode(Y(X==max(X)));
% % % %         end
% % % %
% % % %         if onleft(t)==0 && onright(t)==0
% % % %             cenx(t)= cent(1); ceny(t) = cent(2);
% % % %             caprox(t)=cent(1); caproy(t)=cent(2);
% % % %         end;
% % % %
% % % %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %         statements below to find the aproximate center when not
% % % %         onscreen, in the interest of getting all foot strikes.
% % % %         caprox/caproy is short for "center aproximate_x/y"
% % % %
% % % %         if (onleft(t)>0 && vel<0) ||(onright(t)>0 && vel>0)
% % % %             lth=(Area- allarea) / max(onright(t),onleft(t));
% % % %             lth(lth<0)=0;
% % % %             caprox(t)= cent(1) + (vel*lth/2) ; caproy(t)=cent(2);
% % % %         end
% % % %         if (onleft(t)>0 && vel>0)|| (onright(t)>0 && vel<0)
% % % %             lth=(Area- allarea) / max(onright(t), onleft(t));
% % % %             lth(lth<0)=0;
% % % %             caprox(t)= cent(1) - (vel*lth/2) ; caproy(t)=cent(2);
% % % %         end % note that some aproxoimate centriods will be off screen.
% % % %     end % end  the if-statement for: allarea>0
% % % % end
%%%%%%%%%%%%%% end of centriod tracker %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% begin 2-D array processes (FSTO) %%%%%%%%%%%%%%%%%%%%%%%%%%%
% as it stands abov, floor is a func of t and x. the array below, floor_x
% is only dep'd. on x. floor_x will be subtracted from floor and 3 is added
% back in,
% thus the foot is considered to be on the ground when it is within 3 pixels
% of the floor. Set all positive pixels to 1=white, all other s are zero=black.
% these three pixels incidentally are why the duty factors are calculated
% higer than when a human does this. but 2 pixels-floors tend to generate
% non-contiguous steps on FSTO image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear floor_x eroded finder cx ct ywide xwide AREAstep iterated

%%%%%% this algorythm was abandoned, just not a clean image %%%%%%%%%%%%%%%
%i have refused to delete it. some day maybe you can get it to
%work with a  floor of 1 or 2 pixels. it relys on the mode thru time of a
%given pixel at some x coordinate, then dilates that given pixel thru X to try to generalize where
%the local floor is, but it does not do this all the way across. only locally.
% eroded=zeros(size(floor));
% FX=zeros(1,size(floor,2));
% for j=1:size(floor,2)
%     J=(floor (: ,j) );
%     if max(J)>0
%         J(J==0)=[];
%         FX(j)=mode(J);% FX is a row vector for all X
%     end
% end
% ste=strel('line',17, 0);%dilate the ~width of the paw.
% FX=imdilate(FX,ste);
% FX(FX==0)=max(FX);
%
% for t=1:frames
%     eroded(t,:)= floor(t,:)- FX  +2;% mode or mode minus one only.
% end

%%%%%%%%%%%%%%%% competing algrithm.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
floor_x=zeros(size(floor));
%"floor_ of _ x" is based on "Floor", which is dependant on time as much as on X
% "Floor" is the array that allows within 4 pixels.

display(' ');
display('Entering FSTO Calculation')
for t=1:frames
    floor_x(t,:)=max(floor)-3;
end;
% floor is 3 pix deep based on local X only, not time, and not any other X.
% the loop looks for the maximum value in columns, some places may be zero;
% There is a similar loop above in the three-D process that looks
% within four pixels of max on each frame. this is becuase some slope to floor is alowed in the
% loop that allows four pixels and it is looking for the floor per frame
% not per each X pixel. here we are just talking about local X for each
% pixel. if a pixel moving thru time is not white within 3 pixels of the maximum respective of
% time, it doesnt count as a foot.
% Thus for example if the maximum Z coordinate (respective of time for X=500 is z=68,
% the foot will be considered on the floor at any time that Z>=66, but not where Z=65.

floor_x(floor_x<0)=0;
eroded=floor-(floor_x);

eroded(eroded > 0)=1;   % create the 2-D array of 1 or 0. this is the frist cut of the FSTO plot
eroded(eroded <= 0)=0;
% "Eroded" is used to find centriods of step-objects on the FSTO plot.
% later the array "finder" will be used to find the toeoffs and strikes.
eroded=imfill(eroded,'holes');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This sectoin of code below creates the FSTO plot and looks for
% steps in the X-T plane.
% This algorythim will find the centroids of steps of the allowed size in
% the X-T plane and go back to "finder" and find Time-extrema for the step.
% forelimbs do not resolve as easily on array "finder", so there is also a T-OFF &
% SKT estimator built in below to be used for fore paws only.
% note. the Toeoff and STK estimator will estimate for all steps, but the
% estimated values will later be discarded in the case of hind paws.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







eroded = floor;


ste = strel('square',3);
% eroded = imdilate(eroded,ste);
eroded=imfill(eroded,'holes');
eroded = imerode(eroded,ste);


% 
% eroded = imerode(eroded, strel('line',5,0));
% eroded=imfill(eroded,'holes');
% eroded = imdilate(eroded, strel('line',5,0));


% The three lines above are used to seal the gap that sometimes occurs
% where the rats toes curl: FSTO steps can in that case split in half.
% There is also a way to deal with this later during the processing of the
% the arrays "hind" and "fore" if this first cut does not succeed.


eroded(eroded > 0)=1;   % create the 2-D array of 1 or 0. this is the frist cut of the FSTO plot
eroded(eroded <= 0)=0;

finder=eroded;
% the array "finder" will use centroids to look for foot strikes, T-O's

% areamax=25001;

areamax = 2*areahi;  k=0 ;               iterations=1;
cx= zeros(1,100);   ct=zeros(1,100);    AREAstep=(zeros(1,100));
xwide=cx;           ywide=cx;           iterated=cx;
ystart=cx;          stkapx=cx;          toeoffapx=cx;

% elinimate small objects from the FSTO plot before looking for steps.
[L num]=bwlabel(eroded);   clear AREA;    AREA=zeros(num);
for j=1:num
    clear Ltemp stats area perim widths pitch cent;
    Ltemp=ones(size(L));
    Ltemp(L(:)~=j)=0;
    stats=regionprops(Ltemp,'area','centroid','BoundingBox');
    area=[stats.Area]';
    if area<= arealo
        eroded(L==j)=0;
    end
end;


while areamax>areahi && iterations<8%allow 8 erosions before quitting
    %anything that needs more than 8 erosions is too large to be a step.
    if sample_fps<100
        eroded=imerode(eroded,strel('square',2));
    else
        eroded=imerode(eroded,strel('square',5));
%         eroded=imerode(eroded,strel('square',2));
    end
    % Initial erosion is important to eliminate slender protrusions from
    % the FSTO objects which are often present.
    [L num]=bwlabel(eroded);  clear AREA;    AREA=zeros(num);
    for j=1:num
        clear Ltemp cent stats area widths perim;
        Ltemp=ones(size(L));
        Ltemp(L(:)~=j)=0;
        stats=regionprops(Ltemp,'area','centroid','BoundingBox','Perimeter','Orientation');
        cent=[stats.Centroid]';
        area=[stats.Area]';
        widths=[stats.BoundingBox]';
        perim=stats.Perimeter;
        pitch=stats.Orientation;
%         if area(1)<=areahi && area(1)>= arealimit - perim*iterations*3 && area(1)>0
            

% area(1)

            %Change by HEK 3-13-2015
        if area(1)<=areahi && area(1)>= arealimit - perim*iterations*3 && area(1)> arealo  
            % the if statement considers only things that are the right
            % size, note that the "right" size at the lower end
            % changes depending on  number of iterarions already performed:
            %  perimeiter * area of erosion is subtracted from "arealimit"
            eroded(L==j)=0;
            cx(k+j)= cent(1);
            ct(k+j) = cent(2); % take centroid of obj
            AREAstep(k+j)= area(1);
            xwide(k+j)=  round( 10*iterations + widths(3));
            ywide(k+j)=  round( 10*iterations + widths(4));
            ystart(k+j)= round( 3*iterations + widths(2));
            stkapx(k+j)= widths(2)- 3*iterations;% aproxamation algorithm
            toeoffapx(k+j)=widths(4) + widths(2) + 3*iterations;
            iterated(k+j)= iterations;
            
            % correct for things that do not have realistic shapes:
            % this is based on aspect ratio in XY and also on pitch of major
            % axis.
            % the "1.6" below is known to be problematic, some steps get
            % dropped because of thier XY aspect ratio, but we need a value here
            % in order to eliminate nose drag.
            
            % %  HEK Fix 7-24-2014
            %    Collecting videos in lower frames per second than 250 squashes the pawprints
            %    and collecting in higher frames per second than 250 makes them long and
            %    skinny. They higher fps videos don't have as much of a problem b/c they
            %    have larger areas. The lower fps videos also have smaller areas.
            %    if (xwide(k+j)/ywide(k+j))>1.6 || (xwide(k+j)/ywide(k+j)< .19) ...original line
            
            
            imshow(finder)
% % %             imshow(eroded)
            hold on
            plot(cx,ct,'ro')
            hold off
% %             
            
            
            %             HEK Fix 3-23-2015
            %             General Case for determining shape ratio and eliminate tail drag
            
            if sample_fps<50
                shape_ratio = (.1+dilaterat*.1)/(sample_fps/vid_fps);
                other = (.05-dilaterat*.2)/(sample_fps/vid_fps);
            elseif sample_fps<100
                shape_ratio = (.16+dilaterat*.1)/(sample_fps/vid_fps);
                other = (.08-dilaterat*.2)/(sample_fps/vid_fps);
            else
                shape_ratio = (.25+dilaterat*.6)/(sample_fps/vid_fps);
                other = (.07-dilaterat*.1)/(sample_fps/vid_fps);
            end
            
            %             if sample_fps<100
            %                 shape_ratio = 4;
            %                 other = .19;
            %             elseif sample_fps<550
            %                 shape_ratio = 1.6;
            %                 other = .19;
            %             else
            %                 shape_ratio = 1.6;
            %                 other = .05;
            %             end
            
            
            % (xwide(k+j)/ywide(k+j))
            % shape_ratio
            
            
            if cx(k+j)> Xend || cx(k+j)< Xstart
                cx(k+j)=0;
                ct(k+j)=0;
            end
            
            
            
            
            
            
            if (xwide(k+j)/ywide(k+j))>shape_ratio || (xwide(k+j)/ywide(k+j)< other)
                cx(k+j)=0; ct(k+j)=0;
                %"eliminate it if very wide || very narrow"
%             elseif area/sample_fps<1.8
                elseif area/sample_fps< .8
                cx(k+j)=0; ct(k+j)=0;
            end;
            
%             if pitch>0
%                 if pitch< pitchmin && pitch>-1*pitchmin
%                     %"eliminate it if is too shallowly pitched"
%                     cx(k+j)=0; ct(k+j)=0;
%                 end
%             else
%             end
        end
        AREA(j) = area(1); % fill AREA for loop checker.
    end
    k=k+j;
    areamax=max(AREA(:));    %continue the loop if there are still a=large objects on "eroded"
    iterations=iterations+1; %stop the loop if it has run 8 times.
end

% truncate output arrays (optional 2nd, 3rd arguments: Xcoordinates)
ct(cx<Xstart | cx> Xend)=0;
cx(cx<Xstart | cx> Xend)=0;

% this block of stements takes things that have a centroid of 0,0 and
% throws them out.
% Many of these individual arays will be concatenated into an array
% called "mtx". "mtx" will then be split into "hind" and "fore" and
% sorted according to centriod in Time,  ~center stance
AREA(AREA==0)=[];    AREAstep(ct==0)=[];
cx=round(cx);        ct=round(ct);
xwide(ct==0)= [];    ystart(ct==0)=[];     ywide(ct==0)= [];
iterated(ct==0)=[];  stkapx(ct==0)= [];    toeoffapx(ct==0)=[];
cx(cx==0)=[];        ct(ct==0)=[];

clear L Ltemp cent stats allarea;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function below uses the arrays ct and cx, returned above, superimposes
% them on array "finder" which has the full foot strike as found by "floor"
% there are two clones of the same block; one for vel>0, one for vel<0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the call for sub function fstoseek below will return values for strike
% and toe off and x coordinate for toe off. see also fstoseek anotation.



[strike, toeoff, xtoeoff, toeoffapx, freq]=fstoseek(ct,cx,toeoffapx,finder, vel,xwide,ywide,XMAX,frames,'a',sample_fps);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% here ends the process involving the side image of the rat. Below are the
% intermediate divisions/ concatenations of "mtx" into "hpaws" and
% "fpaws". A  final concatenation with errors/stride stats will come later.
% This is hard to read, but know that "mtx" is a concatenation of almost
% every parameter thus far found, some columns like "stkapx" are place
% holders that will be truncated out when the final matrix of "fore" and
% "hind" are made. "xwide" and "ywide", reffer to the shape of the step on the
% FSTO plot. At the end there are two error cols to tell us if the step is
% clean or questionable, they mean slightly different things on fore vs
% hind. Fore allows for approximate TO and STK to be found, with an error.
% Hind strikes sometimes come later in time than expeted, and an error col
% for this is resereved (note that you should not ever seen these error if
% using CAPITALS for the criteria option argument: "A" "D" "K" "S" etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iterated(iterated==0)=0.1;
dnox=zeros(size(nox));dcenx=dnox;%"delta nose x , and delta center x"
[r,m,b] = regression(cx,ct);


%%%%%%%%%%%%%%%%%%%%%%% patch feb 28th 2013 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if criteriaoption=='A'||criteriaoption=='S'||criteriaoption=='K'||criteriaoption=='D'||criteriaoption=='L'
    % note that lowercase will not invoke this "IF" . basically this will
    % eliminate tail drag. It does not do  much to adress nose drag
    % at all. But tail drag is far enough away from the line of regression
    % that it can be targeted in this loop.
    % (note, if you are eliminating steps becuase of this loop, try the
    % lower case letters: 'a' 'k' 'd' etc.
    for j=1:numel(ct)
        errcolX(j)= abs( ct(j)- (cx(j)*m+b) );
        %delta from regression line, the second error col for hind paws.
    end
    
    dmeanX=2.0*mean(errcolX(:));
    % an average for generalizing when the "step" is highly quesitonable.
    
    looplim=numel(ct);
    j=1;
    
    %this while loop empty-sets the suspected tail drag:
    while j<=looplim
        if errcolX(j)> dmeanX% if distance is too high, eliminate []
            ct(j)=[]; iterated(j)=[]; ywide(j)=[]; xwide(j)=[]; toeoffapx(j)=[];
            cx(j)=[]; xtoeoff(j)=[]; strike(j)=[]; toeoff(j)=[]; stkapx(j)=[];
            freq(j)=[];  looplim=looplim-1;      errcolX(j)=[];       j=j-1;
        end
        j=j+1;
    end
    
    %now a  new regression line is taken after eliminating tail drag.
    [r,m,b] = regression(cx,ct);
end
%%%%%%%%%%%%%%%%%%%%%%%% end patch feb 28th 2013 %%%%%%%%%%%%%%%%%%%%%%%%%%

%create "mtx" for all steps, fore and aft.
%ct=center in time, cx=center in x, xtoeoff= x coor of toe off, freq=
%frequency with which the strike mode occurs on FSTO; strike is the MODE of
%strike on FSTO.
mtx=cat(1, ct ,cx,xtoeoff,strike, toeoff, freq, stkapx,toeoffapx, iterated,ywide,xwide)';
%(1,2,   3        4       5       6       7       8       9,    10,      11)


% This block attampts to find the aproximate toe off and strike for steps that
% return 0 for strike or TO. to do so it generalizes the error between
% aproximations and actual strikes, and then assumes that error on all
% aproximations. The aproximation is only used for fore paws.
TOerr=toeoff-toeoffapx;
TOerr(toeoff==0)=[];
avgerr=mean(TOerr);
toeoffapx=toeoffapx+avgerr;%final approximation. for fore paws only
STKerr=strike-stkapx;
STKerr(strike==0)=[];
avgerr=mean(STKerr);
stkapx=stkapx+avgerr;%final approximation. use for fore paws only

j=1;
clear Hind
clear errcol2
% hindpaws will ignore approximate strikes and toeoffs.
% so we will pull out the array Hind now, beofre allowing aproximations
for k=1:size(mtx,1)
    if ct(k)> ( cx(k)*m+b ) && mtx(k,4)>=1 && mtx(k,1)>=1 && mtx(k,5)<=frames
        Hind(j,:)=mtx(k,:);
        errcol2(j)= abs( ct(k)- (cx(k)*m+b) );%delta from regression line
        j=j+1;
    end
end;
Hind(:,12)=errcol2';%need to insert errcol2 into Hind before sorting by time

% hind paws have been accounted for and saved to matrix "Hind".
% overwrite toeoff for more accurate picture of fore paw behaviour in array: "mtx":
[mtx(:,4),mtx(:,5),mtx(:,3),mtx(:,8),mtx(:,6)]=fstoseek(mtx(:,1),mtx(:,2),mtx(:,8),finder,vel,mtx(:,11),mtx(:,10),XMAX,frames,'F', sample_fps);
% the 'F' option disallows discontinuities in the FSTO plot.
% this is necessary becuase often times the TO recorded for fore will actually be the TO for the same-side hind.

% hind paws can also benefit from the 'H' option, in the case of a relatively
% long stance time, which will return as Toeoff=zero & xtoeoff=zero in the first call of "FSTOseek.m".
% the H option is slightly different from F as it allows a further search in time
% for the toeoff, as well as disalowing discont's.  The F option does not
% allow extended search in dimension of time.
[NEWS,NEWTO,NEWTOX,Hind(:,8),NEWF]=fstoseek(Hind(:,1),Hind(:,2),Hind(:,8),finder,vel,Hind(:,11),Hind(:,10),XMAX,frames,'H',sample_fps);
for j=1:size(Hind,1)
    if Hind(j,5)<=0
        Hind(j,5)=NEWTO(j);
        Hind(j,3)=NEWTOX(j);
    end
end % will overwrite with new returns if old returns for Toeoff=0
% returns for NEWS and NEWF are not used, are space fillers to call function

% forepaws will further include approximate strikes where needed.
% here approximations are added to cols , 5, 4, if "0" was returned before
sortrows(mtx,1);
mtx(:,12)=0;%new col for error notations where aproximate toe off or strike is used.
for j=1:size(mtx,1)
    if mtx(j,5)> 1.6*mtx(j,10)+mtx(j,4) % if strike >about 1.5*ywide will indicate that this is questionalbe
        mtx(j,5)= mtx(j,8 );            % "y-wide" was found during the erosion process.
        mtx(j,12)=20202;
    end
    if mtx(j,5)==0 && mtx(j,8)<frames
        mtx(j,5)=round(mtx(j,8) );
        mtx(j,3)=round(mtx(j,2) );
        mtx(j,12)=20202;
    end
    if mtx(j,4)==0 && mtx(j,7)>1
        mtx(j,4)=round(mtx(j,7));
        mtx(j,12)=mtx(j,12)+01010;
    end
end
% this for-if-if block looks for forepaws with no toeoff/ or strike.
% will insert approximate toeoff and strike where needed,with err message.

j=1;%create array: 'Fore' which *does* include approximations for strike and toeoff.
for k=1:size(mtx,1)
    if ct(k)< ( cx(k)*m+b ) && mtx(k,4)>=1 && mtx(k,1)>=1 && mtx(k,5)<=frames
        Fore(j,:)=mtx(k,:);
        errcol3(j)= abs( ct(k)- (cx(k)*m+b) );
        j=j+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% after below  truncations we can no longer call the fstoseek() function:

fpaws=sortrows(Fore,1);% sorted by time of ~centerstance. will be 8 cols.
hpaws=sortrows(Hind,1);% sorted by time of ~centerstance. will be 7 columns

j=2;loopmax=(size(hpaws,1));%correction for steps where the toe curl of the rat has created a seam in a single step.
while j<loopmax
    if 27> abs(hpaws(j,2)-hpaws(j-1,2))             % difference of x coordinates.
        hpaws(j-1,4)=min( hpaws(j,4),hpaws(j-1,4) );% replace with highest of strikes
        hpaws(j-1,5)=max( hpaws(j,5),hpaws(j-1,5) );% replace with lowest of TO's.
        
        newtoeoff= [ hpaws(j,5),hpaws(j-1,5) ];
        newtoeoffx=[ hpaws(j,3),hpaws(j-1,3) ];    %preparing to replace xtoeoff coordinate with correct coordinate
        newtoeoffx(newtoeoff~=hpaws(j-1,5))=[];
        hpaws(j-1,3)=newtoeoffx(1);                %replacemewnt made based on alignment with correct toe off in time.
        
        loopmax=loopmax-1;                          % change the limit of the iteration.
        hpaws(j,:)=[];                              % nix the repeated step in the array 'hpaws'.
    end;j=j+1;
end;%end correction for pesky double steps.

j=2;loopmax=(size(fpaws,1));%correction for seamed steps
while j<loopmax
    if 27> abs(fpaws(j,2)-fpaws(j-1,2))             % difference of x coordinate.
        fpaws(j-1,4)=min( fpaws(j,4),fpaws(j-1,4) );% replace with highest of strikes
        fpaws(j-1,5)=max( fpaws(j,5),fpaws(j-1,5) );% replace with lowest of TO's.
        
        newtoeoff= [ fpaws(j,5),fpaws(j-1,5) ];
        newtoeoffx=[ fpaws(j,3),fpaws(j-1,3) ];    %preparing to replace xtoeoff coordinate with correct coordinate
        newtoeoffx(newtoeoff~=fpaws(j-1,5))=[];
        fpaws(j-1,3)=newtoeoffx(1);                %replacement made based on alignment with correct toe off in time.
        
        loopmax=loopmax-1;                          % change the limit of the iteration.
        fpaws(j,:)=[];                              % nix the problem row in the array 'hpaws'.
    end;j=j+1;
end;%end correction for seams due to toe curl.

errcol2=hpaws(:,12)';  % extract prior to truncations of hpaws

Xwide=hpaws(:,11)';  % need this extraction for backup fore paw tracker.
%the backup forepaw tracker relies on a hind paw close in XY space to
%tell the code which side the fore paw strike falls on, if no print can be found.

hpaws(:,12)=[];%trunc errcol2, to concatenate later.
hpaws(:,10)=[];%trunc ywide
hpaws(:,10)=[];%trunc xwide
hpaws(: ,7)=[];%trunc stkaprox
hpaws(: ,7)=[];%trunc TOffaprox
fpaws(:,10)=[];%trunc ywide etc., but do not trunc errcol (col 12 in mtx).
fpaws(:,10)=[];%trun
fpaws(: ,7)=[];%trun
fpaws(: ,7)=[];%leaves "iterated" in column 7

% the above truncations are designed to eliminimate information that we do
% not really want on the XLS outputs. The information has served its
% purpouses. we are done with it unless it was extracted as a new
% variable.

errcol3=cat(2,errcol3,errcol2);
dmean=3*mean(errcol3(:));
% dmean is allowed to be 3x the mean of the delta of each cetriod to line.
% errcol2 will concatenate back onto hpaws later, based on dmean.
% this latest error block is totaly irrelevant if you are using CAPITALS
% for your criteria_option, since those things that would trigger ercol3 are already eliminated.


%%%%%%%%%%%%%%%%%%%%%% "matrix of velocity data" %%%%%%%%%%%%%%%%%%%%%%%%%%
Dxy=zeros(1,(numel(cenx)));
%cenx, ceny come from the centriod tracker block:"center x" and "center y"
%Dxy is a disttance in XY from frame to frame , tracking centriod.

for j=2:(numel(cenx))
    if cenx(j)>0 && cenx(j-1)>0
        Dxy(j)=( ( cenx(j)-cenx(j-1) )^2 + ( ceny(j)-ceny(j-1) )^2  )^.5;
    end;
end% regression of Dxy (speed, or D-position) should be a line=constant
%note that there are places that Dxy==0 since the conditoin will not be
%met.

sigD=zeros(1,numel(Dxy)); %"sigma distance"
for j=2:numel(Dxy)
    sigD(j)=Dxy(j)+sigD(j-1);
    % sigD(1)  always == 0, and sometimes Dxy(j) also ==0,
    % sigD is a cumulative position vector, positive line of constant slope.
end
sigD(cenx==0)=0;%set to zero when rat is partly off screen.
% note that there are places that sigD will be zero, but cenx>0.

mtxvel=[1:frames]';%"matrix of velocity"
mtxvel=cat(2,mtxvel,nox,nosey,dnox,cenx,ceny,sigD',caprox,caproy);
% the sigD' used above is just an approxamation of the correct array size.
% the flaw with the above is that when the centriod is lost part way thru
% video, which does happen at times, the position vector jumps down to zero
% then back up to precisely where you left off, but it shoud be further along.
% It has been superceded at this point by the below: March 30, 2013.

% below is the operation to find the line of regression.

% use actual steps to chop relevant velocity along time axis.
framest=-30+min(hpaws(1,4), fpaws(1,4));    % stk.= col 4, T.O.=col 5.
framest(framest<1)=1;                       % stk. will be the min time.
framend=30+max(hpaws(end,5), fpaws(end,5)); % toe off is the max time.
if min(hpaws(end,5),fpaws(end,5))==0 || framend>frames
    % if the last step toeoff =0 (ie no toeoff)--> go to end of video
    framend=frames;
end

Time=framest:framend;        % "frame start and frame end"
cenx=cenx(framest:framend);  % chop relative to good steps
ceny=ceny(framest:framend);
cenx(ceny==0)=[];            % eliminate if no XY coordinate.
Time(ceny==0)=[];
ceny(ceny==0)=[];
Dxy=zeros(1,(numel(cenx)));



%% HEK December 9, 2014 - Velocity Fix
% Velocity was previously calculated as instantaneous velocity and included
% a damping error in which frames during which the centroid was not calculated
% showed up as zero and were then rewritten with data from either side of the
% hole. This artificially lowered the velocity. Velocity is now found using
% the position vector relative to the origin and compensates from different
% frame rates.

clear position pvec
for j=2:(numel(Time))
    
    if (cenx(j)-cenx(j-1)) * vel > 0%this if-statment is part of the May 10th patch.
        Dxy(j)=( ( cenx(j)-cenx(j-1) )^2 + ( ceny(j)-ceny(j-1) )^2  )^.5;
        position(j,1:2) = [Time(j)*frameskip sqrt((cenx(j)-cenx(1))^2+(ceny(j)-ceny(1))^2)];
        
        
%         position(j,1:2) = [Time(j)*frameskip sqrt(cenx(j)^2)];
        
%         Dxy(j)=(cenx(j)^2 + ceny(j)^2)^.5;
        
        
    end%prior to May 10th the above Dxy= line was not based on an IF-condition.
    
end
%%

% Dxy is the pythagorean from point to point.
% This time there are no zero points allowed (where centriod is not
% recorded). all arrays have been shortened: Time, ceny, cenx, and Dxy. so
% now each known coordinate in X and Y is associated with  a CORRECT
% coordinate in time.

%patch May 10, 2013: need to restrict Dxy where the rat is moving backward,
%IE, the tail may dissapear and reappear causing jumps in the centroid
%which are not real. If a  jump backward is detected, Dxy will be 0. we
%will let the jump forwards stay for now since I do not see a robust way to adress them.
%Dxy now is only non zero where the rat is moving forward
%Dxy(1) has always been 0, and now there are other places, potenitally
%%%%***No new code. the patch exists as a new IF-statment above. *****

SIGD=zeros(1,numel(Dxy)); % cumulative postition vector (S)

for j=2:numel(Dxy)
    % % % % %     if ( Dxy(j) > 8*Dxy(j-1) ) && Dxy(j-1)>0 && Dxy(j)>0 && (Time(j)-Time(j-1))==1
    % % % % %         Dxy(j)=median(Dxy);
    % % % % %         % this line acct's for sudden loss of tail--> jump of centriod,
    % % % % %         % which does happen now and then, jump permitted in
    % % % % %         % case of time Delta > 1
    % % % % %     end
    %%%%%%%%%commented off May 10, 2013 in favor of the patch above
    SIGD(j)=Dxy(j)+SIGD(j-1);
    % add the Dxy to the last know position to track rat over S-vector.
    %   per the patch May 10, 2013 there may be places that SIGD does not
    %   increase, since Dxy=0. This is preferable to a centriod jump
end

mtxvel(:,7)=zeros(size(sigD'));% clears  the old sigD' that is just an aproximation

k=1;
% Go back and fill the matrix:'mtxvel' with the more precise positon vector: 'SIGD'.
% 'SIGD' is not the right size necesarily, so there is a loop to fill 'mtxvel'.
% Use the same criteria to fill matrix: "mtxvel", as was used for
% setting 'Time'=[]: if ceny>0, then record value, if not, count j but not k.
for j=framest:framend
    if mtxvel (j,6)>0 && k<=numel(SIGD)
        mtxvel(j,7)=SIGD(k);% fill position vector column, G in .XLSX
        k=k+1;
    end
end


%the regression function is the old way to calculate velocity, it is difficult to augment when running
%multiple fps videos. The process below is less sophisticated, but works
%for all sampling speeds.
[R, wrong_velocity, int]=regression(Time,SIGD);
% velocity=round(velocity*10000)/10000;



%% HEK December 9, 2014 - Velocity Fix
% Velocity was previously calculated as instantaneous velocity and included
% a damping error where frames during which the centroid was not calculated
% showed up as zero and were then rewritten with data from either side of the
% hole. This artificially lowered the velocity. Velocity is now found using
% the position vector relative to the origin, removing data where the
% centroid can't be calculated, and compensating for different frame rates.

clear position pvec
for j=2:(numel(Time))
    
    if (cenx(j)-cenx(j-1)) * vel > 0%this if-statment is part of the May 10th patch.
        Dxy(j)=( ( cenx(j)-cenx(j-1) )^2 + ( ceny(j)-ceny(j-1) )^2  )^.5;
        position(j,1:2) = [Time(j)*frameskip sqrt((cenx(j)-cenx(1))^2+(ceny(j)-ceny(1))^2)];
        
        
        %         position(j,1:2) = [Time(j)*frameskip sqrt(cenx(j)^2)];
        
        %         Dxy(j)=(cenx(j)^2 + ceny(j)^2)^.5;
        
        
    end%prior to May 10th the above Dxy= line was not based on an IF-condition.
    
end

position = position(position(:,1)~=0,:);


p = polyfit(position(:,1),position(:,2),1);
velocity = p(1);

%%






RMSE= sqrt(mean( (SIGD - Time*velocity).^2 ));
velerr={'good linear velocity fit'};R=R;
if R<.99;    velerr={'low R squared. This may be a bad fit'} ; end
%%%%%%%%%%%%%%%% mtxvel already sorted by frame , no need to call "sort"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% outputs above are parameters of all hind steps in the array "finder"
% There may be places that the strike returns, but not toe off(/vice versa)
% toeoffs with no strike are invalid. strikes with no toeoff are allowed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure generation for FSTO plot is right below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
%default colors will be white, orange, blue and black.

if colorscheme=='T'||colorscheme=='t' %when 'if' triggers the image will be charcoal and maroon.
    %     FIG1=(cat(3,(finder*.25),zeros(size(finder)),zeros(size(finder))  ));
    %     FIG2=(cat(3,.25*ones(size(finder)),.25*ones(size(finder))-.25*finder,.25*ones(size(finder))-.25*finder));
    %     FIG=image(FIG1+FIG2);
    
    %%
    %     The new color scheme is a dark navy for steps and a light orange for
    %     the field. The colors can be changed at any point by changing the x in
    %     each statement of finder*x. The color matrix is a depth of 3 RGB image
    %     and each x determines the percentage of color associated with the plane.
    %     Thus, white would be 1 b/c 255/255=1, etc. The steps are separated from
    %     the field and can be altered independently.
    
    %     Alteration made by HEK on April 23, 2014
    
    % stepcolor = (cat(3,(finder*.2),(finder*.2),(finder*.45)));   ... currently blue
    % fieldcolor = (cat(3, .97*abs(finder-1),.89*abs(finder-1),.80*abs(finder-1))); ... currently a light orange
    
%     stepcolor = (cat(3,(finder*.1),(finder*.1),(finder*.55)));   ... currently blue
%         fieldcolor = (cat(3, .3*abs(finder-1),.3*abs(finder-1),.3*abs(finder-1))); ... currently a dark grey
%         FIG = image(stepcolor+fieldcolor);
    


finder = finder/max(max(finder));

    stepcolor = (cat(3,(finder*.75),(finder*.75),(finder*.75)));   ... currently Light Grey
        fieldcolor = (cat(3, 1*abs(finder-1),1*abs(finder-1),1*abs(finder-1))); ... currently White
        FIG = image(stepcolor+fieldcolor);
    
    
    hold on
    plot(cx,cx*m+b,'k')
    scatter(cx,ct,9,'+','k')
    % the + will plot generic centriods with out identifying yet which are
    % hind and fore; some won't have strikes, so will be niether hind nor fore
    scatter( hpaws(:,3),hpaws(:,5),'b')      %*toeoff vs. xtoeoff hind
    scatter( fpaws(:,3),fpaws(:,5),'b','v')  %toeoff vs. xtoeoff fore
    scatter( fpaws(:,2), fpaws(:,1),'v','k') %centriods fore
    scatter( hpaws(:,2), hpaws(:,1),'k')     %centriods hind
    scatter( fpaws(:,2), fpaws(:,4),'r','v') %strike fore paws now blue vice cyan.
    scatter( hpaws(:,2), hpaws(:,4),'r')     %*strike hind paws
    
    
    
    
    %%
    
%     hold on
%     plot(cx,cx*m+b,'w')
%     scatter(cx,ct,9,'+','w')
%     % the + will plot generic centriods with out identifying yet which are
%     % hind and fore; some won't have strikes, so will be niether hind nor fore
%     scatter( hpaws(:,3),hpaws(:,5),'c')      %*toeoff vs. xtoeoff hind
%     scatter( fpaws(:,3),fpaws(:,5),'c','v')  %toeoff vs. xtoeoff fore
%     scatter( fpaws(:,2), fpaws(:,1),'v','y') %centriods fore
%     scatter( hpaws(:,2), hpaws(:,1),'w')     %centriods hind
%     scatter( fpaws(:,2), fpaws(:,4),'r','v') %strike fore paws now blue vice cyan.
%     scatter( hpaws(:,2), hpaws(:,4),'r')     %*strike hind paws
    
    
    AGATHA_stepnames = [{'Hind Foot Strike Frame'}, {'Hind Toe Off Frame'},{'Hind Paw Centroid X (ventral view)'},{'Hind Paw Centroid Y (ventral view)'},{'Leg (Left=1, Right=0)'},{'Visual Location of Foot (Downstage=1, Upstage=0)'}];
 
    clear AGATHA_step
    
%     AGATHA_step(2:length(hpaws(:,2))+1,1) = hpaws(:,2);
%     AGATHA_step(2:length(hpaws(:,2))+1,2) = hpaws(:,3);



%% ADD LEFT RIGHT STEP INCLUDED IN AGATHA_STEP%%



    AGATHA_step(2:length(hpaws(:,2))+1,1) = frameskip*hpaws(:,4); %foot strike frame corrected to original video equivalent
    AGATHA_step(2:length(hpaws(:,2))+1,2) = frameskip*hpaws(:,5); %toe off frame corrected to original video equivalent
    
    
    
else
    %RGB for steps and bkgnd. :
    FIG1=(  cat(  3,  zeros(size(finder)),     (finder*33/255),            (finder*165/255) )  ) ;      % steps are blue
    FIG2=(  cat(  3,  ones(size(finder))-finder,ones(size(finder))-finder, ones(size(finder))-finder)); % bknd is white.
    FIG=image(FIG1+FIG2);
    %blue: [0 33 165]
    %orange:[255 74 0]
    hold on
    plot(cx,cx*m+b,'k')%line of demarcation.
    scatter(cx,ct,9,'+','w')%all centers.
    % the "+" will plot generic centriods without identifying yet which are
    % hind and fore; some won't have strikes, so will be niether hind nor fore
    scatter( hpaws(:,3),hpaws(:,5),'MarkerEdgeColor',[0 0 0])      %toeoff vs. xtoeoff hind
    scatter( fpaws(:,3),fpaws(:,5),'v','MarkerEdgeColor',[0 0 0])  %toeoff vs. xtoeoff fore
    scatter( hpaws(:,2), hpaws(:,1),'MarkerFaceColor',[1 74/255 0],'MarkerEdgeColor',[1 74/255 0])     %centriods hind
    scatter( fpaws(:,2), fpaws(:,1),'v','MarkerFaceColor',[1 74/255 0],'MarkerEdgeColor',[1 74/255 0]) %centriods fore
    scatter( fpaws(:,2), fpaws(:,4),'v','MarkerEdgeColor',[1 74/255 0]) %strike fore paws
    scatter( hpaws(:,2), hpaws(:,4),'MarkerEdgeColor',[1 74/255 0])     %strike hind paws
end

xlabel('approximate x-axis pixels (Direction of travel)');
ylabel('time in frames');
title({name;'FSTO (X-T) plane. Triangles: strike, toeoff or center fore';'Rounds: strike, toeoff or center hind';'White crosses are centers not included in outputs'});

saveas(FIG,cat(2,TrialIDName,'_FSTO Output Image'),'tif');
saveas(FIG,cat(2,TrialIDName,'_FSTO Output Image'),'fig');      hold off;
if PO_ShowAll == 0 && PO_FSTO == 0
    close(2);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pawtracker to find the hind paw strikes near centriod of each frame.
%
% the way this works is to find the rat's center at time of hind strike
% Code will then take a small picuture centered there, which includes the foot,
% then add that to an image of the same place taken some frames later near
% toe off; this way code can be quite certain that the only thing to add up
% to =2 is the foot. Someitmes there are saturation lines that =2, but
% there is a contraint on width allowed to consider a paw using the function
% "region props"
%
% The paw is found using color segmentation in the lines "strike()=" and
% "stance()="
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Finding Paw Prints
steps=size(hpaws,1);
clear foot centerx centery delta D
foot=zeros(1,numel([1:steps]));sym=foot;duty=foot;stdlth=foot;stdwd=foot;
centerx=foot; centery=foot; D=foot; delta=foot;
Lout=zeros(size(video(:,:,1,1)));
WIDEx = 0;

display('Detecting Hind Paws');
for step=1:steps
    clear im strike stance L time lox hix loy hiy allarea ctr stats statsctr;
    time=round(.2*hpaws(step,1)+.8*hpaws(step,4));%strike is col 4 of mtx
    if time>1  && time<frames
%                 lox=round((caprox(time)-ratwide(time)/1.5)); %1.5's were 1.8s - KDA Switch
%                 hix=round((caprox(time)+ratwide(time)/1.5));
        
        % HEK
        % taking velocity into accound when searching for the paw.
        
%         meanvel = abs(mean(topnosevel))/10;
        meanvel = velocity;
        if meanvel>1.5
            meanvel = 1.5;
        elseif meanvel<.75
            meanvel = .75;
        else
            meanvel = .75*meanvel;
        end

        if vel>0
            lox=round((caprox(time)-meanvel*ratwide(time)/1)); %1.5's were 1.8s - KDA Switch
            hix=round(caprox(time)+.25*meanvel*ratwide(time)/1);
        elseif vel<0
            lox=round(caprox(time)-.25*meanvel*ratwide(time)/1); %1.5's were 1.8s - KDA Switch
            hix=round(caprox(time)+meanvel*ratwide(time)/1);
        end
        

        loy= round(Yst + (caproy(time)-ratwide(time)/1.5)); %zero caproy- "center aprox y"- is at Yst (Ystart)
        hiy= round(Yst + (caproy(time)+ratwide(time)/1.5)); %use caproy- "center aprox y"- as sometimes "ceny" is not resolved.
        
%         figure
%         imshow(video(:,:,:,time));
%         %         imshow(video(loy:hiy,lox:hix,:,time));
        %         imshow(video(:,lox:hix,:,time));
        %         imshow(video(:,topnose(time):topnose(time)+distorted25,:,time));
        %         imshow(video(:,caprox(time)-ratwide(time):caprox(time)+ratwide(time),:,time));
        %         imshow(video(:,caprox(time)-25:caprox(time)+25,:,time));
        
        
        
% %         Distortion fix by KDA 2/6/14
% %         if lox < round(XMAX*0.25)
% %             lox = lox + distorted;
% %             if lox < 1
% %                 lox = 1;
% %             end
% %             hix = hix + distorted;
% %             if hix > XMAX
% %                 hix = XMAX;
% %             end
% %         elseif lox > round(XMAX*0.75)
% %             lox = lox - distorted;
% %             if lox < 1
% %                 lox = 1;
% %             end
% %             hix = hix - distorted;
% %             if hix > XMAX
% %                 hix = XMAX;
% %             end
% %         end
        
        
        lox(lox<1)=1;      hix(hix>XMAX)=XMAX;
        loy(loy<1)=1;      hiy(hiy>ZMAX)=ZMAX;
        
        
        %                 figure(17); imshow(im);
        
% %         figure
% %         imshow(video(:,lox:hix,:,time));
%         

loy = loy+10;
hiy = hiy-10;

close all

% figure
% imshow(video(:,:,:,time));
% 
% figure
% imshow(video(loy:hiy,lox:hix,:,time));
        %         strike=zeros(size(im,1),size(im,2));
        %         strike( im(:,:,2)>im(:,:,3)*GBlo & im(:,:,1)>im(:,:,2)*RGlo & im(:,:,1)<im(:,:,2)*RGhi & im(:,:,2)<im(:,:,3)*GBhi & im(:,:,1)>minred)=1;
        %         figure(18); imshow(strike);
        
        
%                figure(19); imshow(hsv_im(:,:,1));
      
        if hpaws(step,5)>0                                 % capture if TO>0
            time2=round(.9*hpaws(step,1)+.1*hpaws(step,5));% toeoff is col 5 of "mtx"
        else
            time2=round(hpaws(step,1)+15);             % else use something based on center stance to estimate. good estimates
            time2(time2>frames)=frames;
        end
        
        Red_Level2 = Red_Level;
        PawPrintCounter = 1;
        MaxPawPrintSize = 1;
        size_im = (hiy-loy)*(hix-lox);
        while (((MaxPawPrintSize/size_im) <= 0.020) || ((MaxPawPrintSize/size_im) >= 0.075)) && (PawPrintCounter <= 10)
            im_strike=video(loy:hiy,lox:hix,:,time);
            if TF_ShowAll == 1 || TF_HindPaw == 1 || TF_ShowBothFeet == 1
                figure(30); imshow(im_strike);
            end
            im2 = rgb2hsv(im_strike);
            
            
%             figure
%             imshow(im2);
%             
            
            
            %save('F:\im2.mat', 'im2');
                Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
            if CheckLines == 1
                LineChecker = min(min(im2(:,:,1)))*1.1;
                KDA_Lines = im2(:,:,1);
                count_check = 0;
                while LineChecker <= 0.02
                    KDA_sensitivity = .90*(max(max(KDA_Lines(:,:,1))));
                    KDA_Lines(KDA_Lines >= KDA_sensitivity) = 1;
                    KDA_Lines = imdilate(KDA_Lines,strel('square',2));
                    %figure(100); imshow(KDA_Lines(:,:,1));
                    KDA_Lines(KDA_Lines == 1) = median(median(im2(:,:,1)));
                    KRed_sensitivity = min(min(KDA_Lines(:,:,1))) + Red_Level2*(max(max(KDA_Lines(:,:,1))) - min(min(KDA_Lines(:,:,1))));
                    strike = KDA_Lines(:,:,1) < KRed_sensitivity;
                    %figure(101); imshow(strike);
                    LineChecker = min(min(KDA_Lines(:,:,1)))*1.1;
                    %input('Press Any Key To Continue');
                    count_check = count_check + 1;
                    if count_check == 20
                        LineChecker = 0.03;
                    end
                end
                if count_check == 0
                    Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                    strike = im2(:,:,1) < Red_sensitivity;
                end
            else
                Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                strike = im2(:,:,1) < Red_sensitivity;
            end
            if TF_ShowAll == 1 || TF_HindPaw == 1 || TF_ShowBothFeet == 1
                figure(31); imshow(strike);
            end
            
            
            
            
            
%             figure(31);imshow(strike); 
%             figure(32); ishow(im2)
%             
            clear im2;
            %input('Press Any Key to Continue');
            
            % im, "-image" zero is even higher than Yst, loy  and hiy both above Yst ("y start")
            %         stance=zeros(size(im,1),size(im,2));  % but the center of im is right at caproy
            %         stance( im(:,:,2)>im(:,:,3)*GBlo & im(:,:,1)>im(:,:,2)*RGlo & im(:,:,1)<im(:,:,2)*RGhi & im(:,:,2)<im(:,:,3)*GBhi & im(:,:,1)>minred )=1;
            im_stance = video(loy:hiy,lox:hix,:,time2);
            if TF_ShowAll == 1 || TF_HindPaw == 1 || TF_ShowBothFeet == 1
                figure(32); imshow(im_stance);
            end
            im2 = rgb2hsv(im_stance);
            %save('F:\im2.mat', 'im2');
            Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
            if CheckLines == 1
                LineChecker = min(min(im2(:,:,1)))*(1.1);
                KDA_Lines = im2(:,:,1);
                count_check = 0;
                while LineChecker <= 0.02
                    KDA_sensitivity = .90*(max(max(KDA_Lines(:,:,1))));
                    KDA_Lines(KDA_Lines >= KDA_sensitivity) = 1;
                    KDA_Lines = imdilate(KDA_Lines,strel('square',2));
                    %figure(100); imshow(KDA_Lines(:,:,1));
                    KDA_Lines(KDA_Lines == 1) = median(median(im2(:,:,1)));
                    KRed_sensitivity = min(min(KDA_Lines(:,:,1))) + Red_Level2*(max(max(KDA_Lines(:,:,1))) - min(min(KDA_Lines(:,:,1))));
                    stance = KDA_Lines(:,:,1) < KRed_sensitivity;
                    %figure(101); imshow(stance);
                    LineChecker = min(min(KDA_Lines(:,:,1)))*(1.1);
                    %input('Press Any Key To Continue');
                    count_check = count_check + 1;
                    if count_check == 20
                        LineChecker = 0.03;
                    end
                end
                if count_check == 0
                    Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                    stance = im2(:,:,1) < Red_sensitivity;
                end
            else
                Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                stance = im2(:,:,1) < Red_sensitivity;
            end
            if TF_ShowAll == 1 || TF_HindPaw == 1 || TF_ShowBothFeet == 1
                figure(33); imshow(stance);
            end
            
%             figure(22); imshow(stance);
            L1=strike+stance;
%             figure(23); imshow(L1);
            
            % HEK May 1 2014
            % A handful of videos were finding the paw perfectly, but the
            % max was only 1 so it was beeing zeroed out. Now there is a
            % more general case.
            if max(max(L1)) == 1
                L1(L1 < 1)=0;
                L1(L1 >= 1)=1;
            else
                L1(L1 < 2)=0;
                L1(L1 >= 2)=1;
            end
            
            
            if TF_ShowAll == 1 || TF_HindPaw == 1 || TF_ShowBothFeet == 1
                figure(34); imshow(L1);
            end
            %Originally this had no initial erode and was dilate 3, followed by
            %erode 3
            
            clear im im2;
            
            L1=imerode(L1,strel('square',1));
            L1=imdilate(L1,strel('square',1));
            
            if TF_ShowAll == 1 || TF_HindPaw == 1 || TF_ShowBothFeet == 1
                figure(35); imshow(L1);
                input('Press any key to continue')
            end
            
            
            
            
            
            
%             figure(35); imshow(L1);
            
            


            
            
            
            [L num]=bwlabel(L1);
            stats=regionprops(L,'area');
            allarea=[stats.Area]';
            clear ctrx ctry delt J Jay jay;
            ctrx=zeros(1,num); ctry=ctrx; delt=ctry;
            
            MaxPawPrintSize = max(allarea);
            if PawPrintCounter == 10
                MaxPawPrintSize = size_im;
            end
            if ((MaxPawPrintSize/size_im) <= 0.025)
                Red_Level2 = Red_Level2 + 0.01;
            elseif  ((MaxPawPrintSize/size_im) >= 0.075)
                Red_Level2 = Red_Level2 - 0.01;
            end
            PawPrintCounter = PawPrintCounter + 1;
        end
        clear Red_Level2;
        
        % at this point you have a small snap shot around the rat's center
        % that is two instances in time added together, the code will
        % look for the biggest object that is =2 and assume that the biggest
        % one is the paw you are trying to track on this iteration of the loop.
        % I used to have a fancy algorythim that looked for the obj closest to
        % the rat centriod, but it proves unreliable. ther are vestiges of this
        % algorythm below that are not necessary, but still function well
        
        if num>0 && max(allarea)>40 %was 40, and allowable XWIDE, YWIDE were >6,
            %changed to these values in early 2013 to caputre more paw prints
            %that were getting filtred out...but now they are back to "40"
            
            for j=1:num
                if allarea(j)>40
                    clear ctr stats Ltemp WIDE XWIDE
                    Ltemp=zeros(size(L));   Ltemp (L==j)=1;
                    stats=regionprops(Ltemp,'centroid','BoundingBox');
                    ctr=[stats.Centroid]';
                    %ctr is center of foot stk. bounding box has center at caproy(j) (centriod of rat).
                    WIDE=[stats.BoundingBox]';
                    XWIDE=(WIDE(3));YWIDE=WIDE(4);WIDEX(j)=0;
                    if XWIDE>4 && YWIDE>4
                        delt(j)=( ( size(L,2)/2 -ctr(1))^2 + (size(L,1)/2 -ctr(2))^2 )^.5;
                        if ctr(2)~=(size(L,1)/2)
                            delt(j)=delt(j)*(size(L,1)/2-ctr(2)) / abs(size(L,1)/2 - ctr(2 ));%above or below?
                        end
                        ctrx(j)=ctr(1)+lox;
                        ctry(j)=ctr(2)+loy;
                        WIDEX(j)=XWIDE;% will use this for averaging size of steps
                        allarea(j)=allarea(j)*10;
                        %the line immediately above is a weight given to any obj.
                        %that is at least 4 pix x 4 pix. This criteria is as
                        %equally important as simple area of obj,
                        %the inflated criterion will carry
                        %forward: ie: inflate area of object when the width
                        %criteria is met,  later code will find the thing with
                        %biggest area, call this the paw.
                    end
                end;J(j)=j;
            end
            
            Jay=J(allarea==max(allarea));%this algorythm created jan 6 2013.
            if numel(Jay)>1
                Jay=Jay(1) ;
            end%there's getting to be a  lot of "Jays"
            %partly this is a relic of the former fancy algorythim, at this point
            %it is probably redundant, but it runs very smoothly, so there is no
            %need to change it.
            
            WIDEx(step)=WIDEX(Jay);
            centerx(step)=ctrx(Jay);
            centery(step)=ctry(Jay);
            delta(step)=delt(Jay);
            D(step)=delta(step)/abs(delta(step));
            %display('centerx')
            if centerx(step)>0
                foot(step)=D(step)*sign(vel); %-1 for right, 1 for left
                %display('Foot Defined')
                
            end
            Lout(loy:hiy,lox:hix)= Lout(loy:hiy,lox:hix)+L1;
            % L1 is the full output figure, Lout is the small snapshot of just one step.
            
        end% if num >0 &max area>40
    end
end% end large for-if statement for foot locator.

if TF_ShowAll == 1 || TF_Tracker == 1
    input('Press Any Key To Continue')
    close(30); close(31); close(32); close(33); close(34); close(35);
end

WIDEx(WIDEx==0)=[];
WID=1.2*mean(WIDEx(:));% all the WIDE permutations help find average width of
% prints in x-dirreciton.
% WID helps determine if code picks up the same print for two distinct
% steps. This is line of code incidentally that tends to create false
% positives  for error: 200000

errcol=zeros(numel(foot),1);% this block heavily revamped on jan 16th.
for j=2:numel(foot)-1
    if foot(j-1)~=0 && foot(j+1)~=0 && centery(j)<centery(j-1)-1 && centery(j)<centery(j+1)-1 &&centery(j)~=0
        foot(j)=sign(vel);
    end
    if foot(j-1)~=0 && foot(j+1)~=0 && (centery(j)>centery(j-1)+1 && centery(j)>centery(j+1)+1) && centery(j)~=0
        foot(j)=sign(vel)*(-1);
    end
    if foot(j-1)~=0 && foot(j+1)~=0 &&foot(j-1)==foot(j+1)
        foot(j)=foot(j-1)*(-1);
    end
    % if consistent either side of j, in case centery(j)==0.
    
end
% patched jan 20th: if foot(1)==0 it is ok to infer side of step.
% if foot(1)==1 or -1, will generate the error 600000 as desired.
if numel(foot)>3
    if foot(3)~=0 && centery(1)==0 && foot(1)==0;
        foot(1)=foot(3);end;
    if foot(end-2)~=0 && centery(end)==0 && foot(end)==0;
        foot(end)=foot(end-2);end
    % end revamp jan 20th. seems to be working.
    for j=3:numel(foot)
        if (abs(centerx(j)-centerx(j-1))<WID || abs( centerx(j)-centerx(j-2))<WID) && centery(j)~=0 && (abs(centery(j)-centery(j-1))<WID || abs( centery(j)-centery(j-2))<WID)
            errcol(j)=200000;% error msg for hitting same physical print two times for distinct toeoffs.
        end;                    % i have noticed a lot of false positives with this checker. not sure how to fix it.
    end;                    % it's not a pythagorean, but it ought to look for both X and Y distance, only if both are too close will error trigger.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end paw tracker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hindsup=hpaws(:,6:7);  % extract suplemental data for hind paws; stk mode & erosions
hpaws(:,6)=[];         % truncate for later concatenations.
% there will be several columns before suplements.
hpaws(:,6)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stride data generation:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(foot)>3
    for j=3:numel(centery)
        if foot(j)==1 && foot(j-2)==1 && foot(j-1)==-1
            sym(j)=( hpaws(j-1,4)-hpaws(j-2,4)) / (hpaws(j,4)-hpaws(j-2,4));
        end
        if foot(j)==foot(j-2) && foot(j)~=0 &&  hpaws(j-2,5)>0
            duty(j)=( hpaws(j-2,5)-hpaws(j-2,4)) / (hpaws(j,4)-hpaws(j-2,4));
        end
        if foot(j)==foot(j-2)&& centerx(j)>0&& centery(j)>0&& centerx(j-2)>0&& centery(j-2)>0 && foot(j)~=0
            stdlth(j)=( ((centerx(j)-centerx(j-2))^2)+((centery(j)-centery(j-2))^2) )^.5;
        end
        
        if foot(j)==foot(j-2)&& centerx(j)>0&& centery(j)>0&& centerx(j-2)>0&& centery(j-2)>0 &&foot(j-1)==foot(j)*-1 && centerx(j-1)>0&& centery(j-1)>0 && foot(j)~=0
            B=( ((centerx(j)-centerx(j-2))^2) +((centery(j)-centery(j-2))^2)      )^.5;
            C=( ((centerx(j-1)-centerx(j-2))^2) +((centery(j-1)-centery(j-2))^2)  )^.5;
            A=( ((centerx(j)-centerx(j-1))^2) +((centery(j)-centery(j-1))^2)      )^.5;
            S=(A+B+C)/2;
            stdwd(j)= 2 * ( (S*(S-A)*(S-B)*(S-C) )^.5 )/B;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% final concatenations for stride data to the matrix: hpaws
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hpaws=cat(2,hpaws,foot',sym',duty',stdlth',stdwd',hindsup);
hpaws(:,13)=errcol;
hpaws(:,14)=errcol2'-dmean;
avgarr=(hpaws(:,9));
avgarr(avgarr==0)=[];
avg=mean2(avgarr);
for j=1:numel(centery)
    hpaws(j,2)=centerx(j);
    hpaws(j,3)=centery(j);
    if hpaws(j,12)>ceil(mean(hpaws(:,12)))+1; hpaws(j,13)=40044;    end;%error code for suspicious number of erosion?
    if hpaws(j,11)<5; hpaws(j,13)= hpaws(j,13)+50055 ;              end;%error code for low mode freq for strike ?
    if hpaws(j,2)~=0&& ((j<numel(centery) && hpaws(j,6)==hpaws(j+1,6)) ||(j>1 && hpaws(j,6)==hpaws(j-1,6)));
        %repeated step sides? will alert to both steps, but will also NOT calculate parameters for any of these steps.
        hpaws(j,13)= hpaws(j,13)+600000;
    end
    if hpaws(j,2)==0 %cannot identify paw print.
        hpaws(j,13)= hpaws(j,13)+02200;
    end
    if hpaws(j,6)==0 %cannot identify side of stk.
        hpaws(j,13)= hpaws(j,13)+01100;
    end
    if errcol2(j)-dmean <0
        hpaws(j,14)=0;% num >0 will indicate exessive distance:taildrag?
    end                % value in hpaws(:,14) is difference from expectation
    % note that this error msg is supersceded if you
    % are using 'CAPITAL' letter arguments in your
    % function call.
    if (( hpaws(j,9)-avg)/ avg)  >.25
        hpaws(j,13)= hpaws(j,13)+100000;
        if j>2; jj=j-2;hpaws(jj,13)= hpaws(jj,13)+100000;end
        %hpaws(j,9)= 0;      % if longer than expected stride, this may be tail drag, not a paw print.
        %hpaws(j,10)= 0;     % may indicate eroneous print.
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clone of above block, fore paw tracker is below. It has a few additional
%lines that can assume the side of a fore strike if no fore print found, but a
%nearby hind was found.  This is the "backup forepaw tracker."
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

steps=size(fpaws,1);clear foot delta D sym A B C S duty stdwd stdlth
foot=zeros(1,numel([1:steps]));sym=foot;duty=foot;stdlth=foot;stdwd=foot;
centerX=foot; centerY=foot; D=foot; delta=foot;

display('Detecting Fore Paws');
for step=1:steps
    clear im strike stance L time lox hix loy hiy allarea ctr stats statsctr;
    time=round(fpaws(step,5));  %find centroid by toeoff.
    
    if time>1&& time<frames && fpaws(step,5)>0
        
        time=round(.8*fpaws(step,1)+.2*fpaws(step,5));% toe off is col (5).
        
        
        % HEK
        % taking velocity into accound when searching for the paw.
        
        meanvel = velocity;
        if meanvel>1.5
            meanvel = 1.5;
        elseif meanvel<.75
            meanvel = .75;
        else
            meanvel = .75*meanvel;
        end

        
        if vel>0
            lox=round((caprox(time)+.05*meanvel*ratwide(time)/1)); %1.5's were 1.8s - KDA Switch
            hix=round(caprox(time)+.85*meanvel*ratwide(time)/1);
        elseif vel<0
            lox=round(caprox(time)-.85*meanvel*ratwide(time)/1); %1.5's were 1.8s - KDA Switch
            hix=round(caprox(time)-.05*meanvel*ratwide(time)/1);
        end
        
        
        
        loy= round(Yst + (caproy(time)-ratwide(time)/1.5)); %zero caproy- "center aprox y"- is at Yst (Ystart)
        hiy= round(Yst + (caproy(time)+ratwide(time)/1.5)); %use caproy- "center aprox y"- as sometimes "ceny" is not resolved.
        
        lox(lox<1)=1;      hix(hix>XMAX)=XMAX;
        loy(loy<1)=1;      hiy(hiy>ZMAX)=ZMAX;
        
        loy = loy+10;
        hiy = hiy-10;
        
           
        
%         lox=round((caprox(time)-ratwide(time)/1.5)); % was 2.2 -- KDA02/06/14
%         hix=round((caprox(time)+ratwide(time)/1.5)); % was 1.8 -- KDA02/06/14
%         loy= round(Yst + (caproy(time)-ratwide(time)/1.5)); % was 1.8 -- KDA02/06/14
%         hiy= round(Yst + (caproy(time)+ratwide(time)/1.5)); % was 1.8 -- KDA02/06/14
%         
%         loy= round(Yst + (caproy(time)-ratwide(time)/1.5)); %zero caproy- "center aprox y"- is at Yst (Ystart)
%         hiy= round(Yst + (caproy(time)+ratwide(time)/1.5)); %use caproy- "center aprox y"- as sometimes "ceny" is not resolved.
%                 
%         lox(lox<1)=1;      hix(hix>XMAX)=XMAX;
%         loy(loy<1)=1;      hiy(hiy>ZMAX)=ZMAX;
%         time=round(.8*fpaws(step,1)+.2*fpaws(step,5));% toe off is col (5).
%         
% %         % Distortion fix by KDA 2/6/14
% %         if lox < round(XMAX*0.25)
% %             lox = lox + distorted;
% %             if lox < 1
% %                 lox = 1;
% %             end
% %             hix = hix + distorted;
% %         elseif lox > round(XMAX*0.75)
% %             lox = lox - distorted;
% %             hix = hix - distorted;
% %             if hix > XMAX
% %                 hix = XMAX;
% %             end
% %         end
% %         
% %         lox(lox<1)=1;      hix(hix>XMAX)=XMAX;
% %         loy(loy<1)=1;      hiy(hiy>ZMAX)=ZMAX;
% %         
% %         lox(lox>XMAX) = XMAX-10;
% %         hix(hix<0) = 10;
% %         
% %         if lox >= XMAX
% %             lox = lox-distorted
% %         end
% %         
% %         if lox >= hix
% %             display('Error in step image detection, coordinates out of bounds')
% %         end
% %         
        
            
%         figure
%         imshow(video(:,:,:,time));
%         figure
%         imshow(video(loy:hiy,lox:hix,:,time));
        
        
        
        %     im=video(loy:hiy,lox:hix,:,time);
        %     strike=zeros(size(im,1),size(im,2));
        %     strike( im(:,:,2)>im(:,:,3)*GBlo & im(:,:,1)>im(:,:,2)*RGlo & im(:,:,1)<im(:,:,2)*RGhi & im(:,:,2)<im(:,:,3)*GBhi & im(:,:,1)>minred )=1;
        
        Red_Level2 = Red_Level;
        PawPrintCounter = 1;
        MaxPawPrintSize = 0;
        size_im = (hiy-loy)*(hix-lox);
        while (((MaxPawPrintSize/size_im) <= 0.010) || ((MaxPawPrintSize/size_im) >= 0.05)) && PawPrintCounter <= 10
            
            im_strike=video(loy:hiy,lox:hix,:,time);
            if TF_ShowAll == 1 || TF_ForePaw == 1 || TF_ShowBothFeet == 1
                figure(40); imshow(im_strike);
            end
            im2 = rgb2hsv(im_strike);
            Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
            if CheckLines == 1
                LineChecker = min(min(im2(:,:,1)))*1.1;
                KDA_Lines = im2(:,:,1);
                count_check = 0;
                while LineChecker <= 0.02
                    KDA_sensitivity = .90*(max(max(KDA_Lines(:,:,1))));
                    KDA_Lines(KDA_Lines >= KDA_sensitivity) = 1;
                    KDA_Lines = imdilate(KDA_Lines,strel('square',2));
                    %figure(100); imshow(KDA_Lines(:,:,1));
                    KDA_Lines(KDA_Lines == 1) = median(median(im2(:,:,1)));
                    KRed_sensitivity = min(min(KDA_Lines(:,:,1))) + Red_Level2*(max(max(KDA_Lines(:,:,1))) - min(min(KDA_Lines(:,:,1))));
                    strike = KDA_Lines(:,:,1) < KRed_sensitivity;
                    %figure(101); imshow(strike);
                    LineChecker = min(min(KDA_Lines(:,:,1)))*1.1;
                    %input('Press Any Key To Continue');
                    count_check = count_check + 1;
                    if count_check == 20
                        LineChecker = 0.03;
                    end
                end
                if count_check == 0
                    Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                    strike = im2(:,:,1) < Red_sensitivity;
                end
            else
                Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                strike = im2(:,:,1) < Red_sensitivity;
            end
            if TF_ShowAll == 1 || TF_ForePaw == 1 || TF_ShowBothFeet == 1
                figure(41); imshow(strike);
            end
            clear im_strike id;
            
            time2=round(.2*fpaws(step,1)+.8*fpaws(step,4));% toe on is (4)
            %     im=video(loy:hiy,lox:hix,:,time2);
            %     stance=zeros(size(im,1),size(im,2));
            %     stance( im(:,:,2)>im(:,:,3)*GBlo & im(:,:,1)>im(:,:,2)*RGlo & im(:,:,1)<im(:,:,2)*RGhi & im(:,:,2)<im(:,:,3)*GBhi & im(:,:,1)>minred )=1;
            
            im_stance=video(loy:hiy,lox:hix,:,time2);
            if TF_ShowAll == 1 || TF_ForePaw == 1 || TF_ShowBothFeet == 1
                figure(42); imshow(im_stance);
            end
            im2 = rgb2hsv(im_stance);
            Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
            if CheckLines == 1
                LineChecker = min(min(im2(:,:,1)))*(1.1);
                KDA_Lines = im2(:,:,1);
                count_check = 0;
                while LineChecker <= 0.02
                    KDA_sensitivity = .90*(max(max(KDA_Lines(:,:,1))));
                    KDA_Lines(KDA_Lines >= KDA_sensitivity) = 1;
                    KDA_Lines = imdilate(KDA_Lines,strel('square',2));
                    %figure(100); imshow(KDA_Lines(:,:,1));
                    KDA_Lines(KDA_Lines == 1) = median(median(im2(:,:,1)));
                    KRed_sensitivity = min(min(KDA_Lines(:,:,1))) + Red_Level2*(max(max(KDA_Lines(:,:,1))) - min(min(KDA_Lines(:,:,1))));
                    stance = KDA_Lines(:,:,1) < KRed_sensitivity;
                    %figure(101); imshow(stance);
                    LineChecker = min(min(KDA_Lines(:,:,1)))*(1.1);
                    %input('Press Any Key To Continue');
                    count_check = count_check + 1;
                    if count_check == 20
                        LineChecker = 0.03;
                    end
                end
                if count_check == 0
                    Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                    stance = im2(:,:,1) < Red_sensitivity;
                end
            else
                Red_sensitivity = min(min(im2(:,:,1))) + Red_Level2*( max(max(im2(:,:,1))) - min(min(im2(:,:,1))));
                stance = im2(:,:,1) < Red_sensitivity;
            end
            if TF_ShowAll == 1 || TF_ForePaw == 1 || TF_ShowBothFeet == 1
                figure(43); imshow(stance);
            end
            L1=strike+stance;
            
            
% % % %                         % HEK May 1 2014
% % % %             % A handful of videos were finding the paw perfectly, but the
% % % %             % max was only 1 so it was beeing zeroed out. Now there is a
% % % %             % more general case.
% % % %             if max(max(L1)) == 1
% % % %                 L1(L1 < 1)=0;
% % % %                 L1(L1 >= 1)=1;
% % % %             else
% % % %                 L1(L1 < 2)=0;
% % % %                 L1(L1 >= 2)=1;
% % % %             end
            
%             figure
%             imshow(L1)
            
            
            if TF_ShowAll == 1 || TF_ForePaw == 1 || TF_ShowBothFeet == 1
                figure(44); imshow(L1)
            end
            clear im_stance id;
            
            %Uncomment to error check on footprint imagae
            %figure(99); imshow(L1);
            
            L1(L1 < 2)=0; L1(L1 >= 2)=1;
            L1=imerode(L1,strel('square',2));
            L1=imdilate(L1,strel('square',2));
            if TF_ShowAll == 1 || TF_ForePaw == 1 || TF_ShowBothFeet == 1
                figure(45); imshow(L1);
                input('Press any key to continue');
            end
            %     L1=imerode(L1,strel('square',3));
            
            [L num]=bwlabel(L1);
            %Uncomment to error check on footprint imagae
            %figure(100); imshow(L1);
            %DrAllenWasHere = input('Press any key to continue');
            stats=regionprops(L,'area');
            allarea=[stats.Area]';
            %     if mean([stats.Area]) < 40
            %         display('Check RGB Settings - Paw Area is too small to detect foot-print pattern');
            %     end
            clear ctrx ctry delt J Jay jay;
            
            if isempty(allarea) == 1
                MaxPawPrintSize = 0;
            else
                MaxPawPrintSize = max(allarea);
                if PawPrintCounter == 11
                    MaxPawPrintSize = size_im;
                end
            end
            if ((MaxPawPrintSize/size_im) <= 0.015)
                Red_Level2 = Red_Level2 + 0.01;
            elseif  ((MaxPawPrintSize/size_im) >= 0.05)
                Red_Level2 = Red_Level2 - 0.01;
            end
            PawPrintCounter = PawPrintCounter + 1;
        end
        
        ctrx=zeros(1,num); ctry=ctrx; delt=ctry;
        
        if num>0 && max(allarea)>20
            J=0;
            for j=1:num
                if allarea(j)>20
                    clear ctr stats Ltemp WIDE XWIDE
                    Ltemp=zeros(size(L));   Ltemp (L==j)=1;
                    stats=regionprops(Ltemp,'centroid','BoundingBox');
                    ctr=[stats.Centroid]';
                    WIDE=[stats.BoundingBox]';
                    XWIDE=(WIDE(3));YWIDE=WIDE(4);WIDEX(j)=0;
                    if XWIDE>4 && YWIDE>4
                        delt(j)=( ( size(L,2)/2 -ctr(1))^2 + (size(L,1)/2 -ctr(2))^2 )^.5;
                        if ctr(2)~=(size(L,1)/2)
                            delt(j)=delt(j)*(size(L,1)/2-ctr(2)) / abs(size(L,1)/2 - ctr(2 ));%above or below?
                        end
                        ctrx(j)=ctr(1)+lox;
                        ctry(j)=ctr(2)+loy;
                        WIDEX(j)=XWIDE;% will use this for averaging size of steps, looking for repeated hits on prints
                        allarea(j)=allarea(j)*10;
                        % again, inflate the area if width criteria are met. see above clone
                        % for hind paws for a  more complete anotation.
                    end;J(j)=j;
                end;
            end
            
            Jay=J(allarea==max(allarea));
            %this algorythm replaces the one which was based on proximity to centoiroid,  jan 6 2013.
            if numel(Jay)>1 && vel<0;  Jay=Jay(1);
            end
            if numel(Jay)>1 && vel>0;  Jay=Jay(end);
            end
            % NOTE JAN. 14: sometimes the hind paw is bigger than fore paw.
            % this IF above may solve issue
            WIDEx(step)=WIDEX(Jay);
            centerX(step)=ctrx(Jay);
            centerY(step)=ctry(Jay);
            delta(step)=delt(Jay);
            D(step)=delta(step)/abs(delta(step));
            if centerX(step)>0
                foot(step)=D(step)*vel; %-1 for right, 1 for left
            end
            Lout(loy-100:hiy-100,lox:hix)= Lout(loy-100:hiy-100,lox:hix) +L1;
            Lout(Lout>1)=1;
            
        end% end for "if num >0&& max( allarea>20)"
    end;
end% end large if-for statement for foot locator.

if TF_ShowAll == 1 || TF_Tracker == 1
    input('Press Any Key To Continue')
    close(40); close(41); close(42); close(43); close(44); close(45);
end

%% Calculating Data Set

display('Calculating Final Data Set');

WIDEx(WIDEx==0)=[];
WID=1.2*mean(WIDEx(:));

% this block heavily revamped on jan 16th. and is unique, mostly, to the
% fore paw tracker, vs. the hind paw tracker.
% Determining side of stk only works relative to centriod about 60 % of the
% time for fore paws.
% therefore, below, IN ORDER is a way to narrow down where the step was.
errcol=zeros(numel(foot),1);
for j=2:numel(foot)-1
    if foot(j-1)~=0 && foot(j+1)~=0 && centerY(j)<centerY(j-1)-1 && centerY(j)<centerY(j+1)-1 &&centerY(j)~=0
        foot(j)=vel;
    end
    if foot(j-1)~=0 && foot(j+1)~=0 && (centerY(j)>centerY(j-1)+1 && centerY(j)>centerY(j+1)+1) && centerY(j)~=0
        foot(j)=vel*(-1);
    end
    % to capture SIDE only if no fore print found, but surrounding prints found:
    if foot(j-1)~=0 && foot(j+1)~=0 &&foot(j-1)==foot(j+1)
        foot(j)=foot(j-1)*(-1);
    end
    if foot(j)==0 % if side STILL zero, use close-in-space hind paw to find side
        for k=1:numel(Xwide)%xwide of hind paws
            if abs(hpaws(k,2)-fpaws(j,2))< (Xwide(k)/1.33) % compare cx of fore/hind w/in range:wide/1.33;
                foot(j)=hpaws(k,6);% side fore = side hind in this case.
            end
        end
    end
end
%%% it should be OK to infer the side if no print found. IE foot(1)==0.

if numel( foot)>3
    if foot(3)~=0 && centerY(1)==0 && foot(1)==0;
        foot(1)=foot(3);end;
    if foot(end-2)~=0 && centerY(end)==0 && foot(end)==0;
        foot(end)=foot(end-2);end
    
    for j=3:numel(foot)
        if centerX(j)~=0 && ( abs(centerX(j)-centerX(j-1))<WID || abs( centerX(j)-centerX(j-2))<WID )&& ( abs(centerY(j)-centerY(j-1))<WID || abs( centerY(j)-centerY(j-2))<WID )
            errcol(j)=200000;% error msg for hitting same physical print two times for distinct toeoffs.
        end
    end
end


foresup=fpaws(:,6:7);% suplemental data for fore paws.
forecomp=fpaws(:,8); % approximation error for toeoff/ strike. will be col 10 in new mtx.
fpaws(:,6)=[];fpaws(:,6)=[];fpaws(:,6)=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stride data generation:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(foot)>3
    for j=3:numel(centerY)
        if foot(j)==1 && foot(j-2)==1 && foot(j-1)==-1
            sym(j)=( fpaws(j-1,4)-fpaws(j-2,4)) / (fpaws(j,4)-fpaws(j-2,4));
        end
        if foot(j)==foot(j-2) && foot(j)~=0 &&  fpaws(j-2,5)>0
            duty(j)=( fpaws(j-2,5)-fpaws(j-2,4)) / (fpaws(j,4)-fpaws(j-2,4));
        end
        if foot(j)==foot(j-2)&& centerX(j)>0&& centerY(j)>0&& centerX(j-2)>0&& centerY(j-2)>0 &&foot(j)~=0
            stdlth(j)=( ((centerX(j)-centerX(j-2))^2) +((centerY(j)-centerY(j-2))^2) )^.5;
        end
        
        if foot(j)==foot(j-2)&& centerX(j)>0&& centerY(j)>0&& centerX(j-2)>0&& centerY(j-2)>0 &&foot(j-1)==foot(j)*-1 && centerX(j-1)>0&& centerY(j-1)>0 &&foot(j)~=0
            B=( ((centerX(j)-centerX(j-2))^2) +((centerY(j)-centerY(j-2))^2)      )^.5;
            C=( ((centerX(j-1)-centerX(j-2))^2) +((centerY(j-1)-centerY(j-2))^2)  )^.5;
            A=( ((centerX(j)-centerX(j-1))^2) +((centerY(j)-centerY(j-1))^2)      )^.5;
            S=(A+B+C)/2;
            stdwd(j)=2 * ( (S*(S-A)*(S-B)*(S-C) )^.5 )/B;
        end
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% final error generation and concatenations for the fore paws
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save('E:\fpaws1.csv', 'fpaws', '-ASCII')
fpaws=cat(2,fpaws,foot',sym',duty',stdlth',stdwd',foresup);
%save('E:\fpaws2.csv', 'fpaws', '-ASCII')
fpaws(:,13)=errcol;
for j=1:numel(centerY)
    fpaws(j,2)=centerX(j);
    fpaws(j,3)=centerY(j);
    if fpaws(j,12)>ceil(mean(fpaws(:,12)))+1; fpaws(j,13)=40044;end;%lots of erosion?
    if fpaws(j,11)<5; fpaws(j,13)= fpaws(j,13)+50055 ;          end;%low freq of strike mode?
    if fpaws(j,2)~=0&& ((j<numel(centerY) && fpaws(j,6)==fpaws(j+1,6)) ||(j>1 && fpaws(j,6)==fpaws(j-1,6)));
        %repeated step sides?
        fpaws(j,13)= fpaws(j,13)+600000;
    end
    if fpaws(j,2)==0 %cannot identify paw print.
        fpaws(j,13)= fpaws(j,13)+02200;
    end
    if fpaws(j,6)==0 %cannot identify paw print.
        fpaws(j,13)= fpaws(j,13)+01100;
    end
    if (( fpaws(j,9)-avg)/ avg)  >.25
        fpaws(j,13)= fpaws(j,13)+100000;
        if j>2; jj=j-2;fpaws(jj,13)= fpaws(jj,13)+100000;    end
        %fpaws(j,9)= 0;      % if longer than expected stride,
        %fpaws(j,10)= 0;     % may indicate eroneous print.
    end
end
fpaws(:,14)=forecomp(:,1);

%%%%%%%%%%%%  set blank to -.01, round decimal places. %%%%%%%%%%%%%%%%%%%%
fpaws=round(fpaws*1000)/1000;
fpaws(fpaws==0)=-.1;
hpaws=round(hpaws*1000)/1000;
hpaws(hpaws==0)=-.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% aslo concatenate hind and fore, will need to create a fourth data sheet
% this block also finds the gait parameter " limb phase"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allpaws2=hpaws;
allpaws2(:,1)=allpaws2(:,4);%place strike in first position.
allpaws2(:,4)=2;            %2 will signify hind paws
%save('E:\allpaws2.csv', 'allpaws2', '-ASCII')

allpaws4=fpaws;
allpaws4(:,1)=allpaws4(:,4);%place strike in first position.
allpaws4(:,4)=4;            %4 will signify fore paws. haha.
%save('E:\allpaws4.csv', 'allpaws4', '-ASCII')

allpaws=vertcat(allpaws4,allpaws2);
allpaws=sortrows(allpaws);
colvector=allpaws(:,4);
allpaws(:,4)=allpaws(:,1);%put strike back where it was before
allpaws(:,1)=colvector;   %put 2 or 4  in first position.
%save('E:\allpaws.csv', 'allpaws', '-ASCII')

Jright=1;
Jleft=1;

%create some matricies that will be used to find the limb phase:" all right", and "all left"
for j=1:size(allpaws,1)
    if allpaws(j,6)==-1
        rightpaws(Jright,:)=allpaws(j,:);
        Jright=Jright+1;
        %display('Defining rightpaws')
    end
    if allpaws(j,6)==1
        leftpaws(Jleft,:)=allpaws(j,:);
        Jleft=Jleft+1;
        %display('Defining leftpaws')
    end
end

%find the parameter: limb phase, for left feet in below loop:
counthind=0;    %count up every time a  hind foot is found.
countfore=0;
limbphase=-.1*ones(size(leftpaws,1),1);
prevhind=0;          %  this variable will always be assigned the most recent hind srtike
prevfore=0;           % this variable will always be assigned the most recent fore srtike
for j=1:size(leftpaws,1)
    % Old incorrect way
%     if counthind>0 && countfore>0 && leftpaws(j,1)==2
%         %"if there is one previous hind , one prev. fore, and current step is hind"...
%         limbphase(j)=(leftpaws(j,4)-prevfore)/(leftpaws(j,4)-prevhind);
%         %strike of hind2 - strike of fore 1)/ (strik of hind 2- strike of hind 1)
%     end
%     if leftpaws(j,1)==2
%         counthind=counthind+1  ;         % count previous hind strikes
%         prevhind=leftpaws(j,4) ;         % 4th column is time of strike
%     end
%     if leftpaws(j,1)==4
%         countfore=countfore+1    ;      % count previous fore strikes.
%         prevfore=leftpaws(j,4)   ;      % 4th column is time of strike
%     end
    
    
    % HEK May 10, 2016 - New Limb Phase Calcs
    if counthind>0 && countfore>0 && leftpaws(j,1)==4 && j<size(leftpaws,1)
        limbphase(j)=(leftpaws(j,4)-leftpaws(j-1,4))/(leftpaws(j+1,4)-leftpaws(j-1,4));
    end
    if leftpaws(j,1)==2
        counthind=counthind+1  ;         % count previous hind strikes
        prevhind=leftpaws(j,4) ;         % 4th column is time of strike
    end
    if leftpaws(j,1)==4
        countfore=countfore+1    ;      % count previous fore strikes.
        prevfore=leftpaws(j,4)   ;      % 4th column is time of strike
    end
    
end
limbphase=round(limbphase*100)/100;
leftpaws(:,7)=limbphase(:);

%find the parameter: limb phase, for RIGHT feet in below loop:
counthind=0;    %count up every time a  hind foot is found.
countfore=0;
limbphase=-.1*ones(size(rightpaws,1),1);
prevhind=0;          %  this variable will always be assigned the most recent hind srtike
prevfore=0;           % this variable will always be assigned the most recent fore srtike
for j=1:size(rightpaws,1)
%     if counthind>0 && countfore>0 && rightpaws(j,1)==2
%         %"if there is one previous hind , one prev. fore, and current step is hind"...
%         limbphase(j)=(rightpaws(j,4)-prevfore)/(rightpaws(j,4)-prevhind);
%         %strike of hind2 - strike of fore 1)/ (strik of hind 2- strike of hind 1)
%     end
    
%HEK Patch May 10, 2016
    if counthind>0 && countfore>0 && rightpaws(j,1)==4 && j<size(rightpaws,1)
        limbphase(j)=(rightpaws(j,4)-rightpaws(j-1,4))/(rightpaws(j+1,4)-rightpaws(j-1,4));
    end
    if rightpaws(j,1)==2
        counthind=counthind+1;            % count previous hind strikes
        prevhind=rightpaws(j,4);          % 4th column is time of strike
    end
    if rightpaws(j,1)==4
        countfore=countfore+1;           % count previous fore strikes.
        prevfore=rightpaws(j,4);         % 4th column is time of strike
    end
    
end
limbphase=round(limbphase*100)/100;
rightpaws(:,7)=limbphase(:);



allpaws=vertcat(rightpaws, leftpaws);allpaws(:,8)=[];%truncate out other parameters that appear in other arrays.
allpaws(:,8)=[];
allpaws(:,8)=[];

zeroclearall= -.1 * ones(40,11);% call this before writing to spreadsheet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output images to the avi's directory, the .xls fiels to FSTO's native folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%desktop = 'C:\Users\Brittany Jacobs\Desktop\FSTOtest\'
%trialname=strcat(desktop,outputname,'_FSTO','.xls');
trialname=strcat(TrialIDName,'_FSTO','.xls');
% trialname(trialname=='\')='_'; %%this line commented to redirect the
% xlsx files to the directories where movies are located, instead of
% writing them to FSTO's dirrectory.

%"trialname" is a string for the xls file name that is the individual data log
%for this AVI file,
labf={'T centriod in XT plane','X centriod in XY plane','Y centriod in XY plane','Foot strike','Toeoff','Right=-1, Left=1','Symmetry','Duty factor','Stride length','Step width','Strike mode per XTplane perim.','Erosions to find step','Error message','Strike/toeoff error'};
labh={'T centriod in XT plane','X centriod in XY plane','Y centriod in XY plane','Foot strike','Toeoff','Right=-1, Left=1','Symmetry','Duty factor','Stride length','Step width','Strike mode per XTplane perim.','Erosions to find step','Error message','Later than expected?'};
labv={'Time','Nose x ','Nose Y ','Nose delta X','Center X','Center Y','Cumulative position vector','Approximate center in x','Approximate center in y'};
labA={'Hind/ Fore','X centriod in XY plane','Y centriod in XY plane','FootStrike','Toeoff','Right=-1, Left=1','Limb Phase','Strike mode per XTplane perim.','Erosions to find step','Error msg 1','Error msg 2'};

xlswrite(trialname,{'Frame','Pixels from right','Pixels from top','Frame','Frame','Neither: can`t find','Percentage','Percentage','Pixels','Pixels','Ideally >= 5','Processing req`d','','Frames late by...'},'hindpaws','A2');
xlswrite(trialname,{'Frame','Pixels from right','Pixels from top','frame','Frame','Neither: can`t find','Percentage','Percentage','Pixels','Pixels','Ideally >= 5','Processing req`d'},'forepaws','A2');
xlswrite(trialname,{'Frame','Pixels','Pixels','Pixels','Pixels','Pixels','Pixels','Pixels','pixels','-','Pixels per frame'},'position data','A2');
xlswrite(trialname,{'2=hind,4=fore','Pixels from right','Pixels from top','Frame','Frame','Right paws presented first','Percentage','Ideally >= 5','Pprocessing req`d'},'allpaws','A2');

% add in screen chop at "y start" variable name: Yst %%%%%%%%%%%%%%%%%%%%%%
% calculatoins above do not chance
% because I am adding in a constant here for the sake of the XLS files
CENT=mtxvel(:,9)+Yst;%Yst is the first row considered for the bottom image.
CENT(CENT==Yst)=0;   %"Ystart"
mtxvel(:,9)=CENT;

CENT=mtxvel(:,6)+Yst;
CENT(CENT==Yst)=0;
mtxvel(:,6)=CENT;
%done adding in chop, this will appear on the sheet: "position data"

xlswrite(trialname,labh,'hindpaws','A1');
zeroclear=-.1*ones( 19,14 );
xlswrite(trialname,zeroclear,'hindpaws','A3');%this line to clear artifacts to -.1 when run twice
xlswrite(trialname,hpaws,'hindpaws','A3');
xlswrite(trialname,labf,'forepaws','A1');
xlswrite(trialname,zeroclear,'forepaws','A3');%clear artifacts if run twice.
xlswrite(trialname,fpaws,'forepaws','A3');
xlswrite(trialname,labA,'allpaws','A1');
xlswrite(trialname,zeroclearall,'allpaws','A3');%clear artifacts if run twice.
xlswrite(trialname,allpaws,'allpaws','A3');


xlswrite(trialname,labv,'position data','A1');
xlswrite(trialname,mtxvel,'position data','A3');
xlswrite(trialname,velocity,'position data','K3');
xlswrite(trialname,R,'position data','L3');
xlswrite(trialname,int,'position data','N3');
xlswrite(trialname,velerr,'position data','K4');%vel err is a string discussing goodness of velocity fit.
xlswrite(trialname,RMSE,'position data','M3');
xlswrite(trialname,{'average velocity','Rsquare','RMSE','intercept'},'position data','K1');

xlswrite(trialname,{'Errors :';'40044,';'50055,';'90099,';'>600000,';'20202,';'1010,';'21212,';'2200,';'1100,';'3300,';'52255,';'690099,';'>100000';'>200000'},'forepaws','A27');
xlswrite(trialname,{'May demand excessive erosions';'Difficulty finding strike';'40044 & 50055';'Repeated right-right or left-left strikes';'Approximated toeoff';'Approximated strike';'1010 & 20202';'No pawprint found';'Undetermined paw (R/L)';'1100 & 2200';'50055& 2200';'40044& 50055& 600000';'Stride longer than expected';'Same paw print may count twice'},'forepaws','B28');

xlswrite(trialname,{'Errors :';'40044,';'50055,';'90099,';'>600000,';'20202,';'1010,';'21212,';'2200,';'1100,';'3300,';'52255,';'690099,';'>100000';'>200000'},'hindpaws','A27');
xlswrite(trialname,{'May demand excessive erosions';'Difficulty finding strike';'40044 & 50055';'Repeated right-right or left-left strikes';'Approximated toeoff';'Approximated strike';'1010 & 20202';'No pawprint found';'Undetermined paw (R/L)';'1100 & 2200';'50055& 2200';'40044& 50055& 600000';'Stride longer than expected';'Same paw print may count twice'},'hindpaws','B28');
xlswrite(trialname,{'COLUMN N greater than zero: this may indicate tail drag as it takes place much later than expected. Col N is delta-time (frames) from expectation'},'hindpaws','A42');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this block generates case logic in the master file.
% you should still review the TIFF files after each run.
% there is a new block here that creates a new parameter: stride
% frequency. This will exist on the case logic line, but not the data logs.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

foot=hpaws(:,6);   %rightor left?
sym=hpaws(:,7);    %symetry
dfa=hpaws(:,8);    %duty factor all
SL=hpaws(:,9);     %stride lth
SW=hpaws(:,10);    %stepwidth
lpl=leftpaws(:,7); %limbphase left
lpr=rightpaws(:,7);%limbphase right

errcheck=hpaws(:,13);
errcheck(errcheck>=100000)=1;
numerr=sum(errcheck(errcheck==1));
% count err col for repeated prints, repeated side of strike, and longer than
% expected strides. Ignores other errors.

if R<.99; numerr=numerr+.667; end;
%questionable velocity will be +2/3 an error to easily see in Master file

sym(sym<=0)=[];  %make variables empty if no measuremnt.
SL(SL<=0)=[];
SW(SW<=0)=[];
lpr(lpr<=0)=[];
lpl(lpl<=0)=[];

dfr=dfa;
dfl=dfa;
dfl(foot==-1)=0; % if foot = rt, duty factor left =0
dfr(foot==1)=0;  % if foot = lf. duty right = 0
dfl(dfl<=0)=[] ; % if duty factor is zero, make empty.
dfr(dfr<=0)=[];
dfa(dfa<=0)=[];

num=numel(dfa)+2; % nunber of obj in the FSTO image
no=numel(SW)+2;   % no.(#) of obj in the pawprints image

LPR=median(lpr);  %limb phase right.
LPL=median(lpl);  %limb phase left.
SYM=median(sym);
SLM=median(SL);
SWM=median(SW);
DFA=median(dfa);
DFR=median(dfr);
DFL=median(dfl);

stepfq=zeros(size(foot));   % to find step frequency.
for j=3:numel(foot)
    if foot(j)==foot(j-2)
        stepfq(j)=hpaws(j,4)-hpaws(j-2,4);
    end
end
stepfq(stepfq==0)=[];
STEPFQ=1/median(stepfq);% take median period, make a true freq. for ouput
STEPFQ=round(STEPFQ*100000)/100000;

% HEK May 5 2015 - temporary exclusion of Limb Phase data
var_out=cat(2,velocity,SYM,DFA,DFR,DFL,SLM,SWM,LPR,LPL,STEPFQ,num, no,numerr) ;   % matrix of medians, and errors of note.
% var_out=cat(2,velocity,SYM,DFA,DFR,DFL,SLM,SWM,num, no,numerr) ;   % matrix of medians, and errors of note.
xlswrite(trialname,var_out,'hindpaws','A25:M25');                                % write to individual trial's sheet.
xlswrite(trialname,{'Velocity (pix/frame)','Symmetry (%)','Duty Factor: All (%)','DF: Right(%)','DF: Left(%)','Stride Length (pix)','Step Width (pix)','Limb Phase Left (%)', 'Limb Phase Right (%)','Stride Freq (stride/frame)','# FSTO Objects','# Pawprint Objects','# Critical Errors'},'hindpaws','A24:M24');
xlswrite(trialname,{'Median Parameters:'},'hindpaws','A23');

%write the medians to the Master case logic file on sheet: Hindpaws
xlswrite('Master_spreadsheet_AGATHA_whiterat.xlsx',{'Movie Title','Velocity (pix/frame)','Symmetry (%)','Duty Factor: All (%)','DF: Right (%)','DF: Left (%)','Stride Length (pix)','Step Width (pix)','Limb Phase Left (%)', 'Limb Phase Right (%)','Stride Freq (stride/frame)','# FSTO Objects','# Pawprint Objects','# Critical Errors'},'Hindpaws','A1:N1');

row=strcat( 'B', int2str(rownum),':N', int2str(rownum)  );
% write to master logic sheet for this folder on this row: rownum
% strting at col B. title of video will write to col A, below:

cell=strcat( 'A', int2str(rownum)  );
xlswrite('Master_spreadsheet_AGATHA_whiterat.xlsx',var_out,'Hindpaws',row);
xlswrite('Master_spreadsheet_AGATHA_whiterat.xlsx',{TrialIDName},'Hindpaws',cell);
% the movie file name will go in the cell.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a clone of the above for fore paws
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foot=fpaws(:,6);
sym=fpaws(:,7);
dfa=fpaws(:,8);
SL=fpaws(:,9);
SW=fpaws(:,10);
errcheck=fpaws(:,13);
errcheck(errcheck>=100000)=1;
numerr=sum(errcheck(errcheck==1));
if R<.99; numerr=numerr+.667; end;

sym(sym<=0)=[];
SL(SL<=0)=[];
SW(SW<=0)=[];
dfr=dfa;
dfl=dfa;
dfl(foot==-1)=0;% if foot = rt, duty factor left =0
dfr(foot==1)=0; % if foot = lf.  duty right = 0
dfl(dfl<=0)=[] ;% zero goes to empty
dfr(dfr<=0)=[];
dfa(dfa<=0)=[];

num=numel(dfa)+2;
no=numel(SW)+2;

SYM=median(sym);
SLM=median(SL);
SWM=median(SW);
DFA=median(dfa);
DFR=median(dfr);
DFL=median(dfl);

stepfq=zeros(size(foot));%step frequency.
for j=3:numel(foot)
    if foot(j)==foot(j-2)
        stepfq(j)=fpaws(j,4)-fpaws(j-2,4);
    end
end
stepfq(stepfq==0)=[];
STEPFQ=1/median(stepfq);

var_out=cat(2,velocity,SYM,DFA,DFR,DFL,SLM,SWM,num, no,numerr) ; % matrix of medians, and errors of note.
xlswrite(trialname,var_out,'forepaws','A25:M25');                                % write to individual trial's sheet.
xlswrite(trialname,{'Velocity (pixels/frame)','Symmetry (%)','% Stance Time: Avg of all','%ST: Right (%)','%ST: Left (%)','Stride Length (pixels)','Step Width (pixels','# FSTO Objects','# Pawprint Objects','# Critical Errors'},'forepaws','A24:M24');
xlswrite(trialname,{'Median Parameters:'},'forepaws','A23');

%write the medians to the master case logic file for sheet: Forepaws
xlswrite('Master_spreadsheet_AGATHA_whiterat.xlsx',{'Movie Title','Velocity','Symmetry','Duty Factor: All','DF: Right','DF: Left','Stride Length','Step Width','# FSTO Objects','# Pawprint Objects','# Critical Errors'},'Forepaws','A1:N1');

row=strcat( 'B', int2str(rownum),':N', int2str(rownum)  );
% write to master logic sheet for this folder on this row: rownum
% strting at col B. title of video will write to col A, below:

cell=strcat( 'A', int2str(rownum)  );
xlswrite('Master_spreadsheet_AGATHA_whiterat.xlsx',var_out,'Forepaws',row);
xlswrite('Master_spreadsheet_AGATHA_whiterat.xlsx',{TrialIDName},'Forepaws',cell);
% movie title will go in this cell.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% end fore paw case logic generation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%final output plot to trace paw prints, after the xls are generated.
%note that there are many lines, designating several ways to present the
%paw print chart. My favorite is blue back drop with orange steps and a
%white marker. All color combinations are possible (except for orange backdrop)
%by commenting off the apropriate lines, per notes on right.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(3);

if colorscheme=='T'||colorscheme=='t'
    
        stepcolor = (cat(3,(Lout*.75),(Lout*.75),(Lout*.75)));   ... currently Light Grey
        fieldcolor = (cat(3, 1*abs(Lout-1),1*abs(Lout-1),1*abs(Lout-1))); ... currently White
        FIG = image(stepcolor+fieldcolor);
    
%     FIG=image(cat(3,Lout*.75,zeros(size(Lout)),zeros(size(Lout))));
    
    hold on;
    scatter(centerx,centery,'k');
    scatter(centerX,centerY-100,'k','v');
    
    AGATHA_step(2:length(centerx)+1,3) = centerx;
    AGATHA_step(2:length(centery)+1,4) = centery;
    leghold = hpaws(:,6);
    leghold(leghold<0) = 0;
    AGATHA_step(2:length(leghold)+1,5) = leghold;
    if vel<0
        AGATHA_step(2:length(leghold)+1,6) = leghold;
    else
        AGATHA_step(2:length(leghold)+1,6) = leghold+vel;
    end    
    
    
else
    
    % FIG1=(  cat(  3,  zeros(size(Lout)),    (Lout*33/255),            (Lout*165/255) )  ) ;          % steps are blue
    FIG1=(  cat(  3,    (Lout),               (Lout*74/255),             zeros(size(Lout)) )  ) ;      % steps are orange
    
    % FIG2=(  cat(  3,  ones(size(Lout))-Lout, ones(size(Lout))-Lout,   ones(size(Lout))-Lout));                       % bknd is white.
    FIG2=(  cat(  3,  zeros(size(Lout)), 33/255*(ones(size(Lout))-Lout),   165/255*(ones(size(Lout))-Lout) ));         % bknd is blue.
    
    FIG=image(FIG1+FIG2);
    hold on;
    
    % scatter(centerx,centery,'MarkerEdgeColor',[1 74/255 0],'LineWidth',1.3);                         %markers in orange
    % scatter(centerX,centerY-100,'v','MarkerEdgeColor',[1 74/255 0],'LineWidth',1.3);
    
    % scatter(centerx,centery,'MarkerEdgeColor',[0 33/255 165/255],'LineWidth',1.3)                    %markers in blue
    % scatter(centerX,centerY-100,'v','MarkerEdgeColor',[0 33/255 165/255],'LineWidth',1.3);
    
    scatter(centerx,centery,'MarkerEdgeColor',[1 1 1],'LineWidth',1.0)                                 %markers in white
    scatter(centerX,centerY-100,'v','MarkerEdgeColor',[1 1 1],'LineWidth',1.0);
    
end

ylabel('Y axis Pixels');
xlabel('X axis Pixels.');
title({name;'Triangles mark centroids fore, circles hind. Prints in blue. Fore prints are offset 100 pixels for clarity'});
saveas(FIG,cat(2,TrialIDName,'_Pawprint Output Image'),'tif');
saveas(FIG,cat(2,TrialIDName,'_Pawprint Output Image'),'fig');

if PO_ShowAll == 0 && PO_PawPrint == 0;
    %     close(3);
    hold off;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % end "if-exist name of movie block". encompaseses nearly all lines above.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    string=cat(2,'! **Warning** ! Cannot find file: ',TrialIDName);
    display(string);
end

xlswrite(['STEP Coordinates' TrialIDName '.xls'],AGATHA_stepnames,1,'A1');
xlswrite(['STEP Coordinates' TrialIDName '.xls'],AGATHA_step,1,'A2');


display(' ');
display(['AGATHA_whiterat Complete for ',TrialIDName]);

% end





























% clearvars( '-except', 'vid', 'video');
    



                                                         