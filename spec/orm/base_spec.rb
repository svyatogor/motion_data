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

    it "includes all properties" do
    	model = ParentModel.new string_value: "abc", int_value: 10
    	model.inspect.should =~ /string_value: \"abc\"/
    	model.inspect.should =~ /int_value: 10/
    end
  end

  describe "#context" do
  	it "returns AppDelegates NSManagedObjectContext by default" do
  		ParentModel.new.context.should == UIApplication.sharedApplication.delegate.managedObjectContext
  	end
  end

  describe "::context" do
  	it "returns AppDelegates NSManagedObjectContext by default" do
  		ParentModel.context.should == UIApplication.sharedApplication.delegate.managedObjectContext
  	end
  end

  describe "::serialize" do
  	it "defines getter and setter" do
  		ParentModel.class_eval { serialize :x }
  		ParentModel.new.should.respond_to :x
  		ParentModel.new.should.respond_to :x=
  	end

  	it "accepts array of fields" do
  		ParentModel.class_eval { serialize :x, :y }
  		ParentModel.new.should.respond_to :x
  		ParentModel.new.should.respond_to :y
  	end

  	describe "setter" do
  		it "store marshaled data in primitive" do
  			v = [1,2]
  			d = Marshal.dump(v).nsdata
  			ParentModel.class_eval { serialize :x }
  			model = ParentModel.new

  			model.x = v
  			model.primitiveX.should == d
  		end
  	end

  	describe "getter" do
  		it "deserializes marshaled data from primitive" do
  			v = [1,2]
  			d = Marshal.dump(v).nsdata
  			ParentModel.class_eval { serialize :x }
  			model = ParentModel.new

  			model.primitiveX = d
  			model.x.should == v
  		end
  	end
  end

  describe "::entity_description" do
  	it "returns valid entity description" do
  		ParentModel.entity_description.name.should == "ParentModel"
  	end
  end
end