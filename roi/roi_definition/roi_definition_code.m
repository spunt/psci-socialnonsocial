baseim = files('Ts*/Tstat*nii');
bspm_imcalc(baseim, 'minTstat_Study1and3.nii', 'min');
in = 'minTstat_Study1and3.nii';
thresh.cluster = [.0005 150];
thresh.peak = [5.76 20];
thresh.separation = 40;
roi.shape = 'Sphere';
roi.size = 15; 
bspm_save_rois(in, thresh, roi)
roifile = files(sprintf('ROI*%s%d_SEP%d.nii', upper(roi.shape), roi.size, thresh.separation)); 
ccname = sprintf('COLORCODED_ROIMAP_%s%d_SEP%d.nii', upper(roi.shape), roi.size, thresh.separation);
bob_spm_imcalc(roifile, ccname, 'colorcode');
FIVEb(ccname);
delete *structure.mat
delete *thresh*clusters.nii
% movefile ROI*nii roifiles/

