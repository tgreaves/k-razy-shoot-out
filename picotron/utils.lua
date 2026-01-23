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

-- Note: btn, btnp, print, line, rect, rectfill, cls, spr, sfx, window
-- are all native Picotron functions and don't need to be redefined!
-- They work exactly like PICO-8 with the same parameters.
