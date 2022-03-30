#!/usr/bin/env/python3
import os
import sys
import shutil
import torch
import torchaudio
import speechbrain as sb
import numpy as np
import argparse
import glob
import json
import librosa
import scipy
from scipy.io import wavfile
import os
import pandas as pd
import requests
import soundfile as sf
import time

PCS = np.ones(257)      # Perceptual Contrast Stretching
PCS[0:3] = 1
PCS[3:6] = 1.070175439
PCS[6:9] = 1.182456140
PCS[9:12] = 1.287719298
PCS[12:138] = 1.4       # Pre Set
PCS[138:166] = 1.322807018
PCS[166:200] = 1.238596491
PCS[200:241] = 1.161403509
PCS[241:256] = 1.077192982

maxv = np.iinfo(np.int16).max

def Sp_and_phase(signal):        
    signal_length = signal.shape[0]
    n_fft = 512
    y_pad = librosa.util.fix_length(signal, signal_length + n_fft // 2)
    
    F = librosa.stft(y_pad, n_fft=512, hop_length=256, win_length=512, window=scipy.signal.hamming)
    
    Lp=PCS*np.transpose(np.log1p(np.abs(F)), (1,0))
    phase=np.angle(F)
    
    NLp=np.transpose(Lp, (1,0))
    
    return NLp, phase, signal_length

def SP_to_wav(mag, phase, signal_length):
    mag = np.expm1(mag)
    Rec = np.multiply(mag , np.exp(1j*phase))
    result = librosa.istft(Rec,
                           hop_length=256,
                           win_length=512,
                           window=scipy.signal.hamming, length=signal_length)
    return result  

          
def get_filepaths(directory):
    """
    This function will generate the file names in a directory 
    tree by walking the tree either top-down or bottom-up. For each 
    directory in the tree rooted at directory top (including top itself), 
    it yields a 3-tuple (dirpath, dirnames, filenames).
    """
    file_paths = []  # List which will store all of the full filepaths.

    # Walk the tree.
    for root, directories, files in os.walk(directory):
        for filename in files:
            # Join the two strings in order to form the full filepath.
            filepath = os.path.join(root, filename)
            file_paths.append(filepath)  # Add it to the list.

    return file_paths  # Self-explanatory.
    

parser = argparse.ArgumentParser()

parser.add_argument('--test_clean_folder', default="", type=str)
parser.add_argument('--test_noisy_folder', default="", type=str)
parser.add_argument('--output_folder', default="", type=str)

args = parser.parse_args()

######################### validation data #########################
Test_Clean_path = args.test_clean_folder
Test_Noisy_paths = get_filepaths(args.test_noisy_folder)
Output_path = args.output_folder


for i in Test_Noisy_paths:
    noisy_wav,_ = torchaudio.load(i)
    noisy_LP, Nphase, signal_length= Sp_and_phase(noisy_wav.squeeze().numpy())
    
    enhanced_wav = SP_to_wav(noisy_LP, Nphase, signal_length)
    enhanced_wav = enhanced_wav/np.max(abs(enhanced_wav))
    
    torchaudio.save(
        Output_path+i.split('/')[-1],
        torch.unsqueeze(torch.from_numpy(enhanced_wav).type(torch.float32), 0),
        16000,
    )
