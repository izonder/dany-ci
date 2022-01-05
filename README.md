# DANY-CI - Docker CI image with Node.js and Yarn

**DANY-CI** = **D**ocker + **A**lpine + **N**ode.js + **Y**arn + **CI**

[![Build Docker image](https://github.com/izonder/dany-ci/actions/workflows/docker-image.yml/badge.svg?branch=nodejs-14)](https://github.com/izonder/dany-ci/actions/workflows/docker-image.yml)

## Features

- Alpine linux as base-image
- Docker in container
- Node.js (without NPM)
- Yarn package manager

## How to use?

E.g. `.gitlab-ci.yml`:
```yml
image: izonder/dany-ci:latest

stages:
    - test
    - build

unit:
    stage: test
    scripts:
        - yarn install
        - yarn test

image:
    stage: build
    scripts:
        - yarn install
        - yarn build
```
