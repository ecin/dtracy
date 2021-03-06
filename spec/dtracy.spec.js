
describe 'util'

  describe 'isDefined()'
  
    before 
      a = true;
      b = false;
      c = ""
      d = null
      e = 0;
      vars = [a,b,c,d,e]
    end
  
    it 'should return true for any variable that has been defined'
      for(v in vars){
        util.isDefined(vars[v]).should_eql true
      }
    end
    
    // To-do: find a way to test with an undefined variable
  
  end
end

describe 'Array'

  describe 'max()'

    it 'should select the max value in an array'
      [1, 2, 3, 4].max().should_eql 4
    end
    
  end
  
  describe 'min()'

    it 'should select the min value in an array'
      [1, 2, 3, 4].min().should_eql 1
    end
    
  end
end

describe 'gui'

  describe 'Console'
  
    
  
  end
end

describe 'dtracy'

  before
    obj = {}
    a = b = 0;
    obj.fun = function() { a = 1 }
    obj.fun2 = function() { b = 2 }
    probe = new dtracy.Probe('gc-start')
    probe2 = new dtracy.Probe('blue', obj.fun, obj.fun2)
    event = new dtracy.Event(1234, 1234567890, 'gc-start', {})
  end

  describe 'Probe'
    it 'should add instances to dtracy.Probes[]'
      dtracy.Probes[probe.name].should_eql probe
    end
    
    describe 'addEvent()'
      it 'should add an Event to probe.events'
        probe.addEvent(event)
        probe.events.pop().should_eql event
      end
    
      it 'should add an Event to dtracy.Probes[event.name].events'
        probe.addEvent(event)
        dtracy.Probes[event.name].events.pop().should_eql event
      end
      
      it 'should call all functions in the :callbacks array'
        probe2.addEvent(event)
        a.should_eql 1
        b.should_eql 2
      end
    end
  end
  
  describe 'dtracy.Probes'
    describe 'addEvent()'
      it 'should add an Event to the Probe with event.name'
        dtracy.Probes.addEvent(event)
        dtracy.Probes[event.name].events.pop().should_eql event
      end
    end
    
    describe 'latest()'
      it 'should return the latest added event'
        dtracy.Probes.addEvent(event)
        dtracy.Probes.latest().should_eql event
        evnt = new dtracy.Event(1234, 1234567890, 'gc-start', ["/"])
        dtracy.Probes.addEvent(evnt)
        dtracy.Probes.latest().should_eql evnt
      end
    end
  end
  
  describe 'Events'
    describe 'toString()'
      it 'should return a string represention of the event'
        result = "<span class='evnt_timestamp'>1234567890</span> "
        result += "<span class='evnt_name'>gc-start</span> "
        result += "<span class='evnt_argument_name'>pid</span> "
        result += "<span class='evnt_argument_value'>1234</span> "
        result += "<span class='evnt_argument_name'>args</span> "
        result += "<span class='evnt_argument'>/</span> "
        evnt = new dtracy.Event(1234, 1234567890, 'gc-start', ["/"])
        result.should_eql evnt.toString()
      end
    end
  end

end

describe 'vis'
  
  before
    ball = new vis.Base();
  end
  
  describe 'update()'
    it 'should update attributes based on a Hash argument'
      ball.update({size: 4, speed: 2})
      ball.size.should_eql 4
      ball.speed.should_eql 2
    end
  end
  
  describe 'vis.Ball'
  
    describe 'update()'
    
      before_each
        ball = new vis.Ball(10,10);
      end
    
      it 'should increase ball size depending on :requests size'
        size = ball.size;
        ball.update(10);
        ball.size.should_be_greater_than size
      end
      
      it 'should lower the ball size if :requests\'s value falls'
        ball.update(10);
        size = ball.size;
        ball.update(0);
        ball.size.should_be_less_than size
      end
      
      it 'should limit the ball\'s size increase depending on :requests\'s value'
        for(i = 0; i < 100; i++)
          ball.update(10);
        size = ball.size
        for(i = 0; i < 100; i++)
          ball.update(10);
        ball.size.should_eql size
        for(i = 0; i < 100; i++)
          ball.update(100);
        ball.size.should_be_greater_than size
      end
    end
  end
  
end

