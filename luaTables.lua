t = {key1 = 'value1', key2 = false}

--print(t.key1) --value1
t.newKey = {}
t.key2 = nil
--print(t) --key1 = value1\nnewKey = {...}

u = {["@!#"] = 'qbert', [{}] = 1729, [6.28] = 'tau'} --[{}] = 1729; wtf???
--print(u[6.28]) --prints "tau"
--So basically each table is a hash table with arbitrarily typed keys
--print(u) --just look at the output yourself :P

a = u['@!#'] -- a = 'qbert'
b = u[{}] -- b = nil since we just created a new table I guess
--a = 57 --does not modify u

function h(x) print(x.key1) end
--print(h{key1 = 'Sonmi~451'}) -- Sonmi~451.  Note the lack of parens around the table
--print(h(t)) -- value1

for key, val in pairs(u) do
   --print (key, val) --prints the contents of u
end

--print(_G['_G'] == _G) --prints true
--print(_G) --prints every global lua variable at the time of calling

v = {'value1', 'value2', 1.21, 'gigawatts'}
for i = 1, #v do
   --print(v[i]) -- indices start at 1.  Everything is awful
end


----------------------------
-- Metatables
----------------------------

f1 = {a = 1, b = 2} --Using to represent the fraction a/b = 1/2
f2 = {a = 2, b = 3} --2/3

metafraction = {}
function metafraction.__add(f1, f2)
   sum = {}
   sum.b = f1.b * f2.b
   sum.a = f1.a * f2.b + f2.a * f1.b
   return sum
end

setmetatable(f1, metafraction)
setmetatable(f2, metafraction)

s = f1 + f2
--print(s) -- a = 7, b = 6
--t = s + s -- fails since s is not a metatable

defaultFavs = {animal = 'gru', food = 'donuts'}
myFavs = {food = 'pizza'}
setmetatable(myFavs, {__index = defaultFavs})
--print(myFavs.animal, myFavs.food) -- gru  pizza since __index overloads dot lookups

--A fancy full table
-- __add(a, b)                     for a + b
-- __sub(a, b)                     for a - b
-- __mul(a, b)                     for a * b
-- __div(a, b)                     for a / b
-- __mod(a, b)                     for a % b
-- __pow(a, b)                     for a ^ b
-- __unm(a)                        for -a
-- __concat(a, b)                  for a .. b
-- __len(a)                        for #a
-- __eq(a, b)                      for a == b
-- __lt(a, b)                      for a < b
-- __le(a, b)                      for a <= b
-- __index(a, b)  <fn or a table>  for a.b
-- __newindex(a, b, c)             for a.b = c
-- __call(a, ...)                  for a(...)

----------------------------
-- Class-like tables and inheritence
----------------------------

Dog = {}  --we gon' make dog a class!

function Dog:new()
   newObj = {sound = 'woof'} --the newObj will be an instance of Dog
   self.__index = self --self = Dog here
   return setmetatable(newObj, self)
end

function Dog:makeSound()
   print('I say ' .. self.sound)
end

mrDog = Dog:new()
--mrDog:makeSound() -- I say woof
--mrDog.makeSound(mrDog) -- also gives 'I say woof'


LoudDog = Dog:new()

function LoudDog:makeSound() --overrides the above function for this child (and notates it as a child!)
   s = self.sound .. ' ' --inherit sound from above
   print(s .. s .. s)
end

seymour = LoudDog:new()
--seymour:makeSound() -- 'woof woof woof'

function LoudDog:new() -- This kind of thing may be needed to finish creating a child
   newObj = {}
   self.__index = self
   return setmetatable(newObj, self)
end
