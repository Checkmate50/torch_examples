require 'nn'
require 'optim'
require 'math'
require 'read_data'

function get_singlenn(inputs, outputs)
   local model = nn.Sequential()
   local HUs = 20
   model:add(nn.Linear(inputs, HUs))
   model:add(nn.Tanh())
   model:add(nn.Linear(HUs, outputs))
   return model
end

local inputs = 3
local mlp = get_singlenn(inputs, 1)
--Gets an array of the inputs and outputs
--Note that the inputs are size 3 arrays and the outputs are integers

--Start Training
local criterion = nn.MSECriterion()
local folder = "cftrains/"
local batchInputs, batchLabels = convert_to_tensors(get_batches(folder, inputs))
local batchCount = #batchLabels
if #batchLabels ~= #batchInputs then
   print("Error: the number of output values does not match the inputs")
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

-- Start Testing
folder = "cftests/"
local testInputs, testLabels = convert_to_tensors(get_batches(folder, inputs))
if #testLabels ~= #testInputs then
   print("Error: the number of output values does not match the inputs")
end
print("TESTING")
local total_diff = 0
for batch=1,#testLabels do
   local batch_diff = 0
   for test=1,(#testLabels[batch])[1] do
      local expected = testLabels[batch][test][1]
      local actual = mlp:forward(testInputs[batch][test])[1]
      local diff = math.abs(actual-expected)
      batch_diff = batch_diff + diff
   end
   total_diff = total_diff + batch_diff
   print("Total diff for batch " .. batch .. " = " .. batch_diff)
end

print("\nTotal diff for network = " .. total_diff)

torch.save("foo_net.th", mlp)

   
