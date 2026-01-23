-- utility functions for picotron

-- clamp value between min and max
function mid(a, b, c)
 if b < a then return a end
 if b > c then return c end
 return b
end

-- sign function
function sgn(x)
 if x < 0 then return -1 end
 if x > 0 then return 1 end
 return 0
end

-- absolute value
function abs(x)
 if x < 0 then return -x end
 return x
end

-- floor function
function flr(x)
 return math.floor(x)
end

-- random number (0 to n-1)
function rnd(n)
 if n == nil or n == 0 then
  return math.random()
 end
 return math.random() * n
end

-- add to table
function add(t, v)
 table.insert(t, v)
end

-- remove from table
function del(t, v)
 for i, item in ipairs(t) do
  if item == v then
   table.remove(t, i)
   return
  end
 end
end

-- iterate over table
function all(t)
 local i = 0
 return function()
  i = i + 1
  return t[i]
 end
end

-- button state (placeholder - needs picotron API)
function btn(n)
 -- TODO: implement with picotron input API
 return false
end

-- button pressed (placeholder - needs picotron API)
function btnp(n)
 -- TODO: implement with picotron input API
 return false
end

-- sound effect (placeholder - needs picotron audio API)
function sfx(n)
 -- TODO: implement with picotron audio API
end

-- print text (placeholder - needs picotron draw API)
function print(text, x, y, col)
 -- TODO: implement with picotron draw API
end

-- draw line (placeholder - needs picotron draw API)
function line(x1, y1, x2, y2, col)
 -- TODO: implement with picotron draw API
end

-- draw rectangle (placeholder - needs picotron draw API)
function rect(x1, y1, x2, y2, col)
 -- TODO: implement with picotron draw API
end

-- draw filled rectangle (placeholder - needs picotron draw API)
function rectfill(x1, y1, x2, y2, col)
 -- TODO: implement with picotron draw API
end

-- clear screen (placeholder - needs picotron draw API)
function cls(col)
 -- TODO: implement with picotron draw API
end

-- window setup (placeholder - needs picotron window API)
function window(params)
 -- TODO: implement with picotron window API
end
