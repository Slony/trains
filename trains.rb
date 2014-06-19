#!/env/ruby

require_relative 'graph'

graph = Graph.new('AB5, BC4, CD8, DC8, DE6, AD5, CE2, EB3, AE7')

tests = {
  'The distance of the route A-B-C'     => graph.distance_of('A-B-C'),
  'The distance of the route A-D'       => graph.distance_of('A-D'),
  'The distance of the route A-D-C'     => graph.distance_of('A-D-C'),
  'The distance of the route A-E-B-C-D' => graph.distance_of('A-E-B-C-D'),
  'The distance of the route A-E-D'     => graph.distance_of('A-E-D'),
  'The number of trips starting at C and ending at C with a maximum of 3 stops'   => graph.routes_count_for('C', 'C', stops_less_than_or_equal_to: 3),
  'The number of trips starting at A and ending at C with exactly 4 stops'        => graph.routes_count_for('A', 'C', stops_equal_to: 4),
  'The length of the shortest route (in terms of distance to travel) from A to C' => graph.length_for('A', 'C'),
  'The length of the shortest route (in terms of distance to travel) from B to B' => graph.length_for('B', 'B'),
  'The number of different routes from C to C with a distance of less than 30'    => graph.routes_count_for('C', 'C', distance_less_than: 30),
}

tests.each.with_index do |(problem, solution), index|
  puts "#{index + 1}. #{problem}: #{solution}"
end