--[[
Omnimate: an animation player object inspired by Godot's Animation Player node

Copyright 2018 Brian Sarfati

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local KeyFrame = {}
KeyFrame.__index = KeyFrame

function KeyFrame:init(time, target, easing_mode)
  self.time = time
  self.target = target
  self.easing_mode = easing_mode
  self.callback = nil
end

function KeyFrame:callback(fxn)
  self.callback = fxn
end

function KeyFrame.newKeyFrame(time, target, easing_mode)
  -- validate inputs
  local easing_mode = easing_mode or "linear"
  local target = target or {}
  assert(time >= 0, "time cannot be a negative number")
  
  local keyframe = setmetatable({},KeyFrame)
  keyframe:init(time, target, easing_mode)
  return keyframe
end

return KeyFrame