import os
import pdb
import sys
import matlab.engine
import math
import numpy as np
from multiprocessing import Pool
from functools import partial
from tqdm import tqdm
from pystoi.stoi import stoi
from scipy.io import wavfile

def get_paths(root_dir):
    ret = []
    for root, dirs, files in os.walk(root_dir):
        for f in files:
            if f.endswith('.wav'):
                ret.append(os.path.join(root, f))
    return sorted(ret)

def foo(a, b):
    return a, b

def get_score(x):
    for i, s in enumerate(x):
        if math.isnan(s):
            print(i)
    return np.mean(np.array(x))

def eval(clean, enhanced, num_worksers=2):
    pesq, sig, bak, ovl, ssnr, wss = [], [], [], [], [], []
    stois = []
    errs = []
    low_performance = []
    [clean_paths, enhanced_paths] = map(get_paths, [clean, enhanced])
    #pdb.set_trace()
    param_list = [(c, p) for c, p in zip(clean_paths, enhanced_paths)]

    eng = matlab.engine.start_matlab()
    eng.addpath('E_evaluation_2/')
    #pdb.set_trace()
    pbar = tqdm(param_list)
    #pdb.set_trace()
    for c, p in pbar:
        #pdb.set_trace()
        sr, clean = wavfile.read(c)
        sr, enhanced = wavfile.read(p)
        #print(clean.shape[0], enhanced.shape[0])
        if clean.shape[0] != enhanced.shape[0]:
            length = min(clean.shape[0], enhanced.shape[0])
            clean = clean[:length]
            enhanced = enhanced[:length]
        #pdb.set_trace()
        stois.append(stoi(clean, enhanced, sr))
        assert c.split('/')[-1] == p.split('/')[-1]
        ret = eng.composite(c, p, nargout=6)
        if p.split('.wav')[0][-3:] == "002":
            pass
        else:
            if np.isnan(ret[0]):
                pdb.set_trace()
            pesq.append(ret[0])
            sig.append(ret[1])
            bak.append(ret[2])
            ovl.append(ret[3])
            ssnr.append(ret[4])
            wss.append(ret[5])
        if ssnr[-1] < 0:
            errs.append(p)
        if pesq[-1] < 2.5:
            low_performance.append(p)
        pbar.set_postfix({
            'PESQ': pesq[-1],
            'STOI': stois[-1],
            'CSIG': sig[-1],
            'CBAK': bak[-1],
            'COVL': ovl[-1],
            'SSNR': ssnr[-1]
        })
    # TODO construction of multiprocessing
    '''
    with Pool(num_worksers) as p:
        ret = p.starmap(partial(eng.composite, nargout=4), param_list)
    '''
    eng.quit()

    return [pesq, sig, bak, ovl, ssnr, wss, stois], errs, low_performance



if __name__ == "__main__":
    ret, errs, low_performance = eval(sys.argv[1], sys.argv[2])
    scores = list(map(get_score, ret))
    print(scores)
