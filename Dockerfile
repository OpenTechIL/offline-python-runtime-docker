FROM python:3.13-slim-trixie

RUN apt-get update && apt-get install -y libaio1t64 libaio-dev unzip curl && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/oracle

RUN curl -o instantclient-basic.zip https://download.oracle.com/otn_software/linux/instantclient/1929000/instantclient-basic-linux.x64-19.29.0.0.0dbru.zip && \
    unzip -o instantclient-basic.zip && \
    rm instantclient-basic.zip

RUN ln -s /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_29:$LD_LIBRARY_PATH
ENV ORACLE_HOME=/opt/oracle/instantclient_19_29
ENV ORACLE_INSTANTCLIENT_PATH=/opt/oracle/instantclient_19_29

RUN useradd -m appuser
RUN chown -R appuser /home/appuser

USER appuser

WORKDIR /home/appuser

RUN mkdir -p /home/appuser/.local/bin

COPY ./requirements.txt .

ENV PATH=/home/appuser/.local/bin:$PATH
# If you want to download
# RUN pip download -d ./packages -r requirements.txt
# RUN pip install --no-index --find-links=./packages -r requirements.txt

RUN pip install --user -r requirements.txt

COPY --chown=appuser:appuser ./py-apps/ ./py-apps/

#RUN tests
RUN pytest -v py-apps/tests/


CMD ["python", "./py-apps/main.py"]