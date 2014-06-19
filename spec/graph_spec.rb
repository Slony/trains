require_relative '../graph'

describe Graph do

  before :each do
    @test_input = 'AB5, BC4, CD8, DC8, DE6, AD5, CE2, EB3, AE7'
  end

  describe '#new supplied with' do
    context 'a valid string' do
      it 'throws no exceptions' do
        expect { Graph.new @test_input }.to_not raise_error
      end
      
      it 'constructs appropriate edges matrix' do
        graph = Graph.new @test_input
        expect(graph.edge).to eq({
          'A' => { 'B' => 5, 'D' => 5, 'E' => 7 },
          'B' => { 'C' => 4 },
          'C' => { 'D' => 8, 'E' => 2 },
          'D' => { 'C' => 8, 'E' => 6 },
          'E' => { 'B' => 3  },
        })
      end
    end
  
    context 'not a string' do
      it 'throws exception with error message "Graph should be inited with a string"' do
        expect { Graph.new :foo }.to raise_error.with_message('Graph should be inited with a string')
      end
    end

    context 'malformed string' do
      it 'throws exception with error message "Graph should be inited with something like \'AB1, BC2, CA3\'"' do
        expect { Graph.new 'blah-blah-blah' }.to raise_error.with_message('Graph should be inited with something like \'AB1, BC2, CA3\'')
      end
    end
    
    context 'string with self-looped vertices' do
      it 'throws exception with error message "Graph should not contain self-looped vertices"' do
        expect { Graph.new 'AB5, BB1' }.to raise_error.with_message('Graph should not contain self-looped vertices')
      end
    end

    context 'string with repeated edges' do
      it 'throws exception with error message "Graph should not contain repeated edges"' do
        expect { Graph.new 'AB5, AB7' }.to raise_error.with_message('Graph should not contain repeated edges')
      end
    end
  end
  
  describe '#distance_of supplied with' do
    before :each do
      @graph = Graph.new(@test_input)
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
  end
  
  describe '#routes_count_for supplied with' do
    before :each do
      @graph = Graph.new(@test_input)
    end
    
    context 'valid start and finish points and maximum stops count' do
      it 'returns routes count' do
        expect(@graph.routes_count_for('C', 'C', stops_lower_than_or_equal_to: 3)).to eq(2)
      end
    end

    context 'valid start and finish points and exact stops count' do
      it 'returns routes count' do
        expect(@graph.routes_count_for('A', 'C', stops_equal_to: 4)).to eq(3)
      end
    end

    context 'valid start and finish points and threshold distance' do
      it 'returns routes count' do
        expect(@graph.routes_count_for('C', 'C', distance_less_than: 30)).to eq(7)
      end
    end
  end
  
  describe '#length_for supplied with' do
    before :each do
      @graph = Graph.new(@test_input)
    end
    
    context 'valid start and finish points' do
      it 'returns minimal length of route from start to finish' do
        expect(@graph.length_for('A', 'C')).to eq(9)
      end
    end
  end
end