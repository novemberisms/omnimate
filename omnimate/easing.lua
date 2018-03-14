--[[
Omnimate: an animation player object inspired by Godot's Animation Player node

Copyright 2018 Brian Sarfati

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
local Easing = {}

---------------------------------------------------------------------------------------
function Easing.linear(start_v, end_v, curr_time, total_time)
  return start_v + (curr_time / total_time) * (end_v - start_v)
end

---------------------------------------------------------------------------------------
function Easing.step(start_v, end_v, curr_time, total_time)
  return start_v
end

function Easing.ceiling(start_v, end_v, curr_time, total_time)
  return end_v
end

function Easing.nearest(start_v, end_v, curr_time, total_time)
  return ((curr_time / total_time) < 0.5) and start_v or end_v
end

---------------------------------------------------------------------------------------
function Easing.exponential(start_v, end_v, curr_time, total_time)
  if curr_time == 0 then return start_v end
  return start_v + (end_v - start_v) * (math.exp(-(total_time - curr_time) * 5 / total_time))
end

function Easing.inverse_exponential(start_v, end_v, curr_time, total_time)
  if curr_time == total_time then return end_v end
  return start_v + (end_v - start_v) * (1 - math.exp(-curr_time * 5 / total_time)) * 1.007
end

---------------------------------------------------------------------------------------
function Easing.quadratic(start_v, end_v, curr_time, total_time)
  local norm = curr_time / total_time
  return start_v + (end_v - start_v) * norm * norm
end

function Easing.inverse_quadratic(start_v, end_v, curr_time, total_time)
  -- derived from y-1 = -(x-1)^2
  local norm = curr_time / total_time
  return start_v + (end_v - start_v) * norm * (2 - norm)
end
---------------------------------------------------------------------------------------
function Easing.sine(start_v, end_v, curr_time, total_time)
  return start_v + (end_v - start_v) * math.sin((math.pi / 2) * (curr_time / total_time))
end

function Easing.inverse_sine(start_v, end_v, curr_time, total_time)
  local angle = (math.pi / 2) * (3 + curr_time / total_time)
  return start_v + (end_v - start_v) * (1 + math.sin(angle))
end

function Easing.in_out_sine(start_v, end_v, curr_time, total_time)
  local angle = (math.pi / 2) * (3 + 2 * curr_time / total_time)
  return start_v + (end_v - start_v) * (1 + math.sin(angle)) / 2
end
---------------------------------------------------------------------------------------
function Easing.logistic(start_v, end_v, curr_time, total_time)
  local x = curr_time / total_time
  return start_v + (end_v - start_v) / (1 + math.exp(-10 * (x - 0.5)))
end
---------------------------------------------------------------------------------------

local function outElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c/a)
  end

  return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

function Easing.elastic(start_v, end_v, curr_time, total_time)
  return outElastic(curr_time, start_v, end_v - start_v, total_time)
end

---------------------------------------------------------------------------------------
local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end

function Easing.bounce(start_v, end_v, curr_time, total_time)
  return outBounce(curr_time, start_v, end_v - start_v, total_time)
end
---------------------------------------------------------------------------------------


-- aliases

Easing.lin = Easing.linear
Easing.ceil = Easing.ceiling
Easing.quad = Easing.quadratic
Easing.inv_quad = Easing.inverse_quadratic
Easing.exp = Easing.exponential
Easing.inv_exp = Easing.inverse_exponential
Easing.sin = Easing.sine
Easing.inv_sin = Easing.inverse_sine

---------------------------------------------------------------------------------------

return Easing