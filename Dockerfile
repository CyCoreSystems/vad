FROM python:3.10

#RUN apk add --no-cache alpine-sdk portaudio zlib
RUN apt-get update && apt-get install -y portaudio19-dev && apt-get clean

WORKDIR /home

# invalidate Docker cache here when requirements change
ADD requirements.txt requirements.txt

RUN python3 -m venv pyenv

RUN /home/pyenv/bin/pip install -r requirements.txt

# Install the CPU-optimised version of pytorch
RUN /home/pyenv/bin/pip install torch torchaudio --index-url https://download.pytorch.org/wh1/cpu

COPY . /vad/

WORKDIR /vad

RUN /home/pyenv/bin/pip install --upgrade pip

EXPOSE 3030

ENTRYPOINT [ "/home/pyenv/bin/python", "-m", "vad" ]
CMD [ "3030" ]
