require_relative '../../trains/graph'

describe Trains::Graph do

  before :each do
    @test_input = 'AB5, BC4, CD8, DC8, DE6, AD5, CE2, EB3, AE7'
  end

  describe '#new supplied with' do
    context 'a valid route specification' do
      it 'throws no exceptions' do
        expect { Trains::Graph.new @test_input }.to_not raise_error
      end
      
      it 'constructs appropriate edges hash' do
        graph = Trains::Graph.new @test_input
        expect(graph.edge).to eq({
          'A' => { 'B' => 5, 'D' => 5, 'E' => 7 },
          'B' => { 'C' => 4 },
          'C' => { 'D' => 8, 'E' => 2 },
          'D' => { 'C' => 8, 'E' => 6 },
          'E' => { 'B' => 3  },
        })
      end

      it 'constructs sorted nodes array' do
        graph = Trains::Graph.new @test_input
        expect(graph.nodes).to eq(%w[A B C D E])
      end
    end
  
    context 'not a string' do
      it 'throws exception with error message "Graph should be inited with a string"' do
        expect { Trains::Graph.new :foo }.to raise_error.with_message('Graph should be inited with a string')
      end
    end

    context 'malformed route specification' do
      it 'throws exception with error message "Graph should be inited with something like \'AB1, BC2, CA3\'"' do
        expect { Trains::Graph.new 'blah-blah-blah' }.to raise_error.with_message('Graph should be inited with something like \'AB1, BC2, CA3\'')
      end
    end
    
    context 'route specification with self-looped nodes' do
      it 'throws exception with error message "Graph should not contain self-looped nodes"' do
        expect { Trains::Graph.new 'AB5, BB1' }.to raise_error.with_message('Graph should not contain self-looped nodes')
      end
    end

    context 'route specification with repeated edges' do
      it 'throws exception with error message "Graph should not contain repeated edges"' do
        expect { Trains::Graph.new 'AB5, AB7' }.to raise_error.with_message('Graph should not contain repeated edges')
      end
    end
  end
  
  describe '#distance_of supplied with' do
    before :each do
      @graph = Trains::Graph.new(@test_input)
    end
    
    context 'valid route specification' do
      it 'returns the distance of the route if it exists' do
        expect(@graph.distance_of('A-B-C')).to eq(9)
      end

      it 'return string "NO SUCH ROUTE" if the route does not exist' do
        expect(@graph.distance_of('A-E-D')).to eq('NO SUCH ROUTE')
      end
    end

    context 'not a string' do
      it 'throws exception with error message "Route should be specified with a string"' do
        expect { @graph.distance_of(:foo) }.to raise_error.with_message('Route should be specified with a string')
      end
    end

    context 'invalid route specification' do
      it 'throws exception with error message "Route should be specified with something like \'A-B-C\'"' do
        expect { @graph.distance_of('foo-bar') }.to raise_error.with_message('Route should be specified with something like \'A-B-C\'')
      end
    end

    context 'route specification with non-existent nodes' do
      it 'throws exception with error message "Non-existent nodes in route specification"' do
        expect { @graph.distance_of('A-B-X-C') }.to raise_error.with_message('Non-existent nodes in route specification')
      end
    end
  end
  
  describe '#routes_count_for supplied with' do
    before :each do
      @graph = Trains::Graph.new(@test_input)
    end
    
    context 'valid start and finish nodes and maximum stops count' do
      it 'returns routes count' do
        expect(@graph.routes_count_for('C', 'C', stops_less_than_or_equal_to: 3)).to eq(2)
      end
    end

    context 'valid start and finish nodes and exact stops count' do
      it 'returns routes count' do
        expect(@graph.routes_count_for('A', 'C', stops_equal_to: 4)).to eq(3)
      end
    end

    context 'valid start and finish modes and threshold distance' do
      it 'returns routes count' do
        expect(@graph.routes_count_for('C', 'C', distance_less_than: 30)).to eq(7)
      end
    end

    context 'non-existent start node' do
      it 'throws exception with error message "Start node not found"' do
        expect { @graph.routes_count_for('X', 'B', stops_equal_to: 4) }.to raise_error.with_message('Start node not found')
      end
    end

    context 'non-existent finish node' do
      it 'throws exception with error message "Finish node not found"' do
        expect { @graph.routes_count_for('A', 'X', stops_equal_to: 4) }.to raise_error.with_message('Finish node not found')
      end
    end

    context 'condition as not a hash' do
      it 'throws exception with error message "Condition should be specified with a hash"' do
        expect { @graph.routes_count_for('A', 'B', :foo) }.to raise_error.with_message('Condition should be specified with a hash')
      end
    end

    context 'no condition' do
      it 'throws exception with error message "No condition specified"' do
        expect { @graph.routes_count_for('A', 'B') }.to raise_error.with_message('No condition specified')
      end
    end

    context 'too many conditions' do
      it 'throws exception with error message "Too many conditions specified"' do
        expect { @graph.routes_count_for('A', 'B', distance_less_than: 30, stops_equal_to: 4) }.to raise_error.with_message('Too many conditions specified')
      end
    end

    context 'unknown condition' do
      it 'throws exception with error message "Unknown condition specified"' do
        expect { @graph.routes_count_for('A', 'B', stops_greater_than: 4) }.to raise_error.with_message('Unknown condition specified')
      end
    end
  end
  
  describe '#length_for supplied with' do
    before :each do
      @graph = Trains::Graph.new(@test_input)
    end
    
    context 'valid start and finish nodes' do
      it 'returns minimal length of route from start to finish' do
        expect(@graph.length_for('A', 'C')).to eq(9)
      end
    end

    context 'non-existent start node' do
      it 'throws exception with error message "Start node not found"' do
        expect { @graph.length_for('X', 'B') }.to raise_error.with_message('Start node not found')
      end
    end

    context 'non-existent finish node' do
      it 'throws exception with error message "Finish node not found"' do
        expect { @graph.length_for('A', 'X') }.to raise_error.with_message('Finish node not found')
      end
    end
  end
end