import io
import socket
import socketserver
import os
import sys
import numpy as np
import pyaudio
import torch
torch.set_num_threads(4)
from colorama import Fore

# DEBUG indicates whether debugging information is displayed to the terminal
if os.getenv('DEBUG'):
    DEBUG=True
else:
    DEBUG=False

# Taken from utils_vad.py
def validate(model,
             inputs: torch.Tensor):
    with torch.no_grad():
        outs = model(inputs)
    return outs

# Provided by Alexander Veysov
def int2float(sound):
    abs_max = np.abs(sound).max()
    sound = sound.astype('float32')
    if abs_max > 0:
        sound *= 1/abs_max
    sound = sound.squeeze()  # depends on the use case
    return sound

class SileroServer(socketserver.ThreadingMixIn, socketserver.TCPServer):            
    pass

class SileroProcessor(socketserver.BaseRequestHandler):            
    def handle(self):
        FORMAT = pyaudio.paInt16
        CHANNELS = 1
        SAMPLE_RATE = 8000
        CHUNK = 1600 # 10 frames of 160 bytes each
        
        # load Silero model
        model, utils = torch.hub.load(repo_or_dir='./silero',
                                  model='silero_vad',
                                  source='local',
                                  force_reload=True)

        (get_speech_timestamps,
         save_audio,
         read_audio,
         VADIterator,
         collect_chunks) = utils

        while True:
            try:
                audio_chunk = self.request.recv(CHUNK)
            except:
                print('connection closed')
                break

            if not audio_chunk:
                print('connection closed')
                break

            if len(audio_chunk) < CHUNK:
                #print('ignoring short data')
                continue

            #import pdb; pdb.set_trace()
            
            audio_int16 = np.frombuffer(audio_chunk, np.int16);
            
            audio_float32 = int2float(audio_int16)
            
            new_confidence = model(torch.from_numpy(audio_float32), SAMPLE_RATE).item()

            confidenceByte = int((new_confidence) * 0xff).to_bytes(1, "little")

            self.request.send(confidenceByte)

            if DEBUG:
                if new_confidence > 0.97:
                    print(Fore.GREEN + "{:0.2f}".format(new_confidence) + Fore.RESET)
                else:
                    print("{:0.2f}".format(new_confidence))

listenPort = 3030

if len(sys.argv) > 1:
 listenPort = int(sys.argv[1])

with SileroServer(("0.0.0.0", listenPort), SileroProcessor) as svc:
    svc.serve_forever()

