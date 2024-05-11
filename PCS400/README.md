# implement PCS
In the experiments, we used Short-time Fourier transform (STFT) with n_FFT=**400**, hop_length=**100**, windown_length=**400**, and Hamming window. 
Additionally, the audio we used in VoiceBank-DEMAND dataset was resampled to a sample rate of 16,000.
  
In the scenario mentioned above, the PCS we used is displayed on lines 10 ~ 20 of `PCS400.py`

# Post-processing PCS

The proposed PCS can also be used as a post-processing (PP) method.  
Here, we offer you an easy way to use it.  

## Requirements
- torch
- torchaudio
- librosa
- numpy
- scipy
- argparse

## How to use ?
The audio to be processed should be placed in a folder. (denote as **input_folder**)  
- You should modify the `--input_folder` (folder path), and `--output_folder` (folder path) in `runPCS.sh` first.
- Then execute `sh runPCS.sh`. The audio processed by PP-PCS will be saved to the `--output_folder`.
  
> Notice that if the **sample rate** of input audio is not **16000**, please modify the parameter of `torchaudio.save()` in `PCS.py`


## Citation:
If you find the code useful in your research, please cite:  
```
@article{chao2022perceptual,  
  title={Perceptual Contrast Stretching on Target Feature for Speech Enhancement},
  author={Chao, Rong and Yu, Cheng and Fu, Szu-Wei and Lu, Xugang and Tsao, Yu},
  journal={Proc. of INTERSPEECH},
  year={2022}
}
```
