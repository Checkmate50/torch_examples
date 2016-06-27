require 'nn'
require 'optim'
require 'math'

function get_singlenn(inputs, outputs)
   local model = nn.Sequential()
   local HUs = 20
   model:add(nn.Linear(inputs, HUs))
   model:add(nn.Tanh())
   model:add(nn.Linear(HUs, outputs))
   return model
end

local inputs = 2
local mlp = get_singlenn(inputs, 1)

--Start Training
local criterion = nn.MSECriterion()
local batchCount = 256
local batchSize = 128
local batchInputs = torch.Tensor(batchCount, batchSize, inputs)
local batchLabels = torch.DoubleTensor(batchCount, batchSize)

for i=1, batchCount do
   for j=1, batchSize do
      local input = torch.randn(inputs)*100-50
      local label = torch.sum(input)
      batchInputs[i][j]:copy(input)
      batchLabels[i][j] = label
   end
end

local params, gradParams = mlp:getParameters()
local optimState = {learningRate = .01}
local current_loss

for epoch=1,100 do
   for batch=1,batchCount do
      current_loss = 0
      local function feval(params)
	 gradParams:zero()

	 local outputs = mlp:forward(batchInputs[batch])
	 local loss = criterion:forward(outputs, batchLabels[batch])
	 local dloss_doutput = criterion:backward(outputs, batchLabels[batch])
	 mlp:backward(batchInputs[batch], dloss_doutput)

	 return loss, gradParams
      end

      _,fs = optim.sgd(feval, params, optimState)
      current_loss = current_loss + fs[1]
   end
   if epoch % 5 == 0 then
      print(current_loss)
   end
end

--Start Testing
print("\nBeginning Testing\n")
totalDiff = 0
testCount = 50
for i=1,testCount do
   x = torch.randn(2)*100-50
   print("Expected = " .. torch.sum(x))
   result = mlp:forward(x)[1]
   print("Actual = " .. result)
   diff = math.abs(result-torch.sum(x))
   print("Diff = " .. diff .. "\n")
   totalDiff = totalDiff + diff
end

print("\nAverage diff = " .. totalDiff/testCount)

torch.save("add_net.t7", mlp)
