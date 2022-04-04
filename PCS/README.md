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


## Citation:
If you find the code useful in your research, please cite:  
```
@article{chao2022perceptual,  
  title={Perceptual Contrast Stretching on Target Feature for Speech Enhancement},
  author={Chao, Rong and Yu, Cheng and Fu, Szu-Wei and Lu, Xugang and Tsao, Yu},
  journal={arXiv preprint arXiv:2203.17152},
  year={2022}
}
```
