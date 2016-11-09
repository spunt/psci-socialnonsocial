% MAKE SLIDES 
% Combine a photograph and a sentence on the same slide
% -----------------------------------------------------
clear all;
basedir   = pwd;
npixels   = 2;
outdim    = [900 1200];
% photodir  = fullfile(basedir, 'test_stimuli');
% outputdir = '/Users/bobspunt/Github/research-projects/iowa-loi-behavioral/loi_socns/stimuli';
photodir  = fullfile(basedir, 'practice_stimuli');
outputdir = '/Users/bobspunt/Github/research-projects/iowa-loi-behavioral/loi_socns/stimuli/practice';
inname    = files([photodir filesep '*.jpg']);
[~,n,e]   = cellfileparts(inname); 
outname   = fullfile(outputdir, strcat(n, '.jpg')); 
sc        = imread('scale.jpg');

for p = 1:length(inname)
    
    % read in photo
    op                          = imread(inname{p});
    op                          = imresize(op, [750 1000]);
    op(:,1:npixels,:)           = 250;
    op(1:npixels,:,:)           = 250;
    op(:,end-(npixels-1):end,:) = 250;
    op(end-(npixels-1):end,:,:) = 250;
    sc(226:975,301:1300,:)      = op;
    slide                       = imresize(sc, outdim);
    imwrite(slide, outname{p}, 'jpg')
        
end









    