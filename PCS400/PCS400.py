#!/usr/bin/env/python3
import os
import torch
import torchaudio
import numpy as np
import argparse
import librosa
import scipy

# PCS400 parameters
PCS400 = np.ones(201)
PCS400[0:3] = 1
PCS400[3:5] = 1.070175439
PCS400[5:8] = 1.182456140
PCS400[8:10] = 1.287719298
PCS400[10:110] = 1.4       # Pre Set
PCS400[110:130] = 1.322807018
PCS400[130:160] = 1.238596491
PCS400[160:190] = 1.161403509
PCS400[190:202] = 1.077192982


maxv = np.iinfo(np.int16).max


def Sp_and_phase(signal):
    signal_length = signal.shape[0]
    n_fft = 400
    hop_length = 100
    y_pad = librosa.util.fix_length(signal, size=signal_length + n_fft // 2)

    F = librosa.stft(y_pad, n_fft=n_fft, hop_length=hop_length, win_length=n_fft, window=scipy.signal.hamming)
    Lp = PCS400 * np.transpose(np.log1p(np.abs(F)), (1, 0))
    phase = np.angle(F)

    NLp = np.transpose(Lp, (1, 0))

    return NLp, phase, signal_length


def SP_to_wav(mag, phase, signal_length):
    mag = np.expm1(mag)
    Rec = np.multiply(mag, np.exp(1j*phase))
    result = librosa.istft(Rec,
                           hop_length=100,
                           win_length=400,
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

parser.add_argument('--input_folder', default="", type=str)
parser.add_argument('--output_folder', default="", type=str)

args = parser.parse_args()


# ---------- validation data ---------- #
Test_Noisy_paths = get_filepaths(args.input_folder)
Output_path = args.output_folder

if Output_path[-1] != '/':
    Output_path = Output_path + '/'

for i in Test_Noisy_paths:
    print(i)
    noisy_wav, _ = torchaudio.load(i)

    if _ != 16000:
        print("Warning: Audio is not 16000 Hz.")

    # for dual audio:
    if noisy_wav.shape[0] == 2:
        print("Warning: Audio is not mono.")
        noisy_wav = noisy_wav[0].unsqueeze(0)

    noisy_LP, Nphase, signal_length = Sp_and_phase(noisy_wav.squeeze().numpy())

    enhanced_wav = SP_to_wav(noisy_LP, Nphase, signal_length)
    enhanced_wav = enhanced_wav/np.max(abs(enhanced_wav))

    torchaudio.save(
        Output_path+i.split('/')[-1],
        torch.unsqueeze(torch.from_numpy(enhanced_wav).type(torch.float32), 0),
        16000,
    )
