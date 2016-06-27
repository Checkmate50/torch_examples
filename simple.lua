torch.manualSeed(1234)

function J(x)
   return 0.5*x:dot(A*x)-b:dot(x)
end

function min()
   return J(torch.inverse(A)*b)
end

function dJ(x)
   return A*x-b
end

local neval = 0
local evaluations = {}
local time = {}
local timer = torch.Timer()
function JdJ(x)
   local Jx = J(x)
   neval = neval + 1
   print(string.format('after %d evaluations J(x) = %f', neval, Jx))
   table.insert(evaluations, Jx)
   table.insert(time, timer:time().real)
   return Jx, dJ(x)
end

local N = 2
A = torch.rand(N, N)
print("initial: ");print(A)
A = A*A:t()
print(A)
A:add(0.001, torch.eye(N))
print(A)
b = torch.rand(N)
print(J(torch.rand(N)))

print(string.format('J(x^*) = %g', min()))

local x = torch.rand(N)

--[[
lr = .01
for i=1,20000 do
   x = x - dJ(x)*lr
   print(string.format('at iter %d J(x) = %f', i, J(x)))
   end
]]

do
   local A = torch.rand(N, N)
   print(A)
end
print(A) --prints the A defined above

require 'optim'

state = {
   verbose = true,
   maxIter = 100
}

x0 = torch.rand(N)
cgx = x0:clone() -- make a copy of x0
timer:reset()
optim.cg(JdJ, cgx, state)

-- we convert the evaluations and time tables to tensors for plotting:
cgtime = torch.Tensor(time)
cgevaluations = torch.Tensor(evaluations)

evaluations = {}
time = {}
neval = 0
state = {
  lr = 0.1
}

-- we start from the same starting point than for CG
x = x0:clone()

-- reset the timer!
timer:reset()

-- note that SGD optimizer requires us to do the loop
for i=1,1000 do
  optim.sgd(JdJ, x, state)
  table.insert(evaluations, Jx)
end

sgdtime = torch.Tensor(time)
sgdevaluations = torch.Tensor(evaluations)

require 'gnuplot'

--[[
gnuplot.figure(1)
gnuplot.title('CG loss minimisation over time')
gnuplot.plot(cgtime, cgevaluations)

gnuplot.figure(2)
gnuplot.title('SGD loss minimisation over time')
gnuplot.plot(sgdtime, sgdevaluations)
]]

gnuplot.pngfigure('plot.png')
gnuplot.plot(
   {'CG',  cgtime,  cgevaluations,  '-'},
   {'SGD', sgdtime, sgdevaluations, '-'})
gnuplot.xlabel('time (s)')
gnuplot.ylabel('J(x)')
gnuplot.plotflush()
