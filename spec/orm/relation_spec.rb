describe "MotionData::Relation" do
  extend Facon::SpecHelpers

  before do
    @subject = MotionData::Relation.alloc.initWithClass(ParentModel)
  end

  after do
    UIApplication.sharedApplication.delegate.managedObjectContext.rollback
  end

  describe "#initWithClass" do
    it "assigns entity based on the model class" do
      @subject.entity.should == ParentModel.entity_description
    end
  end

  describe "#destroy_all" do
    it "sends :destroy to all elements" do
      o1 = mock('model', destroy: true)
      o2 = mock('model', destroy: true)
      @subject.stub!(:to_a).and_return([o1, o2])

      o1.should.receive(:destroy)
      o2.should.receive(:destroy)

      @subject.destroy_all
    end
  end

  describe "#to_a" do
    it "returns array with objects matching the criteria" do
      model = ParentModel.create! string_value: "abc"
      @subject.to_a.should == [model]
    end

    it "raises exception when error occurs" do
      relation = @subject.where("invalid = 1")
      lambda { relation.to_a }.should.raise(StandardError)
    end
  end
end