# Quest: bringing dhall to Javascript

see: https://github.com/dhall-lang/dhall-lang/issues/58

This project tries to
make [the dhall compiler](https://github.com/dhall-lang/dhall-lang) accessible
from Javascript, and eventually (in a typed manner) Purescript.

Instead of rewriting the whole thing, we use
the [https://github.com/ghcjs/ghcjs](GHCJS) Haskell to Javascript compiler to
convert the officiall dhall library to a minified Javascript library.

For now this is to be seen as proof of concept and by no means as a
production-ready (much less supported) project.

## Building

*Attention:* the nix `ghcjsHEAD` release is used on a quite recent master.
It might take a while to build the necessary compiler and libraries.

```
For the unminified output:
$ nix-build -A orig  release.nix

For the (experimental) minified version:
$ nix-build -A small  release.nix

To run:
$ node ./release
```


## Speed concerns

Care needs to be taken that the resulting code loads and executes with an
acceptable speed. This means the least amount of conversions possible should
take place.

Speed might be also influenced by the following:

* GHCJS (Haskell) runtime:
  Haskell has a runtime which implements its laziness (via “thunks”) and
  green-thread parallelism (via “sparks”, which is reimplemented by GHCJS as a
  set of Javascript primitives. This runtime of course has some overhead if we
  execute it on calls to dhall. This might be a steady overhead for each call
  into dhall, but has not been measured yet.
* Converting between JS and GHCJS String representations
* Internal Haskell representation as strict vs lazy `String`s and/or `Text`
