--[[
   It's a multi-line comment!
   (Note the brackets)
--]]

num = 42 --all numbers are doubles

s = 'walternate'
t = "double-quotes are fine"
u = [[ you can do
    multi-line strings?!?]]
t = nil --destroys t, frees for garbage collection

while num < 50 do
   num = num + 1 --no ++ or += ...
end

if num > 40 then
   print('40!')
elseif s ~= 'walternate' then -- ~= is !=
   io.write('no call for you')
else
   varsAreGlobal = 5
   local line = io.read() --reads next stdin line

   print("Winter is coming, " .. line) -- .. operator gives string concatenation
end

foo = anUnknownVariable -- sets foo to nil, since all undefined variables return nil

aBoolValue = false
if not aBoolValue then print('twas false') end
ans = aBoolValue and 'yes' or 'no' --'no'

karlSum = 0
for i = 1, 100 do -- 1 and 100 are included
   karlSum = karlSum + i
end
--print(karlSum) --5050

fredSum = 0
for j = 100, 1, -1 do
   fredSum = fredSum + j
end
--print(fredSum) --5050, since range is begin, end[, step]

repeat
   --print('the way of the future') --prints 'num' times
   num = num -1
until num == 0

