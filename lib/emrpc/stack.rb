module EMRPC
  #
  # -> callback in(data)   -> down(data)  
  # <- up(data)            <- callback out(data)
  #
  class Stack < Module
    module Adapter
      def post_init
      end
      
      def unbind
      end
      
      def connection_completed
      end
      
      def receive_data(data)
        down(data)
      end
      def out(data)
        send_data(data)
      end
    end
    
    def initialize(modules = [], *args)
      @layers = [ objectify(Adapter) ]
      first = @layers.first
      connect_methods(self, :post_init,            first, :post_init)
      connect_methods(self, :receive_data,         first, :receive_data)
      connect_methods(self, :unbind,               first, :unbind)
      connect_methods(self, :connection_completed, first, :connection_completed)
      
      modules.each do |m|
        self << m
      end
    end
    
    def <<(m)
      curr = objectify(m) if m.is_a?(Module)
      prev = @layers.last
      connect_methods(meta(prev), :down, curr, :in)
      connect_methods(meta(curr), :up,   prev, :out)
    end
    
  private
  
    def objectify(m)
      o = Object.new
      o.extend(m)
      o
    end
    
    def meta(obj)
      class<<obj; self; end
    end
    
    # to_meth must exists, otherwise it is not connected
    def connect_methods(from_mod, from_meth, to, to_meth)
      to_meth = to.method(to_meth)
      from_mod.send(:define_method, from_meth, &to_meth)
    end
    
  end
end
