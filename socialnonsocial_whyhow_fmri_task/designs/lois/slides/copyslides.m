% MAKE SLIDES 
% Combine a photograph and a sentence on the same slide
% -----------------------------------------------------
clear all; close all hidden

basedir = pwd;
photodir = '/Users/bobspunt/Desktop/photos';
namedir = [basedir filesep 'photos/lois_demo'];
outdir = [basedir filesep 'photos/demo'];
cd(namedir)
names = files('*.jpg');
for i = 1:length(names)
    cim = names{i};
    imaddborder([photodir filesep cim],4,'');
    movefile([photodir filesep cim],[outdir filesep cim,]);
end
cd(basedir)



names = files('*.jpg');
for i = 1:length(names)
    cim = names{i};
    imaddborder([photodir filesep cim],4,'');
end






    