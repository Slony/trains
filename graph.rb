# An instance of class +Graph+ represents the railroad network as a directed
# graph and has three useful methods to solve the test problems.
class Graph
  
  # Array of known success conditions for routes counting procedure.
  CONDITION_KEYS = [
    :stops_less_than_or_equal_to,
    :stops_equal_to,
    :distance_less_than,
  ]
  
  # An array of nodes is available as read-only attribute (mainly for tests).
  attr_reader :nodes

  # A hash with edge lengths is available as read-only attribute (mainly for
  # tests).
  # 
  # Example:
  #   ab_weight = edge['A']['B'] # Returns length of edge from node A to node B.
  attr_reader :edge
  
  # Graph object is initialized with a string representation of a graph.
  # 
  # Parameters:
  # - +specification+ --- a string composed of edge specifications
  #   separated with commas and optional spaces. An edge specifiacation is a
  #   pair of capital latin letters (nodes) suffixed with an integer (weight of
  #   an edge).
  # 
  # Example:
  #   graph = Graph.new('AB1, BC2, CA3')
  def initialize(spec)
    validate_graph_spec spec
    @edge = {}
    @nodes = []
    spec.split(/,\s+/).each { |e|
      @edge[e[0]] ||= {}
      @edge[e[0]][e[1]] = e[2..-1].to_i
      @nodes << e[0] << e[1]
    }
    @nodes.uniq!.sort!
  end
  
  # This method calculates the length of a route specified as string.
  # 
  # Parameters:
  # - +specification+ --- string of sequential capital latin letters (nodes)
  #   separated with hyphens.
  # 
  # Returns calculated distance or string 'NO SUCH ROUTE' if specified route
  # does not exist.
  # 
  # Example:
  #   distance = graph.distance_of('A-B-C')
  def distance_of(specification)
    validate_route_spec specification

    route = specification.gsub('-', '')

    (0 .. (route.size - 2)).inject(0) do |sum, index|
      from, to = route[index], route[index + 1]
      return 'NO SUCH ROUTE'  if edge[from].nil? || edge[from][to].nil?
      sum + edge[from][to]
    end
  end
  
  # This method counts all the possible routes from start to finish that meet
  # specified condition.
  # 
  # Parameters:
  # - +start+ --- one-letter string specifying the start node
  # - +finish+ --- one-letter string specifying the finish node
  # - +condition+ --- single key-value pair specifying a condition that has to
  #   be met by a route to be counted
  # +condition+ key must be one of the self-explanatory symbols:
  # - +:stops_less_than_or_equal_to+
  # - +:stops_equal_to+
  # - +:distance_less_than+
  # To decide whether to take the route into account or not the distance of the
  # route or the number of stops it includes are compared with +condition+
  # value using comparision method specified with +condition+ key.
  # 
  # Note that the route can start and finish at the same node.
  # 
  # Returns the number of routes that match the specified parameters.
  # 
  # Examples:
  #   sle3 = graph.routes_count_for('C', 'C', stops_less_than_or_equal_to: 3)
  #   se4  = graph.routes_count_for('A', 'C', stops_equal_to: 4)
  #   dl30 = graph.routes_count_for('C', 'C', distance_less_than: 30)
  # 
  # In fact this method just validates it's input and invokes #routes_count
  # method with the start node, the finish node and a block appropriate to the
  # specified +condition+. See the description of #routes_count method.
  def routes_count_for(start, finish, condition = {})
    validate_start_and_finish_nodes(start, finish)
    validate_condition(condition)
    
    case condition.keys.first
    when :stops_less_than_or_equal_to
      max_stops = condition[:stops_less_than_or_equal_to]
      routes_count(start, finish) do |node, stops, distance|
        [ stops > max_stops, stops > 0 ]
      end
    when :stops_equal_to
      exact_stops = condition[:stops_equal_to]
      routes_count(start, finish) do |node, stops, distance|
        [ stops > exact_stops, stops == exact_stops ]
      end
    when :distance_less_than
      max_distance = condition[:distance_less_than]
      routes_count(start, finish) do |node, stops, distance|
        [ distance >= max_distance, stops > 0 ]
      end
    end
  end
  
  # This method uses slightly modified Dijkstra’s algorithm to calculate the
  # length of the shortest route (in terms of distance to travel) from the start
  # node to the finish node. See comments in the source code for details.
  # 
  # Parameters:
  # - +start+ --- one-letter string specifying the start node
  # - +finish+ --- one-letter string specifying the finish node
  # 
  # Returns the length of the shortest route (in terms of distance to travel)
  # from the start node to the finish node.
  # 
  # Example:
  #   min_length = graph.length_for('A', 'C')
  def length_for(start, finish)
    validate_start_and_finish_nodes(start, finish)

    # Hash to store the distances form the start node. Note that we do not set
    # zero distance for the start node itself for it will help us to cope with
    # the case when the route starts and finishes at the same node.
    distance_to = {}
    
    # Hash used to figure out if a node already visited or not.
    is_visited = {}
    
    # FIFO queue to enqueue nodes to be visited. We enqueue the start node for
    # the first iteration of the main loop.
    queue = [ start ]
    
    while queue.size > 0 do
      node = queue.shift
      
      # The search is over if we have reached the finish node and it's distance
      # from the start node already figured out. The second part of the 
      # condition below (i.e. !distance_to[node].nil?) has been introduced to
      # cope with the case when the route starts and finishes at the same node.
      # It's where this algorithm differs form the Dijkstra’s.
      break  if node == finish && !distance_to[node].nil?

      # Sort neighbours of the current node by their distance from the start
      # node in ascending order taking +nil+ as infinity. This will help us to
      # enqueue nodes to visit in appropriate order (it's a key point of the
      # Dijkstra’s algorithm).
      neighbours = edge[node].keys.sort do |v1, v2|
        if distance_to[v1].nil?
          1
        elsif distance_to[v2].nil?
          -1
        else
          distance_to[v1] <=> distance_to[v2]
        end
      end
      
      neighbours.each do |next_node|
        next  if is_visited[next_node]
        # And again we use some trick to cope with the routes that start and
        # finish at the same node --- do you remeber that the start node is 
        # marked as infinitely distant from the start of the route during the
        # first iteration?
        new_distance = (distance_to[node] || 0) + edge[node][next_node]
        if distance_to[next_node].nil? || distance_to[next_node] > new_distance
          distance_to[next_node] = new_distance
        end
        queue.push next_node
      end
      
      # And once again we don't want to mark the start node as visited during
      # the first itaration for we might return to it later.
      is_visited[node] = !distance_to[node].nil?
    end
    
    distance_to[finish]
  end
  
  private

  # This private method uses DFS to count all the routes from the start node to
  # the finish node using block to determine what routes are to be counted and
  # when to stop the search.
  # 
  # Parameters:
  # - +start+ --- one-letter string specifying the start node
  # - +finish+ --- one-letter string specifying the finish node
  # - block that takes three arguments --- the last node of the
  #   assessed route, the number of stops in the assessed route and the length
  #   of the assessed route --- and returns an array of two boolean values. The
  #   first element of returned array --- halt flag --- should be set to +true+
  #   if the assessed route does not meet the required conditions and there's
  #   no reason to proceed along with it. The second element of returned array
  #   --- increment flag --- should be set to +true+ if the assessed route meets
  #   the required conditions and can be counted given it's last node equals to
  #   the finish node. (Well, may be it's better to look at the source code in 
  #   order to get the idea.)
  # 
  # Returns the number of routes started and finished at the specified nodes
  # and selected with the help of supplied block.
  # 
  # In the example below we're counting all the routes from A to D that has no
  # more than 3 stops:
  #   routes_count('A', 'D') do |node, stops, distance|
  #     [ stops > 3, stops > 0 ]
  #   end
  def routes_count(start, finish, &assessor)
    # We're using an array as a LIFO queue to enqueue successive nodes of the
    # assessed routes along with the number of stops and distance from the
    # start node. For the sake of performance it's better to use queues instead
    # of recursive method calls.
    queue = [ [start, 0, 0 ] ]
    count = 0

    while queue.size > 0 do
      node, stops, distance = queue.pop
      halt, increment = yield(node, stops, distance)
      next  if halt
      count += 1  if node == finish && increment
      edge[node].each { |v, d| queue.push([v, stops + 1, distance + d]) }
    end
    
    count
  end
  
  # This private method validates the graph specification provided as a
  # parameter to Graph::new method. For the sake of simplicity we don't create
  # special classes for exceptions and use +RuntimeError+ with messages
  # explaining the error.
  def validate_graph_spec(spec)
    raise 'Graph should be inited with a string'  unless spec.is_a? String
    raise 'Graph should be inited with something like \'AB1, BC2, CA3\''  unless spec.match(/^([A-Z][A-Z]\d+,\s*)*[A-Z][A-Z]\d+$/)
    raise 'Graph should not contain self-looped nodes'  if spec.match(/([A-Z])\1/)
    raise 'Graph should not contain repeated edges'  if spec.match(/([A-Z][A-Z]).*?\1/)
  end
  
  # This private method validates the route specification provided as a
  # parameter to Graph#distance_of method. For the sake of simplicity we don't
  # create special classes for exceptions and use +RuntimeError+ with messages
  # explaining the error.
  def validate_route_spec(spec)
    raise 'Route should be specified with a string'  unless spec.is_a? String
    raise 'Route should be specified with something like \'A-B-C\''  unless spec.match(/^([A-Z]-)+[A-Z]$/)
    raise 'Non-existent nodes in route specification'  unless spec.split('-') - nodes == []
  end
  
  # This private method validates the route assessment condition provided as a
  # parameter to Graph#routes_count_for method. For the sake of simplicity we
  # don't create special classes for exceptions and use +RuntimeError+ with
  # messages explaining the error.
  def validate_condition(condition)
    raise 'Condition should be specified with a hash'  unless condition.is_a?(Hash)
    raise 'No condition specified'  if condition.size < 1 
    raise 'Too many conditions specified'  if condition.size > 1
    raise 'Unknown condition specified'  unless CONDITION_KEYS.include?(condition.keys.first)
  end

  # This private method checks if the start and the finish nodes provided as a
  # parameters to Graph#routes_count_for and Graph#length_for methods are
  # present in the graph. For the sake of simplicity we don't create special
  # classes for exceptions and use +RuntimeError+ with messages explaining the
  # error.
  def validate_start_and_finish_nodes(start, finish)
    raise 'Start node not found'  unless nodes.include?(start)
    raise 'Finish node not found'  unless nodes.include?(finish)
  end
end