FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN export GIT_SSL_NO_VERIFY=1

RUN apt-get update && apt-get install -y --no-install-recommends \
build-essential \
git \
libgd-dev \
libtry-tiny-perl \
wget \
perl-tk \
libproc-processtable-perl \
libdbi-perl \
libreadonly-perl \
liblog-log4perl-perl \
libterm-readkey-perl \
libxml-simple-perl \
libtext-sprintfn-perl \
libjson-perl \
libconfig-inifiles-perl \
liblingua-en-inflect-perl \
libio-stringy-perl \
libdata-rmap-perl \
libnamespace-autoclean-perl \
libyaml-perl \
libhash-merge-simple-perl \
libfile-slurp-perl \
libmoosex-role-strict-perl \
libmoosex-log-log4perl-perl \
cpanminus \
zip \
unzip \
libanyevent-perl \
libconst-fast-perl \
libtest-mockobject-perl \
libapache2-mod-perl2 \
mysql-client apache2 \
sqlite3 \
libsqlite3-dev \
libgtk2.0-dev \
libmysqlclient-dev \
libconfig-dev \
libhts-dev \
libreadline6-dev \
libssl-dev \
exonerate \
hmmer2 \
libdbd-sqlite3-perl \
libdbd-mysql-perl \
uuid-dev \
libbz2-dev \
liblzma-dev \
libcurl4-gnutls-dev \
libglib2.0-dev \
autoconf \
libtool


RUN git config --global --add safe.directory '*'

RUN cd && \
git clone https://github.com/Ensembl/otter-client.git && \
cd otter-client/software/anacode/otter/otter_rel109/ && \
rm -r ensembl-otter/ ensembl/ && \
git clone https://github.com/Ensembl/ensembl-otter.git && \
git clone --branch release/108 https://github.com/Ensembl/ensembl.git

RUN cpanm --force -q Log::Log4perl Proc::ProcessTable Term::ReadKey XML::Simple JSON Bio::PrimarySeqI DBI Readonly Config::IniFiles Lingua::EN::Inflect \
Mac::PropertyList Crypt::JWT Tk Moose MooseX::Log::Log4perl Data::Rmap Hash::Merge::Simple Text::sprintfn AnyEvent::Impl::Perl

RUN cd && \
apt-get install -y libbz2-dev liblzma-dev && \
wget -nc https://github.com/samtools/htslib/releases/download/1.8/htslib-1.8.tar.bz2 && \
tar xjf htslib-1.8.tar.bz2 && \
cd htslib-1.8 && \
./configure && \
make && \
make install

RUN cd && \
wget http://ftp.ebi.ac.uk/pub/software/vertebrategenomics/exonerate/exonerate-2.2.0.tar.gz && \
tar xvf exonerate-2.2.0.tar.gz && \
cd exonerate-2.2.0/ && \
./configure LIBS=-lpthread && \
make && \
make install

RUN cd && \
wget "ftp://ftp.sanger.ac.uk/pub/resources/software/seqtools/PRODUCTION/seqtools-4.44.1.tar.gz" && \
tar -zxvf seqtools-4.44.1.tar.gz && \
cd seqtools-4.44.1/ && \
./configure && \
make && \
make install

RUN apt-get install -y --no-install-recommends \
autotools-dev \
automake

RUN cd && \
git clone https://github.com/Ensembl/zmap.git && \
cd zmap/src/ && \
./autogen.sh && \
./configure CFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib/x86_64-linux-gnu/libmysqlclient.so -L/usr/lib/libssl.so" --prefix=/usr && \
make && \
make install

RUN cd && \
wget -nc "https://github.com/ucscGenomeBrowser/kent/archive/v378_branch.1.tar.gz" && \
tar -xvzf "v378_branch.1.tar.gz" && \
cp -rf kent-378_branch.1 kent && \
cd kent/src && \
CFLAGS=-fPIC make -C lib

RUN cd && \
cd ./kent/src && \
export KENT_SRC=$PWD && \
echo $KENT_SRC && \
ln -s $KENT_SRC/lib/x86_64/* $KENT_SRC/lib/ && \
cpanm --force -q Test::Pod::Coverage && \
apt-get install -y libxml-dom-xpath-perl && \
cpanm --force -q Bio::Root::Version && \
apt-get install -y hmmer && \
cpanm --force -q Bio::DB::HTS

RUN export MACHTYPE=`uname -p`

RUN cpanm --force -q ZMQ::LibZMQ3

RUN cd && \
wget https://cpan.metacpan.org/authors/id/L/LD/LDS/Bio-BigFile-1.01.tar.gz && \
tar -zxvf Bio-BigFile-1.01.tar.gz && cd Bio-BigFile-1.01 && \
perl -pi -e 's/.*extra_linker_flags.*/extra_linker_flags => ["\$jk_lib\/\$LibFile","-lhts","-lz", "-lssl"],/g' Build.PL

RUN cd && \
mkdir .otter && \
touch .otter/config.ini

CMD $HOME/otter-client/software/anacode/otter/otter_live/bin/otter