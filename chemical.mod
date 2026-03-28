module mongodb

source "src"

import std

import "chemicallang/mongodb" branch "win-x64" if windows and !arm
import "chemicallang/mongodb" branch "win-arm64" if windows and arm

import "chemicallang/mongodb" branch "linux-x64" if linux and !arm
import "chemicallang/mongodb" branch "linux-arm64" if linux and arm

import "chemicallang/mongodb" branch "linuxmusl-x64" if linux and musl and !arm
import "chemicallang/mongodb" branch "linuxmusl-arm64" if linux and musl and arm

import "chemicallang/mongodb" branch "macos-x64" if macos and !arm
import "chemicallang/mongodb" branch "macos-arm64" if macos and arm