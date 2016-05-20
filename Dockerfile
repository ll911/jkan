FROM ruby:2.1-onbuild
MAINTAINER leo.lou@gov.bc.ca
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES true
ENV LC_CTYPE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANG C.UTF-8

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
  && git config --global url.https://github.com/.insteadOf git://github.com/ \
  && gem install nokogiri -- --use-system-libraries -N \
  && gem install jekyll -N \
  && gem install github-pages -N \
  && gem install bundler -N \
  && DEBIAN_FRONTEND=noninteractive apt-get purge -y \
  && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
  && DEBIAN_FRONTEND=noninteractive apt-get clean \  
  && rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/ll911/jkan.git /tmp/repo1 && cp -r /tmp/repo1/* /usr/src/app && rm -Rf /tmp/repo1
RUN cd /usr/src/app 
RUN bundle install
RUN bundle exec jekyll build
RUN bundle exec htmlproof ./_site --disable-external --allow-hash-href

RUN useradd -ms /bin/bash jekyll \
  && chown -R jekyll:0 /usr/src/app \
  && chmod -R 770 /usr/src/app

USER jekyll
WORKDIR /usr/src/app
EXPOSE 4000
CMD jekyll serve --host 0.0.0.0
