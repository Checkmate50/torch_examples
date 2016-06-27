function fib(n)
   if n < 2 then return 1 end
   return fib(n-2)+fib(n-1)
end

--print(fib(5)) -- 8

function subber(x)
   return function (y) return x-y end
   --new function created when adder is called, remembers the value of x
end
a1 = subber(9) --returns a function which subtracts a new target from 9
a2 = subber(36)
--print(a1(16)) -- -7
--print(a2(64)) -- -28

x,y,z = 1,2,3,4 -- note that 4 gets thrown away (no error)
function bar(a, b, c)
   --print(a, b, c)
   return 4, 8, 15, 16, 23, 42
end
x,y = bar('zaphod') --prints zaphod\tnil\tnil when the above is uncommented
--print(x .. ' ' .. y) --prints 4 8

--The following two statements are equivalent (!)
function f(x) return x*x end
f = function (x) return x*x end
--print(f(5)) -- 25

--And these two functions are also equivalent
local function g(x) return math.sin(x) end
local g
g = function (x) return math.sin(x) end
--print(g(0)) -- 0

print "hello" --works
