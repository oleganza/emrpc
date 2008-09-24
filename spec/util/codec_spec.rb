require File.dirname(__FILE__) + '/spec_helper'

describe "Codec with" do
  
  before(:each) do
    @encode_method = :encode_b381b571_1ab2_5889_8221_855dbbc76242
    @decode_method = :decode_b381b571_1ab2_5889_8221_855dbbc76242
    @dummy_pid = mock("dummy pid", :uuid => "dummy-uuid")
    @host_pid = mock("host pid", :find_pid => @dummy_pid)
  end
  
  describe Object do
    before(:each) do
      @obj = Object.new
    end
    
    it "should return self" do
      @obj.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid).should eql(@obj)
      @obj.decode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid).should eql(@obj)
    end
  end
  
  describe PidVariables do
    before(:each) do
      ::MyClass = Class.new do 
        include PidVariables
        attr_accessor :name, :pid
      end
      @pid = Pid.new
      @obj = ::MyClass.new
      @obj.name = "Oleg"
      @obj.pid = @pid
      @encoded = @obj.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid)
    end
    
    after(:each) do
      Object.send(:remove_const, :MyClass) if defined?(::MyClass)
    end
    
    it "should encode ivars" do
      encoded = @encoded
      encoded.should be_kind_of(PidVariables::Container)
      encoded.cls.should == @obj.class
      name_pair, pid_pair = encoded.ivars.sort_by{|a|a[0]}
      name_pair.should == ["@name", "Oleg"]
      pid_pair[0].should == "@pid"
      pid_pair[1].should be_kind_of(Pid::Marshallable)
      pid_pair[1].uuid.should == @obj.pid.uuid
    end

    describe PidVariables::Container do
      before(:each) do
        @host_pid.should_receive(:find_pid).once.with(@pid.uuid).and_return do |uuid|
          @pid
        end
        @decoded = @encoded.decode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid)
      end
      
      it "should decode ivars" do
        @decoded.class.should == @obj.class
        @decoded.name.should == @obj.name
        @decoded.pid.should == @obj.pid
      end
    end
  end
  
  describe "primitive", :shared => true do
    it "should return itself" do
      @obj.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid).should eql(@obj)
    end
    it "should return itself" do
      @obj.decode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid).should eql(@obj)
    end
  end

  [nil, true, false, "string", 123, 3.725, :symbol].each do |obj|
    describe obj.inspect do
      before(:each) do
        @obj = obj
      end
      it_should_behave_like "primitive"
    end
  end

  def codec_mock(method, name, n)
    enc = name.upcase.to_sym
    item = mock(name)
    item.stub!(method).and_return(enc)
    item.should_receive(method).exactly(n).times.with(@host_pid).and_return do |hpid|
      hpid.should == @host_pid
      enc
    end
    item
  end
  
  describe Array do
    describe "array codec", :shared => true do
      it "should encode/decode each item recusively" do
        item = codec_mock(@method, "item", 6)
        @arr = [item, item, [item, item, [item, [[item]] ]]]
        @coded = @arr.__send__(@method, @host_pid)
        item = :ITEM
        @coded.should == [item, item, [item, item, [item, [[item]] ]]]
      end
    end
    describe "encoding" do
      before(:each) do
        @method = @encode_method
      end
      it_should_behave_like "array codec"
    end
    describe "decoding" do
      before(:each) do
        @method = @decode_method
      end
      it_should_behave_like "array codec"
    end
  end


  describe Hash do
    describe "hash codec", :shared => true do
      it "should encode/decode each key and value recusively" do
        key   = codec_mock(@method, "key", 3)
        value = codec_mock(@method, "value", 3)
        @hash = { key => value, :key => { key => { "str" => value, key => {"str" => 123, :sym => value } } } }
        @coded = @hash.__send__(@method, @host_pid)
        key = :KEY
        value = :VALUE
        @coded.should == { key => value, :key => { key => { "str" => value, key => {"str" => 123, :sym => value } } } }
      end
    end
    describe "encoding" do
      before(:each) do
        @method = @encode_method
      end
      it_should_behave_like "hash codec"
    end
    describe "decoding" do
      before(:each) do
        @method = @decode_method
      end
      it_should_behave_like "hash codec"
    end
  end
  
  describe Pid do
    before(:each) do
      @pid = Pid.new
      @pid.uuid = @dummy_pid.uuid
      @epid = @pid.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid)
    end
    
    it "should be encoded into Pid::Marshallable" do
      @epid.should be_kind_of(Pid::Marshallable)
      @epid.uuid.should_not be_nil
      @epid.uuid.should == @pid.uuid
    end
    
    describe "decoded" do
      before(:each) do
        @host_pid.should_receive(:find_pid).once.with(@dummy_pid.uuid).and_return do |uuid|
          @dummy_pid
        end
        @depid = @epid.decode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid)
      end
      it "should be decoded into real pid" do
        @depid.should == @dummy_pid
      end
    end
  end
end


describe Pid::Marshallable do
  before(:each) do  
    @cls = Pid::Marshallable
    @obj = @cls.new("myuuid")
  end
  it "should be marshallable" do
    Marshal.load(Marshal.dump(@obj)).uuid.should == @obj.uuid
  end
end
