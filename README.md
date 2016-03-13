# SDVX Emulator

A basic Sound Voltex emulator with support for [K-Shoot MANIA](http://kshoot.client.jp)
maps, written in Lua using [LÖVE](http://love2d.org).  
Name subject to change.

The goal of the `prototype` branch is to reverse-engineer and
[describe](KSHSPEC.md) the K-Shoot MANIA chart format and write a parser with a
simple two-dimensional renderer for it. This includes finding an efficient and
flexible way of storing and looking up events during gameplay.

After this work has been finished, development of the main game will continue on
`develop`, following [git flow](http://nvie.com/posts/a-successful-git-branching-model)
branching strategies.
