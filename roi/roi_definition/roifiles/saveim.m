roi = files('ROI*nii');
underlay = '/Users/bobspunt/Drive/Writing/Empirical/SVN/data/final_output/Jun_21_2014_MNI8_LOIS_2X3_NoModelCue_InclACC_InclRT_ARrwls_128s/OSTT_FLEX_N=19_minN=16_rmout=0/meanT1_N=19.nii';
[path, name] = cellfun(@fileparts, roi, 'Unif', false);
for i = 1:length(roi)
    outname = sprintf('DISPLAY_%s', name{i});
    bob_spm_sliceprint_auto(underlay, roi{i}, 'sagittal', [0.1 10 12], outname, 1, 0, 'Purples');
end