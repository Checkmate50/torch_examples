require 'nngraph'

torch.manualSeed(7361)

--[[
local function get_network()
   -- it is common style to mark inputs with identity nodes for clarity.
   local input = nn.Identity()()

   -- each hidden layer is achieved by connecting the previous one
   -- here we define a single hidden layer network
   local h1 = nn.Tanh()(nn.Linear(20, 10)(input))
   local h2 = nn.Sigmoid()(h1)
   local output = nn.Linear(10, 1)(h2)

   -- the following function call inspects the local variables in this
   -- function and finds the nodes corresponding to local variables.
   nngraph.annotateNodes()
   return nn.gModule({input}, {output})
end

mlp = get_network()
x = torch.rand(20)
dx = torch.rand(1)
mlp:updateOutput(x)
mlp:updateGradInput(x, dx)
mlp:accGradParameters(x, dx)

-- draw graph (the forward graph, '.fg')
-- this will produce an SVG in the runtime directory
graph.dot(mlp.fg, 'MLP', 'MLP_Annotated')
]]

function get_rnn(input_size, rnn_size)

   -- there are n+1 inputs (hidden inputs on each layer and x)
   local input = nn.Identity()()
   local prev_h = nn.Identity()()

   -- RNN tick
   local i2h = nn.Linear(input_size, rnn_size)(input)
   local h2h = nn.Linear(rnn_size, rnn_size)(prev_h)
   local added_h = nn.CAddTable()({i2h, h2h})
   local next_h = nn.Tanh()(added_h)

   nngraph.annotateNodes()
   return nn.gModule({input, prev_h}, {next_h})
end

function get_rnn2(input_size, rnn_size)
   local input1 = nn.Identity()():annotate{graphAttributes = {style='filled', fillcolor='blue'}}
   local input2 = nn.Identity()():annotate{graphAttributes = {style='filled', fillcolor='blue'}}
   local prev_h = nn.Identity()():annotate{graphAttributes = {style='filled', fillcolor='blue'}}
   local rnn_net1 = get_rnn(128, 128)({input1, prev_h}):annotate{graphAttributes = {style='filled', fillcolor='yellow'}}
   local rnn_net2 = get_rnn(128, 128)({input2, rnn_net1}):annotate{graphAttributes = {style='filled', fillcolor='green'}}
   nngraph.annotateNodes()
   return nn.gModule({input1, input2, prev_h}, {rnn_net2})
end

local rnn_net3 = get_rnn2(128, 128)
graph.dot(rnn_net3.fg, 'rnn_net3', 'rnn_net2_pretty')
