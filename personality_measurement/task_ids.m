function task_ids(subjectID, inputDevice)
% =========================================================================
% Personality Meaurement
% Bob Spunt
% Social Cognitive Neuroscience Lab (www.scn.ucla.edu)
% University of California, Los Angeles
% =========================================================================
if nargin==0

    disp('Set monitor resolution to 1920 x 1200'); 

    %---------------------------------------------------------------
    % PRINT TITLE TO SCREEN
    %---------------------------------------------------------------
    script_name='- Individual Differences -'; boxTop(1:length(script_name))='=';
    fprintf('%s\n%s\n%s\n',boxTop,script_name,boxTop)

    %---------------------------------------------------------------
    % GET INPUT
    %---------------------------------------------------------------
    subjectID   = ptb_get_input_string('\nEnter Subject ID: ');
    inputDevice = ptb_get_resp_device;
    
end

%---------------------------------------------------------------
% INITIALIZE SCREENS
%---------------------------------------------------------------
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
xcenter=wWidth/2;
ycenter=wHeight/2;
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

% colors
grayLevel=0;    
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
Screen('FillRect', w, grayLevel);
Screen('Flip', w);

% text
theFont='Arial';
Screen('TextSize',w,55);
theight = Screen('TextSize', w);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);

% cues
fixation='+';

% compute default Y position (vertically centered)
numlines = length(strfind(fixation, char(10))) + 1;
bbox = SetRect(0,0,1,numlines*theight);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
PosY = dv;
% compute X position for fixation
bbox=Screen('TextBounds', w, fixation);
[rect,dh,dv] = CenterRect(bbox, Screen('Rect', w));
fixPosX = dh;

HideCursor;

%---------------------------------------------------------------
% DEFINE RESPONSE KEYS
%---------------------------------------------------------------
b1=KbName('1!');
b2=KbName('2@');
b3=KbName('3#');
b4=KbName('4$');
b5=KbName('5%');
b6=KbName('6^');
b7=KbName('7&');
b8=KbName('8*');
b9=KbName('9(');
spacebar=KbName('space');
enter=KbName('Return');

%---------------------------------------------------------------
% GET AND LOAD STIMULI
%---------------------------------------------------------------
DrawFormattedText(w, 'LOADING', 'center','center',white, 46);
Screen('Flip',w);

% get respones scale and figure out positioning
cd stimuli
scaleTex=Screen('MakeTexture',w,imread('scale.jpg'));
tRect=Screen('Rect', scaleTex);
[ctRect, dx, dy]=CenterRect(tRect, Screen('Rect', w));
scaleRect = ctRect;
scaleRect([2 4]) = scaleRect([2 4])+250; 

% get items
cd scales
d = dir('*.xls');
for s = 1:length(d)
    
    scales{s}.name = d(s).name;
    [num txt raw]=xlsread(scales{s}.name);
    scales{s}.name(end-3:end)=[];
    txt(strcmp(txt,''))=[];
    txt = regexprep(txt,'Õ','''');
    scales{s}.items = txt;
    scales{s}.key = num;
    n = length(txt);
    scales{s}.rt = zeros(n,1);
    scales{s}.rawresp = zeros(n,1);
    scales{s}.revresp = zeros(n,1);
    
end
cd ../..
nscales = length(scales);
%---------------------------------------------------------------
% INSTRUCTIONS
%---------------------------------------------------------------
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
WaitSecs(0.25);
Screen('TextSize',w,44);
instructCUE='For this task you will read several sets of statements that may be more or less desciptive of you. Use the 1-4 keys to indicate the extent to which you agree with each statement. If you encounter a statement to which you feel you cannot respond, you may skip the statement by pressing [spacebar].\n\nTo start the first set of statements, press [spacebar].';
DrawFormattedText(w, instructCUE, 'center','center',white,46);
Screen('Flip',w);
noresp = 1;
while noresp
    [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
    if keyIsDown && keyCode(spacebar)
        noresp=0;
        Screen('FillRect', w, grayLevel);
        Screen('Flip', w);
    end
    WaitSecs(.001)
end
WaitSecs(1)

%---------------------------------------------------------------
% TRIAL PRESENTATION
%---------------------------------------------------------------
try

    for t=1:nscales

        if t~=1
            Screen('TextSize',w,50);
            transitionCUE='Feel free to take a short break. Press [spacebar] when you are ready to see the next set of statements.';
            DrawFormattedText(w, transitionCUE, 'center','center',white,46);
            Screen('Flip',w);
            WaitSecs(.25)
            noresp = 1;
            while noresp
                [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
                if keyIsDown && keyCode(spacebar)
                    noresp=0;
                    Screen('FillRect', w, grayLevel);
                    Screen('Flip', w);
                end
                WaitSecs(.001)
            end
            WaitSecs(.5)
        end
        
        Screen('TextSize',w,55);
        
        citems = scales{t}.items;
        n = length(citems);
        
        for i = 1:n
            
            Screen('DrawTexture',w, scaleTex,[],scaleRect);
            DrawFormattedText(w, citems{i},'center','center',white,46);
            Screen('Flip',w);
            stimStart=GetSecs;
            WaitSecs(.25)
            noresp = 1;
            while noresp
                [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
                if keyIsDown && (keyCode(b1) || keyCode(b2) || keyCode(b3) || keyCode(b4) || keyCode(spacebar))
                    noresp=0;
                    scales{t}.rt(i)=secs-stimStart;
                    Screen('FillRect', w, grayLevel);
                    Screen('Flip', w);
                    if keyCode(b1)
                        scales{t}.rawresp(i)=1;
                    elseif keyCode(b2)
                        scales{t}.rawresp(i)=2;
                    elseif keyCode(b3)
                        scales{t}.rawresp(i)=3;
                    elseif keyCode(b4)
                        scales{t}.rawresp(i)=4;
                    else
                        scales{t}.rawresp(i)=NaN;
                    end
                end
                WaitSecs(.001);
            end
            WaitSecs(.25)

        end % end of item loop
        
        % reverse score
        scales{t}.revresp = scales{t}.rawresp;
        idx = find(scales{t}.key(:,2));
        raw = scales{t}.rawresp(idx);
        rev = 5-raw;
        scales{t}.revresp(idx) = rev;
        
        WaitSecs(1)
    end; % end of scale loop
    
% %---------------------------------------------------------------
% % Mari's items
% %---------------------------------------------------------------
% 
% WaitSecs(2)
% 
% % sexuality: categorical
% CUE='Which of the following best describes you? (1=Heterosexual/Strait,   2=Bisexual,   3=Gay/Lesbian)';
% DrawFormattedText_new(w, CUE, 'center','center',white,800,0,0);
% Screen('Flip',w)
% noresp = 1;
% while noresp
%     [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
%     if keyIsDown && (keyCode(b1) || keyCode(b2) || keyCode(b3))
%         noresp=0;
%         if keyCode(b1)
%             demographics.sexualitycat = 1;
%         elseif keyCode(b2)
%             demographics.sexualitycat = 2;
%         else
%             demographics.sexualitycat = 3;
%         end
%         Screen('FillRect', w, grayLevel);
%         Screen('Flip', w);
%     end
%     WaitSecs(.001)
% end
% Screen('FillRect', w, grayLevel);
% Screen('Flip', w);
% WaitSecs(0.25);
% 
% % sexuality: continuous
% CUE=' On a scale from 1(Exclusively Heterosexual) to 50(Equally Heterosexual and Homosexual) to 100(Exclusively Homosexual), what number best describes your sexual orientation, overall?';
% DrawFormattedText_new(w,CUE, 'center',300,white,800,0,0);
% demographics.sexualitycont_overall = GetEchoString(w,'Type your number: ',xcenter-200, ycenter, white, black);
% Screen('FillRect', w, grayLevel);
% Screen('Flip', w);
% WaitSecs(0.25);
% 
% CUE='On a scale from 1(Exclusively Heterosexual) to 50(Equally Heterosexual and Homosexual) to 100(Exclusively Homosexual), what number best describes your sexual attractions?';
% DrawFormattedText_new(w,CUE, 'center',300,white,800,0,0);
% demographics.sexualitycont_sexatt = GetEchoString(w,'Type your number: ',xcenter-200, ycenter, white, black);
% Screen('FillRect', w, grayLevel);
% Screen('Flip', w);
% WaitSecs(0.25);
% 
% CUE='On a scale from 1(Exclusively Heterosexual) to 50(Equally Heterosexual and Homosexual) to 100(Exclusively Homosexual), what number best describes your sexual fantasies?';
% DrawFormattedText_new(w,CUE, 'center',300,white,800,0,0);
% demographics.sexualitycont_fantasy = GetEchoString(w,'Type your number: ',xcenter-200, ycenter, white, black);
% Screen('FillRect', w, grayLevel);
% Screen('Flip', w);
% WaitSecs(0.25);
% 
% CUE='On a scale from 1(Exclusively Heterosexual) to 50(Equally Heterosexual and Homosexual) to 100(Exclusively Homosexual), what number best describes your sexual behaviors?';
% DrawFormattedText_new(w,CUE, 'center',300,white,800,0,0);
% demographics.sexualitycont_behav = GetEchoString(w,'Type your number: ',xcenter-200, ycenter, white, black);
% Screen('FillRect', w, grayLevel);
% Screen('Flip', w);
% WaitSecs(0.25);
% 
% CUE='On a scale from 1(Exclusively Heterosexual) to 50(Equally Heterosexual and Homosexual) to 100(Exclusively Homosexual), what number best describes your romantic attractions?';
% DrawFormattedText_new(w,CUE, 'center',300,white,800,0,0);
% demographics.sexualitycont_romatt = GetEchoString(w,'Type your number: ',xcenter-200, ycenter, white, black);
% Screen('FillRect', w, grayLevel);
% Screen('Flip', w);
% WaitSecs(0.25);
    
catch
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end;

%---------------------------------------------------------------
% SAVE DATA
%---------------------------------------------------------------
d=clock;
outfile=sprintf('ids_%s_%s_%02.0f-%02.0f.mat',subjectID,date,d(4),d(5));
cd data
try
    save(outfile, 'subjectID', 'scales');
catch
	fprintf('couldn''t save %s\n saving to ids_behav.mat\n',outfile);
	save ids_behav
end;
cd ..

% ---------------------------------------------------------------
% End study 
% ---------------------------------------------------------------

instructCUE3='Please let the experimenter know that you are done.';
DrawFormattedText(w, instructCUE3, 'center','center',white,46);
Screen('Flip',w);

noresp=1;
while noresp
    [keyIsDown,secs,keyCode]=KbCheck(inputDevice);
    if keyIsDown
        noresp=0;
    end
WaitSecs(.001);
end

%---------------------------------------------------------------
% CLOSE SCREENS
%---------------------------------------------------------------
Screen('CloseAll');
Priority(0);
ShowCursor;

end
% =========================================================================
% *
% * SUBFUNCTIONS
% *
% =========================================================================
function chosen_device = ptb_get_resp_device(prompt)
% PTB_GET_RESPONSE Psychtoolbox utility for acquiring responses
%
% USAGE: chosen_device = ptb_get_resp_device(prompt)
%
% INPUTS 
%  prompt = to display to user
%
% OUTPUTS
%  chosen_device = device number
%
% Adapted by Bob Spunt (Jan. 8, 2013) from function by Don Kalar

% --------------------- Copyright (C) 2013 ---------------------
%	Author: Bob Spunt (adapted from hid_probe.m by Don Kalar)
%	Affilitation: Caltech
%	Email: spunt@caltech.edu
%
%	$Revision Date: Oct_24_2013

if nargin < 1, prompt = 'Enter Subject Response Device'; end
chosen_device = [];
numDevices=PsychHID('NumDevices');
devices=PsychHID('Devices');
candidate_devices = [];
str = upper('Potential Response Devices');
boxTop(1:length(str))='-';
keyboard_idx = GetKeyboardIndices;
fprintf('\n%s\n%s\n%s\n',boxTop,str,boxTop)
if length(keyboard_idx)==1
    fprintf('Defaulting to one found keyboard: %s, %s\n',devices(keyboard_idx).usageName,devices(keyboard_idx).product)
    chosen_device = keyboard_idx;
else 
    for i=1:length(keyboard_idx), n=keyboard_idx(i); fprintf('%d - %s, %s\n',i,devices(n).usageName,devices(n).product); candidate_devices = [candidate_devices i]; end
    prompt_string = sprintf('\n%s (%s): ', prompt, num2str(candidate_devices));
    while isempty(chosen_device)
        chosen_device = input(prompt_string);
        if isempty(chosen_device)
            fprintf('Invalid Response!\n')
            chosen_device = [];
        elseif isempty(find(candidate_devices == chosen_device))
            fprintf('Invalid Response!\n')
            chosen_device = [];
        end
    end
    chosen_device = keyboard_idx(chosen_device);
end
end
function out = ptb_get_input_string(prompt)
% PTB_GET_INPUT_STRING Psychtoolbox utility for getting valid user input string
%
% USAGE: out = ptb_get_input(prompt)
%
% INPUTS 
%  prompt = string containing message to user
%
% OUTPUTS
%  out = input
%

% ----------------------------- Copyright (C) 2013 -----------------------------
%	Author: Bob Spunt
%	Affilitation: Caltech
%	Email: spunt@caltech.edu
%
%	$Revision Date: Oct_24_2013

if nargin<1, disp('USAGE: out = ptb_get_input(prompt)'); return; end
out = input(prompt, 's');
while isempty(out)
    disp('ERROR: You entered nothing. Try again.');
    out = input(prompt, 's');
end
end
         
    
    


