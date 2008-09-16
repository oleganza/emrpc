require File.dirname(__FILE__) + '/spec_helper'

describe String, "#parsed_uri" do
  before(:each) do
    @str = "http://ya.ru/path?query"
    @uri = @str.parsed_uri
  end
  it { @uri.should be_kind_of(::URI::Generic) }
  it { @uri.should == URI.parse(@str) }
end

describe ::URI::Generic, "#parsed_uri" do
  before(:each) do
    @str = "http://ya.ru/path?query"
    @regular_uri = URI.parse(@str)
    @uri = @regular_uri.parsed_uri
  end
  it { @uri.should equal(@regular_uri)}
end
