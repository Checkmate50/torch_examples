require 'nn'
require 'paths'

torch.manualSeed(4312) --Conserve random seed

net = nn.Sequential()

net:add(nn.SpatialConvolution(1, 6, 5, 5)) -- 1 input image channel, 6 output channels, 5x5 convolution kernel
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.SpatialMaxPooling(2,2,2,2))     -- A max-pooling operation that looks at 2x2 windows and finds the max.
net:add(nn.SpatialConvolution(6, 16, 5, 5))
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.SpatialMaxPooling(2,2,2,2))
net:add(nn.View(16*5*5))                    -- reshapes from a 3D tensor of 16x5x5 into 1D tensor of 16*5*5
net:add(nn.Linear(16*5*5, 120))             -- fully connected layer (matrix multiplication between input and weights)
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.Linear(120, 84))
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.Linear(84, 10))                   -- 10 is the number of outputs of the network (in this case, 10 digits)
net:add(nn.LogSoftMax())                     -- converts the output to a log-probability. Useful for classification problems

--print('Lenet5\n' .. net:__tostring())

input = torch.rand(1, 32, 32)
output = net:forward(input)
--print(output)

criterion = nn.ClassNLLCriterion() -- a negative log-likelihood criterion for multi-class classification
criterion:forward(output, 3) -- let's say the groundtruth was class number: 3
gradients = criterion:backward(output, 3)

net:zeroGradParameters()
gradInput = net:backward(input, torch.rand(10))
--print(#gradInput)

m = nn.SpatialConvolution(1,3,2,2) -- learn 3 2x2 kernels
--print(m.weight) -- initially, the weights are randomly initialized
--print(m.bias) -- The operation in a convolution layer is: output = convolution(input,weight) + bias

if (not paths.filep("cifar10torchsmall.zip")) then
    os.execute('wget -c https://s3.amazonaws.com/torch7/data/cifar10torchsmall.zip')
    os.execute('unzip cifar10torchsmall.zip')
end
trainset = torch.load('cifar10-train.t7')
testset = torch.load('cifar10-test.t7')
classes = {'airplane', 'automobile', 'bird', 'cat',
           'deer', 'dog', 'frog', 'horse', 'ship', 'truck'}

--print(trainset)
--print(#trainset.data)

setmetatable(trainset,
	     {__index = function(t, i)
		 return {t.data[i], t.label[i]}
	     end}
);

trainset.data = trainset.data:double()

function trainset:size()
   return self.data:size(1)
end

--print(trainset:size())

--print(trainset[33])

redChannel = trainset.data[{ {}, {1}, {}, {} }] -- this picks {all images, 1st channel, all vertical pixels, all horizontal pixels}

--print(#redChannel)

--smallSet = trainset.data[{ {150, 300}, {1}, {}, {} }]
--print(#smallSet)

mean = {}
stdv = {}
for i=1,3 do
   mean[i] = trainset.data[{ {}, {i}, {}, {}  }]:mean() -- mean estimation
   print('Channel ' .. i .. ', Mean: ' .. mean[i])
   trainset.data[{ {}, {i}, {}, {}  }]:add(-mean[i]) -- mean subtraction, send to 0
   
   stdv[i] = trainset.data[{ {}, {i}, {}, {}  }]:std() -- std estimation
   print('Channel ' .. i .. ', Standard Deviation: ' .. stdv[i])
   trainset.data[{ {}, {i}, {}, {}  }]:div(stdv[i]) -- std scaling, send to 1
end

--Resetting the net
net = nn.Sequential()

net:add(nn.SpatialConvolution(3, 6, 5, 5)) -- 3 input image channel, 6 output channels, 5x5 convolution kernel
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.SpatialMaxPooling(2,2,2,2))     -- A max-pooling operation that looks at 2x2 windows and finds the max.
net:add(nn.SpatialConvolution(6, 16, 5, 5))
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.SpatialMaxPooling(2,2,2,2))
net:add(nn.View(16*5*5))                    -- reshapes from a 3D tensor of 16x5x5 into 1D tensor of 16*5*5
net:add(nn.Linear(16*5*5, 120))             -- fully connected layer (matrix multiplication between input and weights)
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.Linear(120, 84))
net:add(nn.ReLU())                       -- non-linearity 
net:add(nn.Linear(84, 10))                   -- 10 is the number of outputs of the network (in this case, 10 digits)
net:add(nn.LogSoftMax())                     -- converts the output to a log-probability. Useful for classification problems

criterion = nn.ClassNLLCriterion() --log-likelihood clasisfication loss

trainer = nn.StochasticGradient(net, criterion)
trainer.learningRate = .001
trainer.maxIteration = 5

trainer:train(trainset)

testset.data = testset.data:double()
for i=1,3 do
   testset.data[{ {}, {i}, {}, {}  }]:add(-mean[i])
   testset.data[{ {}, {i}, {}, {}  }]:div(stdv[i])
end

horse = testset.data[100]
--print(horse:mean(), horse:std())

--print(classes[testset.label[100]])
predicted = net:forward(testset.data[100])
--print(predicted:exp())

--[[
for i = 1,predicted:size(1) do
   print(classes[i], predicted[i])
end
]]

correct = 0
class_performance = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
for i =1,10000 do
   local groundtruth = testset.label[i]
   local prediction = net:forward(testset.data[i])
   local confidences, indices = torch.sort(prediction, true) --sort in descending order
   if groundtruth == indices[1] then
      correct = correct + 1
      class_performance[groundtruth] = class_performance[groundtruth] + 1
   end
end

print(correct, 100*correct/10000 .. ' % ')
for i = 1,#classes do
   print(classes[i], 100*class_performance[i]/1000 .. '%')
end


