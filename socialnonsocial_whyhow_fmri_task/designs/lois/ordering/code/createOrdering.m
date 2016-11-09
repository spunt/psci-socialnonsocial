% SPECS
clear all
basedir = pwd;
stimdatadir = [basedir filesep 'stimdata'];
stimdir = ['/Users/bobspunt/Drive/Research/Caltech/whyhow/tasks/fmri/stimuli/lois'];

% save?
FLAG = 1;
PRINT = 0;

% block level
nBlocks = 36;           % # blocks
nConds = 6;
nTrialsBlock = 9;       % # trials/block
nStim = 162;
foilDists = [4 4 4 4 4 4];  % distribution of # foils/block

% trial level
stimDur = 2;
ITI = .5;
nYes = 180;
nNo = 144;

% read in data
design1 = load('design3.txt');
design2 = load('design5.txt');
[cuen cues raw] = xlsread('cues.xlsx');
cues = cues(2:end,2:3);
preblockcues = cues(:,1);
isicues = cues(:,2);
load all_question_data.mat;
qim(:,1) = regexprep(qim(:,1),'_',' ');

% combined designs
% ----------------
design1(end) = 6;
anchor = ceil(sum(design1(end,3:5)));
design2(:,3) = design2(:,3) + anchor;
design = [design1; design2];
design(:,1) = 1:nBlocks;

% totalTime
% -------------
totalTime = ceil(sum(design(end,3:5)));

% Used in Optimizing
% NS_High Face_High Hand_High NS_Low Face_Low Hand_Low

% blockSeeker
% -------------
% 1 - block #
% 2 - condition (1=aH,2=eH,3=aL,4=eL)
% 3 - onset (s)
% 4 - cue idx 
blockSeeker = design(:,1:3);
for i = 1:6
    blockSeeker(blockSeeker(:,2)==i,4) = find(cuen(:,1)==i);
end

% trialSeeker
% -------------
% 1 - block #
% 2 - trial #
% 3 - condition (NS_High Face_High Hand_High NS_Low Face_Low Hand_Low)
% 4 - normative response (1=Yes, 2=No)
% 5 - stimulus # (corresponds to order in stimulus dir)
trialSeeker = zeros(nBlocks*nTrialsBlock,5);
for i = 1:nBlocks
    start = 1+(i-1)*nTrialsBlock;
    finish = i*nTrialsBlock;
    trialSeeker(start:finish,1) = i;
end
for i = 1:nTrialsBlock
    trialSeeker(i:nTrialsBlock:end,2) = i;
end
trialSeeker(:,3) = reshape(repmat(design(:,2),1,nTrialsBlock)',nBlocks*nTrialsBlock,1);
trialSeeker(:,4) = 1;

for i = 1:nBlocks
    
    ccue = preblockcues{blockSeeker(i,4)};
    name = ccue;
    tmpname{i} = name;
    idx = find(strcmp(qim(:,1),name));
    norm = qdata(idx,2);
    bad = 1;
    
    while bad

        bad = 0;
        randorder = randperm(length(idx));
        idx2 = idx(randorder);
        norm2 = norm(randorder);
        if norm2(1)==2
            bad = 1;
            continue
        end
        count = 1;
        for s = 2:7
            test(count) = sum(norm2(s:s+2));
            count = count + 1;
        end
        if any(test==6)
            bad = 1;
        else
            bad = 0;
            trialSeeker(trialSeeker(:,1)==i,[4 5]) = [norm2 idx2];
        end

    end

end

% get valence array
[nn nt raw] = xlsread('data_pleasantness.xlsx');
nt = nt(1,:);
for i = 1:length(nt)
    idx = strfind(nt{i},'.jpg');
    allim{i} = nt{i}(idx-5:idx+3);
    v = nn(:,i);
    imemo(i) = nanmedian(v);
end

qlist = unique(qim(:,1));
for i = 1:length(qlist)
    cims = qim(strcmp(qim(:,1),qlist{i}),2);
    idx = find(ismember(allim,cims));
    qvalence{i} = imemo(idx);
    blockvalence{i,1} = qlist{i};
    blockvalence{i,2} = nanmean(imemo(idx));
end

if FLAG
save design.mat totalTime blockSeeker trialSeeker preblockcues isicues qvalence
end



    


 
 
 
 
