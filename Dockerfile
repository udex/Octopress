FROM ubuntu:14.04

MAINTAINER udex <dmitriyukhov@gmail.com>

ENV HOME /home/blog
ENV SITE /blog
ENV PATH $HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH
ENV VERSION 1.9.3-p0

# install packages
RUN apt-get update && apt-get -qy upgrade
RUN apt-get install -qy \
  build-essential \
  nodejs \
  python \
  python-dev \
  language-pack-en \
  git \
  curl \
  zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean

# setup utf locale
ENV LC_ALL en_US.utf8

# set up user so that host files have correct ownership
RUN useradd -ms /bin/bash --uid 1000 --gid 50 deploy

# install ruby to deploy's home directory
WORKDIR $HOME
RUN git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"' >> .bashrc
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
RUN eval "$(rbenv init -)"
RUN git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN ~/.rbenv/plugins/ruby-build/install.sh
RUN rbenv install $VERSION
RUN rbenv global  $VERSION
RUN rbenv rehash

# add files from current blog
ADD . $SITE
WORKDIR $SITE

# install dependencies
RUN gem install bundler
RUN rbenv rehash
RUN bundle install

# change permissions
RUN chown -R deploy:staff $SITE
RUN chown -R deploy:staff $HOME/.rbenv/
RUN chown deploy:staff $HOME/.bashrc
USER deploy
RUN chmod -R 755 $SITE
RUN chmod -R 755 $HOME/.rbenv/
RUN chmod 755 $HOME/.bashrc

ENTRYPOINT ["rake"]