describe "MotionData::Base" do
	before do
		p App.documents_path
	end
  describe "#inspect" do
    it "includes entity name" do
    	ParentModel.new.inspect.should =~ /ParentModel/
    end
  end
end