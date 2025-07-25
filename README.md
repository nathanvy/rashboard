# Rashboard - Rails Dashboard

I'm 110% certain this name probably already exists, if not in the Rails ecosystem then certainly in Rust, but it's groovy so I'm keeping it despite the collision.

This is a Rails-based dashboard to display certain performance stats from my algorithmic trading application.

## Getting started

#+begin_src 
$ git clone
$ docker compose build
$ RAILS_MASTER_KEY=$(cat config/credentials/production.key) docker compose up -d
#+end_src
