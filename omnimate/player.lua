--[[
Omnimate: an animation player object inspired by Godot's Animation Player node

Copyright 2018 Brian Sarfati

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""


local AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer

local Animation = require (_PACKAGE .. "/animation")

function AnimationPlayer:init(owner)
  self.owner = owner
  self.animations = {}
  self.timer = 0
  self.state = "stopped"
  self.playing = nil
  self.current_animation = nil
  self.callbacks = {}
  self.animation_args = {}
end

function AnimationPlayer:update(dt)
  if not self.current_animation then return end
  if self.state == "playing" then
    self.timer = self.timer + dt
    self:checkForCallbacks()
    self.current_animation:act(self.owner, self.timer, self.animation_args)
    if self.timer > self.current_animation.duration then
      self:stop()
    end
  end
end

function AnimationPlayer:addAnimation(name, animation)
  self.animations[name] = animation
end

function AnimationPlayer:play(animation_name,...)
  assert(self.animations[animation_name], "no such animation defined: " .. animation_name)
  self.current_animation = self.animations[animation_name]
  self.playing = animation_name
  self.timer = 0
  self.state = "playing"
  self.animation_args = {...}
  self:queueCallbacks(self.current_animation)
end

function AnimationPlayer:stop()
  self.timer = 0
  self.current_animation = nil
  self.playing = nil
  self.state = "stopped"
  self.animation_args = {}
  self:clearCallbacks()
end

function AnimationPlayer:pause()
  if self.state == "playing" then
    self.state = "paused"
  end
end

function AnimationPlayer:resume()
  if self.state == "paused" then
    self.state = "playing"
  end
end

function AnimationPlayer:newCallbackObject(time,callback)
  return {
    time = time,
    callback = callback
  }
end

function AnimationPlayer:queueCallbacks(animation)
  self.callbacks = {}
  for i,keyframe in ipairs(animation.keyframes) do
    if keyframe.callback then
      table.insert(self.callbacks,self:newCallbackObject(keyframe.time, keyframe.callback))
    end
  end
end

function AnimationPlayer:checkForCallbacks()
  while (#self.callbacks > 0) and (self.timer >= self.callbacks[1].time) do
    local callback = table.remove(self.callbacks,1).callback
    callback(self.owner)
  end
end

function AnimationPlayer:clearCallbacks()
  self.callbacks = {}
end

function AnimationPlayer:isStopped() return self.state == "stopped" end
function AnimationPlayer:isPlaying() return self.state == "playing" end
function AnimationPlayer:isPaused() return self.state == "paused" end

function AnimationPlayer:getCurrentAnimation()
  return self.playing, self.current_animation
end

function AnimationPlayer.newAnimationPlayer(owner)
  local new_player = setmetatable({},AnimationPlayer)
  new_player:init(owner)
  return new_player
end

return AnimationPlayer