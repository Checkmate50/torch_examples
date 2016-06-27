--Contents of mod.lua

--[[
local M = {}

local function sayMyName()
   print('Hrunkner')
end

function M.sayHello()
   print('Why hello there')
   sayMyName()
end

return M
]]

local mod = require('mod') --runs the file mod.lua and places its return value in mod

--mod.sayHello() -- why hello there \n Hrunkner
--mod.sayMyName() --errors out since sayMyName is local

--mod2.lua prints 'Hi!'
--local a = require('mod2')
--local b = require('mod2') --Hi! is only printed once since return values of modules are cached

--dofile('mod2.lua')
--dofile('mod2.lua') -- these print 'Hi!' twice since dofile avoids the cache

f = loadfile('mod2.lua') -- call f() to actually run the file
--f() -- Hi!

g = loadstring('print(343)')
--g() -- 343
