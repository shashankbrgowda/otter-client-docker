# otter-client-docker

Ensembl otter in Docker container

## OSX Installation

In order to run Otter client GUI in a docker container we are using Socat and Xquartz. Socat is a unix tool which allows bidirectional streams between two connections and Xquartz is a X window system for OSX operating system which is used for running GUI remotely. As a result we create connection between docker container running otter GUI and xquartz.

#### OSX Prerequisites

* Docker

#### Installation steps

We need to run two simple scripts to install and run otter client

```
cd otter-client-docker
```

Run the installtion script first. After running this script we need to restart our computer for xquartz to work as expected.
```
./osx/install.sh
```

Now run the start script to start the otter client. We need to enter file location of config.ini (ex: /home/ebi/config.ini) when prompted. We can mount more files through volumn if necessary.
```
./osx/start.sh
```

Note: .otter directory of otter client is mounted on $HOME/otter/ and /var/tmp/otter_root/ on $HOME/otter/sqlite/

---

## Ubuntu Installation

In order to run Otter client GUI in a docker container we are using Socat and X server. Socat is a unix tool which allows bidirectional streams between two connections and X server system is used for running GUI remotely. As a result we create connection between docker container running otter GUI and x server.

#### OSX Prerequisites

* Docker

#### Installation steps

We need to run two simple scripts to install and run otter client

```
cd otter-client-docker
```

Run the installtion script first.
```
./ubuntu/install.sh
```

Now run the start script to start the otter client. We need to enter file location of config.ini (ex: /home/ebi/config.ini) when prompted. We can mount more files through volumn if necessary.
```
./ubuntu/start.sh
```

Note: .otter directory of otter client is mounted on $HOME/otter/ and /var/tmp/otter_root/ on $HOME/otter/sqlite/
