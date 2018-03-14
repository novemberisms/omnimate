--[[
Omnimate: an animation player object inspired by Godot's Animation Player node

Copyright 2018 Brian Sarfati

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local Easing = require(_PACKAGE .. "/easing")
local KeyFrame = require(_PACKAGE .. "/keyframe")

local Animation = {}
Animation.__index = Animation
Animation.__tostring = function() return "Omnimate Animation Object" end

function Animation:init()
  self.keyframes = {} -- autosorted array
  self.tracks = {}
  self.duration = 0
end

function Animation:act(subject, curr_time, animation_args)
  for key in pairs(self.tracks) do
    -- figure out between which keyframes the track will use based on curr_time
    local prev_keyframe, next_keyframe = self:getActiveKeyFramesForTrack(key, curr_time)
    if not prev_keyframe then return end
    if not next_keyframe then next_keyframe = prev_keyframe end
    
    local elapsed_time = curr_time - prev_keyframe.time
    local ease_duration = next_keyframe.time - prev_keyframe.time
    if ease_duration == 0 then 
      ease_duration = 1
      elapsed_time = 1
    end
    
    local prev_value = prev_keyframe.target[key]
    local next_value = next_keyframe.target[key]
    
    self:actOnSubject(
      subject, 
      key, 
      next_keyframe.easing_mode, 
      prev_value, 
      next_value, 
      elapsed_time, 
      ease_duration,
      animation_args
    )
    
  end
end

function Animation:getActiveKeyFramesForTrack(track, curr_time)
  local prev_keyframe, next_keyframe
  -- get the last keyframe before curr_time with the track
  for i, keyframe in ipairs(self.keyframes) do
    if keyframe.time > curr_time then break end
    if keyframe.target[track] ~= nil then prev_keyframe = keyframe end
  end
  -- get the first keyframe after curr_time with the track
  for i, keyframe in ipairs(self.keyframes) do
    if curr_time > keyframe.time then goto continue end
    if keyframe.target[track] ~= nil then 
      next_keyframe = keyframe
      break
    end
    ::continue::
  end
  return prev_keyframe, next_keyframe
end

function Animation:getEaseObject(track, easing_mode)
  if type(easing_mode) == "table" then
    return easing_mode[track] or Easing.linear
  elseif type(easing_mode) == "string" then
    return Easing[easing_mode] or Easing.linear
  elseif type(easing_mode) == "function" then
    return easing_mode
  end
  error("Invalid easing mode for animation")
end

-- one of the ugliest and hackiest recursive functions I have ever written. 
-- I still don't quite understand it completely but it works!
function Animation:actOnSubject(subject, key, easing_mode, prev_value, next_value, elapsed_time, duration, animation_args)
  local prev_value = self:confirmValue(prev_value, animation_args)
  local next_value = self:confirmValue(next_value, animation_args)
  
  local ease_object = self:getEaseObject(key, easing_mode)

  if (type(prev_value) == "number") and (type(next_value) == "number") then
    local ease_fxn = self:getEaseObject(nil, ease_object)
    subject[key] = ease_fxn(
      prev_value,
      next_value,
      elapsed_time,
      duration
    )
  elseif (ease_object ~= "raw_table") and 
         (easing_mode ~= "raw_table") and
         (type(prev_value) == "table") and 
         (type(next_value) == "table") then
    
    for nested_key,nested_value in pairs(prev_value) do
      local nested_ease_mode = self:getEaseObject(nested_key, ease_object)
      
      self:actOnSubject(
        subject[key],
        nested_key,
        nested_ease_mode, -- this is also either a string or a table
        prev_value[nested_key],
        next_value[nested_key],
        elapsed_time,
        duration,
        animation_args
      )
    end
  ---[[
  elseif (type(prev_value) == "cdata") and
         (type(next_value) == "cdata") and
         prev_value.__pairs then
    local ease_fxn = self:getEaseObject(nil, ease_object)
    for cname, cvalue in pairs(prev_value) do
      subject[key][cname] = ease_fxn(
        prev_value[cname],
        next_value[cname],
        elapsed_time,
        duration
      )
    end
  --]]
  else
    subject[key] = prev_value
  end
end

function Animation:getActiveKeyFrames(time)
  local prev_keyframe, next_keyframe
  for i,keyframe in ipairs(self.keyframes) do
    -- we are always guaranteed a keyframe at t=0
    if time < keyframe.time then break end
    prev_keyframe = keyframe
    next_keyframe = self.keyframes[i+1]
  end
  return prev_keyframe, next_keyframe
end

function Animation:addKeyFrame(new_keyframe)
  -- autosort keyframe array
  local last_keyframe = self.keyframes[#self.keyframes]
  if (#self.keyframes == 0) or (new_keyframe.time > last_keyframe.time) then
    -- most common case: appending a new keyframe to the end of the animation
    table.insert(self.keyframes, new_keyframe)
    self.duration = new_keyframe.time
  else
    for i,curr_keyframe in ipairs(self.keyframes) do
      if new_keyframe.time < curr_keyframe.time then
        -- put in between existing keyframes
        table.insert(self.keyframes, i, new_keyframe)
        break
      elseif new_keyframe.time == curr_keyframe.time then
        -- if same time, just replace the old one entirely
        self.keyframes[i] = new_keyframe
        break
      end
    end
  end
  -- update tracks
  for key in pairs(new_keyframe.target) do
    if not self.tracks[key] then
      self.tracks[key] = true
    end
  end
end

function Animation:newKeyFrame(time, target, easing_table)
  -- create keyframe
  local new_keyframe = KeyFrame.newKeyFrame(time, target, easing_table)
  self:addKeyFrame(new_keyframe)
  -- return the newly created keyframe so we can attach callbacks to it
  return new_keyframe
end

function Animation.ARGS(n)
  return {
    __is_animation_arg = true,
    __n = n
  }
end

function Animation:confirmValue(value, animation_args)
  if type(value) == "table" and value.__is_animation_arg then
    return animation_args[value.__n]
  end
  return value
end

function Animation.newAnimation()
  local new_animation = setmetatable({},Animation)
  new_animation:init()
  return new_animation
end

return Animation