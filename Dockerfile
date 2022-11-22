FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade

RUN apt-get install -y --no-install-recommends \
autoconf \
automake \
build-essential \
cpanminus \
exonerate \
git \
hmmer \
libalgorithm-munkres-perl \
libanyevent-perl \
libarray-compare-perl \
libbio-das-lite-perl \
libbz2-dev \
libclone-perl \
libconfig-dev \
libconfig-inifiles-perl \
libconst-fast-perl \
libcrypt-cbc-perl \
libcrypt-jwt-perl \
libcurl4-openssl-dev \
libdata-rmap-perl \
libdata-stag-perl \
libdb-dev \
libdbd-mysql-perl \
libdbd-sqlite3-perl \
libdbi-perl \
libdevel-checklib-perl \
libfile-slurp-perl \
libgd-perl \
libgetopt-long-descriptive-perl \
libgtk2.0-dev \
libhash-merge-perl \
libhash-merge-simple-perl \
libhtml-tableextract-perl \
libio-string-perl \
libio-stringy-perl \
libio-tiecombine-perl \
libjson-perl \
libjson-xs-perl \
liblingua-en-inflect-perl \
liblist-moreutils-perl \
liblog-log4perl-perl \
liblwp-protocol-https-perl \
liblzma-dev \
libmodule-build-perl \
libmodule-pluggable-perl \
libmoose-perl \
libmoosex-log-log4perl-perl \
libmoosex-role-strict-perl \
libmysqlclient-dev \
libnamespace-autoclean-perl \
libparams-validate-perl \
libpng-dev \
libproc-processtable-perl \
libreadline-dev \
libreadonly-perl \
libscalar-list-utils-perl \
libset-scalar-perl \
libsqlite3-dev \
libssl-dev \
libstring-rewriteprefix-perl \
libtask-weaken-perl \
libterm-readkey-perl \
libtest-cleannamespaces-perl \
libtest-fatal-perl \
libtest-mockobject-perl \
libtest-most-perl \
libtest-needs-perl \
libtest-requires-perl \
libtest-sharedfork-perl \
libtest-tcp-perl \
libtest-warnings-perl \
libtext-sprintfn-perl \
libtool \
libtry-tiny-perl \
libwww-curl-perl \
libxml-dom-perl \
libxml-dom-xpath-perl \
libxml-parser-perl \
libxml-sax-writer-perl \
libxml-simple-perl \
libxml-twig-perl \
libxml-writer-perl \
libxmu-dev \
libyaml-perl \
libzmq3-dev \
libzmq-ffi-perl \
mysql-client \
perl-tk \
uuid-dev \
zlib1g-dev

RUN git config --global --add safe.directory '*'
RUN git config --global http.sslverify false

RUN echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"' >> ~/.profile
RUN . ~/.profile

# install minimal bioperl 1.6
RUN cd ${HOME} && \
mkdir src && \
cd src && \
git clone --branch release-1-6-924 --depth 1 https://github.com/bioperl/bioperl-live.git && \
cd bioperl-live && \
perl Build.PL --accept=n && \
./Build --prefix=~/perl5 && \
./Build --prefix=~/perl5 install

# clone our repos
RUN cd ${HOME} && \
git clone https://github.com/Ensembl/otter-client.git && \
cd otter-client/software/anacode/otter/otter_rel109/ && \
rm -r ensembl-otter/ ensembl/ && \
git clone https://github.com/Ensembl/ensembl-otter.git && \
git clone --branch release/108 https://github.com/ensembl/ensembl

# install seqtools
RUN cd ${HOME}/src && \
git clone https://github.com/Ensembl/seqtools.git && \
cd seqtools/src && \
./autogen.sh && \
./configure --prefix=/usr/local && \
make && \
make install

# install zmap
# We set options for gdb, stack-protector and sanitizers to catch bugs in ZMap
# ZMap brings along an installation of htslib 1.3 which Kent will need
RUN cd ${HOME}/src && \
git clone --depth 1 https://github.com/Ensembl/zmap.git && \
cd zmap/src/ && \
./autogen.sh && \
./configure CFLAGS="-ggdb -Og -I/usr/include/openssl" \
  CXXFLAGS="-ggdb -Og -I/usr/include/openssl" \
  LDFLAGS="-fsanitize=address,undefined -fstack-protector -L/usr/lib/x86_64-linux-gnu/libmysqlclient.so -L/usr/lib/x86_64-linux-gnu/libssl.so" \
  --prefix=/usr/local && \
make && \
make install

RUN apt-get install -y --no-install-recommends wget

# install Kent lib
# We add / change:
#  -fPIC: to produce position independent code;
#  -z muldefs: allow multiple definitions of a symbol when linking;
#  fix the my_bool type that is not actually defined;
#  use the current name of the constant in libssl to specify what to verify
RUN cd ${HOME}/src && \
export KENT_SRC=$PWD/kent/src && \
export MACHTYPE=$(uname -m) && \
wget https://github.com/ucscGenomeBrowser/kent/archive/v335_base.tar.gz && \
tar xzf v335_base.tar.gz && rm -rf v335_base.tar.gz kent-335_base/java kent-335_base/python && \
mv kent-335_base kent && \
cd kent/src && \
sed -i "s/CC=gcc/CC=gcc -fPIC -z muldefs/g" ./inc/common.mk && \
sed -i "28s/L=/L=-lz/" ./inc/common.mk && \
sed -i "1109s/my_bool/bool/" ./hg/lib/jksql.c && \
sed -i "1110s/MYSQL_OPT_SSL_VERIFY_SERVER_CERT/CLIENT_SSL_VERIFY_SERVER_CERT/" ./hg/lib/jksql.c && \
make -C lib && \
make -C jkOwnLib && \
ln -s $KENT_SRC/lib/x86_64/* $KENT_SRC/lib/ && \
# install htslib 1.13
# This version also exists in Ubuntu 22, but is built with curl-gnutls.
# We want it built with curl-openssl, because we need that to build Bio::DB::HTS later
cd ${HOME}/src && \
export HTSLIB_DIR=${HOME}/src/htslib-1.13 && \
wget https://github.com/samtools/htslib/releases/download/1.13/htslib-1.13.tar.bz2 && \
tar xvf htslib-1.13.tar.bz2 && \
cd htslib-1.13/ && \
./configure --prefix=/usr/local && \
make && \
make install && \
ldconfig && \
export PERL_CPANM_OPT="-l $HOME/perl5" && \
cpanm --force Bio::DB::HTS Bio::DB::BigFile

RUN cpanm --force Bio::PrimarySeqI
RUN cpanm --force Mac::PropertyList
RUN cpanm --force ZMQ::LibZMQ3

#RUN mkdir /var/tmp/otter_root && \
#chown -R root:root /var/tmp/otter_root/

CMD $HOME/otter-client/software/anacode/otter/otter_live/bin/otter