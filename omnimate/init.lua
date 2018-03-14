-- VERSION 0.9
--[[
Omnimate: an animation player object inspired by Godot's Animation Player node

Copyright 2018 Brian Sarfati

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local _PACKAGE = string.gsub(...,"%.","/") or ""

local omnimate = {}

local AnimationPlayer = require(_PACKAGE .. "/player")
local Animation = require(_PACKAGE .. "/animation")
local KeyFrame = require(_PACKAGE .. "/keyframe")

omnimate.newAnimationPlayer = AnimationPlayer.newAnimationPlayer
omnimate.newAnimation = Animation.newAnimation
omnimate.newKeyFrame = KeyFrame.newKeyFrame
omnimate.ARGS = Animation.ARGS

return omnimate