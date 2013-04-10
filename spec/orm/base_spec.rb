describe "MotionData::Base" do
	before do
	end

	after do
		UIApplication.sharedApplication.delegate.managedObjectContext.rollback
	end

  describe "#inspect" do
    it "includes entity name" do
    	ParentModel.new.inspect.should =~ /ParentModel/
    end
  end
end