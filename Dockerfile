# Dockerfile.build
FROM elixir as builder
ENV DEBIAN_FRONTEND=noninteractive
RUN mkdir /opt/tools
WORKDIR /opt/tools
COPY . /opt/tools
RUN mix local.hex --force
RUN mix deps.get
RUN mix compile
# RUN mix escript.build
CMD ["mix"]

# FROM node
# WORKDIR /opt/tools
# COPY ./utils /usr/tools
# RUN npm -g babel-cli 
# RUN npm i


