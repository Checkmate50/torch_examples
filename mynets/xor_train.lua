require 'nn'

mlp = nn.Sequential()
inputs = 2; outputs = 1; HUs = 20;
mlp:add(nn.Linear(inputs, HUs))
mlp:add(nn.Tanh())
mlp:add(nn.Linear(HUs, outputs))

criterion = nn.MSECriterion()

for i = 1,2500 do
   local input = torch.randn(2)
   local output = torch.Tensor(1)
   if input[1]*input[2] > 0 then
      output[1] = -1
   else
      output[1] = 1
   end

   criterion:forward(mlp:forward(input), output)

   --zero the accumulation of the gradients
   mlp:zeroGradParameters()
   -- accumulate gradients
   mlp:backward(input, criterion:backward(mlp.output, output))
   -- update with .01 learning rate
   mlp:updateParameters(.01)
end

local x = torch.Tensor(2)
x[1] = .5; x[2] = .5; print(mlp:forward(x))
x[1] = .5; x[2] = -.5; print(mlp:forward(x))
x[1] = -.5; x[2] = .5; print(mlp:forward(x))
x[1] = -.5; x[2] = -.5; print(mlp:forward(x))
