require 'nn'
require 'optim'

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
local batchSize = 128
local batchInputs = torch.Tensor(batchSize, inputs)
local batchLabels = torch.DoubleTensor(batchSize)

for i=1,batchSize do
  local input = torch.randn(2)     -- normally distributed example in 2d
  local label = 1
  if input[1]*input[2]>0 then     -- calculate label for XOR function
    label = -1;
  end
  batchInputs[i]:copy(input)
  batchLabels[i] = label
end

local params, gradParams = mlp:getParameters()
local optimState = {learningRate = .01}
local current_loss

for epoch=1,50 do
   for i=1,50 do
      current_loss = 0
      -- local function we give to optim
      -- it takes current weights as input, and outputs the loss
      -- and the gradient of the loss with respect to the weights
      -- gradParams is calculated implicitly by calling 'backward',
      -- because the model's weight and bias gradient tensors
      -- are simply views onto gradParams
      local function feval(params)
	 gradParams:zero()

	 local outputs = mlp:forward(batchInputs)
	 local loss = criterion:forward(outputs, batchLabels)
	 local dloss_doutput = criterion:backward(outputs, batchLabels)
	 mlp:backward(batchInputs, dloss_doutput)

	 return loss,gradParams
      end
      _,fs = optim.sgd(feval, params, optimState)
      current_loss = current_loss + fs[1]
   end
   print(current_loss / batchSize)
end

--Start Testing

local x = torch.Tensor(2)
x[1] = .5; x[2] = .5; print(mlp:forward(x))
x[1] = .5; x[2] = -.5; print(mlp:forward(x))
x[1] = -.5; x[2] = .5; print(mlp:forward(x))
x[1] = -.5; x[2] = -.5; print(mlp:forward(x))

