FROM registry.access.redhat.com/ubi9/ruby-30
MAINTAINER Eguzki Astiz Lezaun <eastizle@redhat.com>

USER root

RUN gem install bundler --version 2.3.5 --no-document

WORKDIR /usr/src/app
COPY . .

RUN chmod +t /tmp

RUN bundle config --local silence_root_warning 1 \
    && bundle config --local disable_shared_gems 1 \
    && bundle config --local without "development test" \
    && bundle config set --local deployment 'true' \
    && bundle config --local gemfile Gemfile \
    && bundle config set --local path 'vendor/bundle'

RUN bundle install \
    && bundle binstubs 3scale_toolbox

ENV PATH="/usr/src/app/bin:${PATH}"

# Drop privileges
USER default

WORKDIR /opt/app-root/src

CMD ["/bin/bash"]
