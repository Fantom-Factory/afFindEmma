#Find Emma! v1.0.2
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v1.0.2](http://img.shields.io/badge/pod-v1.0.2-yellow.svg)](http://www.fantomfactory.org/pods/afFindEmma)
![Licence: ISC Licence](http://img.shields.io/badge/licence-ISC Licence-blue.svg)

## Overview

"Find Emma!" is a Birthday present for my wife, Emma.

It is a retro style text adventure game in the ilk of [Zork](https://en.wikipedia.org/wiki/Zork) and [Colossal Cave Adventure](https://en.wikipedia.org/wiki/Colossal_Cave_Adventure).

It's about a little doggy who has to feed animals in the garden, open presents, eat snacks, and ultimately find her best pal, Emma! The whole game is based on a dog we're (currently) fostering and our village home in South Wales, UK.

Play "Find Emma!" online at [http://findemma.fantomfactory.org/](http://findemma.fantomfactory.org/).

## Install

Install `Find Emma!` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afFindEmma

Or install `Find Emma!` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afFindEmma

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afFindEmma 1.0"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afFindEmma/) - the Fantom Pod Repository.

## Play Locally

To run "Find Emma!" locally, install the `afFindEmma.pod` into your Fantom environment and then run the following command:

    C:\> fan afFindEmma 8069

This starts up a webserver and "Find Emma!" may then be played in a browser by visiting [http://localhost:8069/](http://localhost:8069/).

## Stats

"Find Emma!" has 62 interactable objects and 29 rooms.

