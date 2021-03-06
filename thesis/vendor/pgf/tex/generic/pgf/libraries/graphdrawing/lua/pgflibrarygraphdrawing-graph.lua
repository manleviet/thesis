-- Copyright 2010 by Renée Ahrens, Olof Frahm, Jens Kluttig, Matthias Schulz, Stephan Schuster
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot-fuse/pgf/pgf/generic/pgf/libraries/graphdrawing/lua/pgflibrarygraphdrawing-graph.lua,v 1.2 2011/04/20 17:50:27 matthiasschulz Exp $

-- This file defines a graph class, which later represents user created
-- graphs.

pgf.module("pgf.graphdrawing")

Graph = Box:new()
Graph.__index = Graph

--- Creates a new graph.
-- @param values Values (e.g. options) to be merged with the default-metatable of a graph
-- @return The new graph.
function Graph:new(values)
   local defaults = {
      nodes = {},
      edges = {},
      pos = Position:new(),
      options = {},
      -- root = nil,
   }
   setmetatable(defaults, Graph)
   local result = mergeTable(values, defaults)
   return result
end

--- Sets the option name to value.
-- @param name Name of the option to be set.
-- @param value Value for the option defined by name.
function Graph:setOption(name, value)
   self.options[name] = value
end

--- Returns the value of the option defined by name.
-- @param name Name of the option.
-- @return The stored value of the option or nil.
function Graph:getOption(name)
   return self.options[name]
end

--- Merges the given options into options of the graph.
-- @param options The options to be merged.
-- @see mergeTable
function Graph:mergeOptions(options)
   self.options = mergeTable(options, self.options)
end

--- Creates a shallow copy of a graph.
-- That is, without nodes or edges.
-- @return A copy of the graph.
function Graph:copy ()
   local result = copyTable(self, Graph:new())
   result.nodes = {}
   result.edges = {}
   result.root = nil
   return result
end

--- Adds a node to the graph.
-- @param node The node to be added.
function Graph:addNode(node)
   if not findTable(self.nodes, node) then
      table.insert(self.nodes, node)
      if(node.tex.maxY and node.tex.maxX and node.tex.minY and node.tex.minX) then
         node.height = string.sub(node.tex.maxY,0,string.len(node.tex.maxY)-2) - 
            string.sub(node.tex.minY,0,string.len(node.tex.minY)-2)
         node.width = string.sub(node.tex.maxX,0,string.len(node.tex.maxX)-2) - 
            string.sub(node.tex.minX,0,string.len(node.tex.minX)-2)
      end
      assert(node.height >= 0)
      assert(node.width >= 0)
   end
end

--- Removes a node from the graph, if possible and returns it.
-- @param node The node to remove.
-- @return The node or nil if it wasn't contained in the graph.
function Graph:removeNode(node)
   local index = findTable(self.nodes, node)
   if index then
      table.remove(self.nodes, index)
      return node
   else
      return nil
   end
end

--- Searches the nodes of the graph by the given name.
-- @param name Name of the node you're looking for.
-- @return The node with the given name or nil if it wasn't contained in the graph.
function Graph:findNode(name)
   return self:findNodeIf(function (node) return node.name == name end)
end

--- Searches the nodes of the graph by the given test-function and returns the first matching node.
-- @param test A function (with a parameter of node) returning a boolean value.
-- @return The matching node or nil.
function Graph:findNodeIf(test)
   for node in values(self.nodes) do
      if test(node) then
	 return node
      end
   end
   return nil
end

--- Like removeNode, but also removes all edges incident to the removed node
-- and for all nodes incident to the removed edges, remove the edges from them,
-- too.
-- @param node The node to be deleted with its edges.
-- @return The node or nil if the node wasn't contained in the graph.
function Graph:deleteNode(node)
   local node = self:removeNode(node)
   if node then
      for edge in values(node:getEdges()) do
	 self:removeEdge(edge)
	 for node in values(edge:getNodes()) do
	    node.removeEdge(edge)
	 end
      end
      node.edges = {}
   end
   return node
end

--- Adds an edge to the graph.
-- @param edge The edge to be added.
function Graph:addEdge(edge)
   if not findTable(self.edges, edge) then
      table.insert(self.edges, edge)
   end
end

--- Removes an edge from the graph, if possible and returns it.
-- @param edge The edge to be removed.
-- @return The edge or nil.
function Graph:removeEdge(edge)
   local index = findTable(self.edges, edge)
   if index then
      table.remove(self.edges, edge)
      return edge
   else
      return nil
   end
end

--- Like removeEdge, but also removes the edge from the nodes incident
-- with it.
-- @param edge The edge to be removed.
-- @return The edge or nil.
function Graph:deleteEdge(edge)
   local edge = self:removeEdge(edge)
   if edge then
      for node in edge:getNodes() do
	 node.removeEdge(edge)
      end
   end
   return edge
end

--- Creates and adds a new edge to the graph. 
-- The edge contains the given nodes and its direction and options are set to the param direction/option.
-- @param nodeA The first node of the new edge.
-- @param nodeB The second node of the new edge.
-- @param direction The direction of the new edge.
-- @param options The options of the new edge.
-- @return The newly created edge.
function Graph:createEdge(nodeA, nodeB, direction, options)
   local edge = Edge:new{direction = direction, options = options}
   edge:addNode(nodeA)
   edge:addNode(nodeB)
   self:addEdge(edge)
   return edge
end

--- Auxiliary function to walk a graph. Does nothing if no nodes exist.
-- @param root The first node to be visited.  If nil, chooses some node.
-- @param visited Set of already seen things (nodes and edges).
-- |visited[v] == true| indicates that the object v was already seen.
-- @param removeIndex Is either nil or a numeric value where the objects are
-- removed from the local queues (nil therefore designates queue behaviour,
-- 1 a stack behaviour).
-- @see walkDepth, walkBreadth
function Graph:walkAux(root, visited, removeIndex)
   root = root or self.nodes[1]
   if not root then return end

   visited = visited or {}
   visited[root] = true
   local nodeQueue = {root}
   local edgeQueue = {}
   local function insertVisited(queue, object)
      if not visited[object] then
	 table.insert(queue, 1, object)
	 visited[object] = true
      end
   end
   local function remove(queue)
      return table.remove(queue, removeIndex or #queue)
   end
   return
   function ()
      while #edgeQueue > 0 do
	 local currentEdge = remove(edgeQueue)
	 for node in values(currentEdge:getNodes()) do
	    insertVisited(nodeQueue, node)
	 end
	 return currentEdge
      end
      while #nodeQueue > 0 do
	 local currentNode = remove(nodeQueue)
	 for edge in values(currentNode:getEdges()) do
	    insertVisited(edgeQueue, edge)
	 end
	 return currentNode
       end
      return nil
   end
end

--- The function returns an iterator to walk the graph depth-first.
-- The iterator then returns all edges and nodes one at a time and once
-- only.  Use a filter function to return only edges or nodes.
-- @see iterator.filter
function Graph:walkDepth(root, visited)
   return self:walkAux(root, visited, 1)
end

--- The function returns an iterator to walk the graph breadth-first.
-- The iterator then returns all edges and nodes one at a time and once
-- only.  Use a filter function to return only edges or nodes.
-- @see iterator.filter
function Graph:walkBreadth(root, visited)
   return self:walkAux(root, visited)
end

--- The function returns a new subgraph.
-- The result graph begins at the node root, excludes all nodes and edges
-- which are marked as visited.
-- @param root Root node where operation starts.
-- @param graph Result graph object or nil.
-- @param visited Set of already visited nodes/edges or nil; will be
-- modified.
function Graph:subGraph(root, graph, visited)
   graph = graph or self:copy()
   visited = visited or {}

   -- translates old things to new things
   local translate = {}
   local nodes, edges = {}, {}
   for v in self:walkDepth(root, visited) do
      if v.__index == Node then
	 table.insert(nodes, v)
      elseif v.__index == Edge then
	 table.insert(edges, v)
      end
   end

   -- create new nodes (without edges)
   for node in values(nodes) do
      local copy = node:copy()
      graph:addNode(copy)
      assert(copy)
      translate[node] = copy
      graph.root = graph.root or copy
   end

   -- create new edges and adds them to graph and nodes
   for edge in values(edges) do
      local copy = edge:copy()
      local canAdd = true
      for v in values(edge:getNodes()) do
	 local translated = translate[v]
	 if not translated then
	    canAdd = false
	 end
      end
      if canAdd then
	 for v in values(edge:getNodes()) do
	    local translated = translate[v]
	    copy:addNode(translated)
	 end
	 for node in values(copy:getNodes()) do
	    node:addEdge(copy)
	 end
	 graph:addEdge(copy)
      end
   end

   return graph
end

--- Creates a new subgraph with the parent marked visited. Useful if the
-- graph is a tree structure (and parent is the parent of root).
-- @param parent Parent of the recursion step before.
-- @see subGraph
function Graph:subGraphParent(root, parent, graph)
   local visited = {}
   visited[parent] = true

   -- mark edges with root and parent as visited
   for edge in values(root:getEdges()) do
      if edge:containsNode(root) and edge:containsNode(parent) then
	 visited[edge] = true
      end
   end
   return self:subGraph(root, graph, visited)
end

--- Returns a string representation of this graph including all nodes and edges.
-- @return Graph as string.
-- @ignore This should not appear in the documentation.
function Graph:__tostring()
   local tmp = Graph.__tostring
   Graph.__tostring = nil
   local result = "Graph<" .. tostring(self) .. ">(("
   Graph.__tostring = tmp

   local first = true
   for node in values(self.nodes) do
      if first then first = false else result = result .. ", " end
      result = result .. tostring(node)
   end
   result = result .. "), ("
   first = true
   for edge in values(self.edges) do
      if first then first = false else result = result .. ", " end
      result = result .. tostring(edge)
   end

   return result .. "))"
end
