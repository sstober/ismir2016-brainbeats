Matlab Code for:
   Sebastian Stober; Thomas Prätzlich & Meinard Müller.
   Brain Beats: Tempo Extraction from EEG Data.
   International Society for Music Information Retrieval Conference (ISMIR), 2016
   https://dx.doi.org/10.6084/m9.figshare.3398545

* DEMO.m gives an overview of the MATLAB scripts 

data/:
- beats - Onsets of beats in audio (librosa/Ellis beat tracker) (like HAMR)
- (raw - EEG data, one file with 5 trials (64 channels) per stimulus ID and subject (like HAMR), needs to be generated from OpenMIIR EEG recordings, see below ** )
- sce-filtered - filtered EEG-data, 64 channels are aggregated (and normalized to [-1,1]) using 5 trials per stimulus and subject
  * single precision data for SCE filter EEG data -> don't forget to convert to double after import
- v2 - Audio stimuli (copied and renamed from https://github.com/sstober/openmiir/tree/master/audio/full.v2 )


** extra: python code to generate the data files from the original OpenMIIR EEG recordings
Note: 
To run the experiments (Matlab code) as described in the paper, all data is already provided here. This code is provided additionally in case somebody, for instance, wants to also run the analysis for the other subjects (who listened to some slightly different stimuli, cf. OpenMIIR paper) or use a different EEG pre-processing pipeline. This also requires to download the full OpenMIIR dataset from https://github.com/sstober/openmiir (See also instructions to download the EEG files which are not included in the git repository because of their size!) and install a working python environment with at least Numpy, Theano, Blocks, MNE-Python, Matplotlib, Logging.

Included files:
data_preprocessing_and_export.ipynb - main script
deepthought/ - part of the deepthought library from http://github.com/sstober/deepthought needed to run the main script
sce-weights.npy - channel weights for the SCE filter as shown in the paper
