module mongodb

source "src"

import std

import "chemicallang/mongodb" orphan branch "win-x64" if windows and !arm
import "chemicallang/mongodb" orphan branch "win-arm64" if windows and arm

import "chemicallang/mongodb" orphan branch "linux-x64" if linux and !arm
import "chemicallang/mongodb" orphan branch "linux-arm64" if linux and arm

import "chemicallang/mongodb" orphan branch "linuxmusl-x64" if linux and musl and !arm
import "chemicallang/mongodb" orphan branch "linuxmusl-arm64" if linux and musl and arm

import "chemicallang/mongodb" orphan branch "macos-x64" if macos and !arm
import "chemicallang/mongodb" orphan branch "macos-arm64" if macos and arm