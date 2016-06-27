require 'string'

function read_file(filepath)
   --[[
      Given a path to a tab-deliminated file 'filepath'
      Returns the data of 'filepath' converted into a table of numbers
      Note that the file cannot contain non-numeric values
   ]]
   local toReturn = {}
   for line in io.lines(filepath) do
      table.insert(toReturn, string.split(line, "\t"))
   end

   for i=1,#toReturn do
      for j=1,#toReturn[i] do
	toReturn[i][j] = tonumber(toReturn[i][j])
      end
   end

   return toReturn
end

function get_batch(filepath, inputCount)
   --[[
      Given a path to a tab-deliminated nn training file with numeric values
      Which contains a number of columns equal to inputCount + [the expected number of outputs]
      This function returns two values: the tables inputs and outputs
      Where inputs becomes a fileRowsxinputCount table
      And outputs becomes a fileRowsx(fileColumns-inputCount) table
   ]]
   local data = read_file(filepath)
   local inputs={}
   local outputs={}

   for i=1,#data do
      inputs[i] = {}
      outputs[i] = {}
      for j=1,#data[i] do
	 if j<=inputCount then
	    inputs[i][j]=data[i][j]
	 else
	    outputs[i][j-inputCount]=data[i][j]
	 end
      end
   end

   return inputs, outputs
end

function get_batches(folderpath, inputCount)
   --[[
      Given a path to a folder containing a collection of tab-deliminated nn training files
      Each of which contains a table of numeric values such that each table
      Has a number of columns equal to inputCount + [the expected number of outputs]
      This function returns an array of input and output tables
      Note that the files in the given folder must follow the following naming convention:
      folderpath#.txt, where # is an integer such that the first file has # = 1
   ]]
   local i = 1
   local toReturn = {}
   while true do --Only quit when we run out of files
      local s = folderpath .. i .. ".txt"
      if io.open(s) ~= nil then
	 toReturn[i] = {}
	 toReturn[i][1],toReturn[i][2] = get_batch(s, inputCount)
      else
	 return toReturn
      end
      i = i + 1
   end
   
end

function convert_to_tensors(batches)
   --[[
      Given a set of n batches of size s with i inputs and o outputs
      Returns two tables of length n
      Where the first table represents inputs with Tensors of size sxi
      And the second table represents outputs with Tensors of size sxo
   ]]
   local inputs = {}
   local outputs = {}

   for i=1,#batches do
      inputs[i]=torch.Tensor(batches[i][1])
      outputs[i]=torch.Tensor(batches[i][2])
   end
   return inputs, outputs
   
end

function get_batch_tensors(folderpath, inputCount)
   return convert_to_tensors(get_batches(folderpath, inputCount))
end
