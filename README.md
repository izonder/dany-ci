# DANY-CI - Docker CI image with Node.js and Yarn

**DANY-CI** = **D**ocker + **A**lpine + **N**ode.js + **Y**arn + **CI**

[![](https://images.microbadger.com/badges/version/izonder/dany-ci.svg)](https://microbadger.com/images/izonder/dany-ci "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/izonder/dany-ci.svg)](https://microbadger.com/images/izonder/dany-ci "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/izonder/dany-ci.svg?branch=master)](https://travis-ci.org/izonder/dany-ci)

## Features

- Alpine linux as base-image
- Docker in container
- Node.js (fully-static without NPM)
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
