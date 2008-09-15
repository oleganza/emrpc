require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
include EventedAPI

module MockDescribe
  def mock_describe(title, scope = :each, &blk)
    describe(title) do
      before(scope, &blk)
      it("should verify mocks expectations") { }
    end
  end
end
