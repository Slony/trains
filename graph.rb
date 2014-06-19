class Graph
  
  attr_reader :edge
  
  def initialize(graph)
    validate_graph_specification graph
    @edge = {}
    graph.split(/,\s+/).each { |e|
      @edge[e[0]] ||= {}
      @edge[e[0]][e[1]] = e[2..-1].to_i
    }
  end
  
  def distance_of(route)
    validate_route_specification route
    v = route.gsub('-', '')
    (0 .. (v.size - 2)).inject(0) do |sum, index|
      from, to = v[index], v[index + 1]
      return 'NO SUCH ROUTE'  if edge[from].nil? || edge[from][to].nil?
      sum + edge[from][to]
    end
  end
  
  def routes_count_for(start, finish, condition = {})
    if condition.keys.include?(:stops_lower_than_or_equal_to)
      max_stops = condition[:stops_lower_than_or_equal_to]
      routes_count(start) do |vertex, stops, distance|
        [ stops > max_stops, vertex == finish && stops > 0 ]
      end
    elsif condition.keys.include?(:stops_equal_to)
      exact_stops = condition[:stops_equal_to]
      routes_count(start) do |vertex, stops, distance|
        [ stops > exact_stops, vertex == finish && stops == exact_stops ]
      end
    elsif condition.keys.include?(:distance_less_than)
      max_distance = condition[:distance_less_than]
      routes_count(start) do |vertex, stops, distance|
        [ distance >= max_distance, vertex == finish && stops > 0 ]
      end
    else
      raise 'No valid condition specified for routes counting'
    end
  end
  
  def length_for(start, finish)
    distance_to = { start => nil }
    is_visited = {}
    
    queue = [ start ]
    
    while queue.size > 0 do
      vertex = queue.shift
      
      break  if vertex == finish && !distance_to[vertex].nil?

      neighbours = edge[vertex].keys.sort do |v1, v2|
        if distance_to[v1].nil?
          1
        elsif distance_to[v2].nil?
          -1
        else
          distance_to[v1] <=> distance_to[v2]
        end
      end
      
      neighbours.each do |next_vertex|
        next  if is_visited[next_vertex]
        new_distance = (distance_to[vertex] || 0) + edge[vertex][next_vertex]
        distance_to[next_vertex] = new_distance  if distance_to[next_vertex].nil? || distance_to[next_vertex] > new_distance
        queue.push next_vertex
      end

      is_visited[vertex] = !distance_to[vertex].nil?
    end
    
    distance_to[finish]
  end
  
  private

  def routes_count(start, &test)
    queue = [ [start, 0, 0 ] ]
    count = 0

    while queue.size > 0 do
      vertex, stops, distance = queue.pop
      halt, increment = yield(vertex, stops, distance)
      next  if halt
      count += 1  if increment
      edge[vertex].each { |v, d| queue.push([v, stops + 1, distance + d]) }
    end
    
    count
  end
  
  def validate_graph_specification(str)
    raise 'Graph should be inited with a string'  unless str.is_a? String
    raise 'Graph should be inited with something like \'AB1, BC2, CA3\''  unless str.match(/^([A-Z][A-Z]\d+,\s*)*[A-Z][A-Z]\d+$/)
    raise 'Graph should not contain self-looped vertices'  if str.match(/([A-Z])\1/)
    raise 'Graph should not contain repeated edges'  if str.match(/([A-Z][A-Z]).*?\1/)
  end
  
  def validate_route_specification(str)
    raise 'Route should be specified with a string'  unless str.is_a? String
    raise 'Route should be specified with something like \'A-B-C\''  unless str.match(/^([A-Z]-)+[A-Z]$/)
  end
end