# VAD:  Voice Activity Detector

The VAD receives 8kHz, 16-bit, mono, signed-linear PCM data over a TCP socket,
running it through the Silero VAD ML model, and returns for each processed block
a one-byte unsigned integer (00-FF) for the confidence that voice is present.

Generally, we seem to be able to use fairly high confidences as a threshold:
\>97\% (`> 0xF7`).

**Usage note**:  the model is intended as an aggregate, so whenever the client side
determines that it has sufficient data to indicate a voice, it should terminate
the connection, dialing again when it wants to detect voice again, even if that
is during the same telephone conversation.


## Testing

Samples may be tested with `ffmpeg` and `nc`, like so:

```sh
$ fmpeg -hide_banner -loglevel error -re -i test.wav -f s16le - | nc localhost 3030 |hexdump
```

