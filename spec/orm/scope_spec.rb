module MotionData
  describe Scope do
    extend Facon::SpecHelpers

    before do
      @subject = Scope.alloc.initWithClass(ParentModel)

      moc = UIApplication.sharedApplication.delegate.managedObjectContext
      moc.undoManager.beginUndoGrouping
    end

    after do
      moc = UIApplication.sharedApplication.delegate.managedObjectContext
      moc.undoManager.endUndoGrouping
      moc.undoManager.undo
    end

    describe Scope, "#initWithClass" do
      it "assigns entity based on the model class" do
        @subject.entity.should == ParentModel.entity_description
      end
    end

    describe Scope, "#destroy_all" do
      it "sends :destroy to all elements" do
        o1 = mock('model', destroy: true)
        o2 = mock('model', destroy: true)
        @subject.stub!(:to_a).and_return([o1, o2])

        o1.should.receive(:destroy)
        o2.should.receive(:destroy)

        @subject.destroy_all
      end
    end

    describe Scope, "#to_a" do
      it "returns array with objects matching the criteria" do
        model = ParentModel.create! string_value: "abc"
        @subject.to_a.should == [model]
      end

      it "raises exception when error occurs" do
        relation = @subject.where("invalid = 1")
        lambda { relation.to_a }.should.raise(StandardError)
      end
    end

    describe Scope, "#count" do
      before do
        ParentModel.create! string_value: "abc"
        ParentModel.create! string_value: "abc"
      end

      it "returns number of records" do
        @subject.count.should == 2
      end

      it "preserves result_type" do
        @subject.resultType = NSDictionaryResultType
        @subject.count
        @subject.resultType.should == NSDictionaryResultType
      end

      it "handles fetchOffset" do
        @subject.fetchOffset = 1
        @subject.count.should == 1
      end
    end

    describe Scope, "#first" do
      before do
        ParentModel.create! string_value: "first", int_value: 1
        ParentModel.create! string_value: "last", int_value: 2

        @subject.order('int_value', ascending: true)
      end

      it "returns first object" do
        @subject.first.string_value.should == "first"
      end

      it "resets fetchLimit" do
        @subject.first
        @subject.to_a.count.should == 2
      end
    end

    describe Scope, "#last" do
      before do
        ParentModel.create! string_value: "first", int_value: 1
        ParentModel.create! string_value: "last", int_value: 2

        @subject.order('int_value', ascending: true)
      end

      it "returns last object" do
        @subject.last.string_value.should == "last"
      end

      it "resets fetchLimit/fetchOffset" do
        @subject.last
        @subject.to_a.count.should == 2
      end
    end

    describe Scope, "#limit" do
      it "sets fetchLimit and returns self" do
        @subject.limit(10).fetchLimit.should == 10
        @subject.limit(10).isEqual(@subject).should == true
      end
    end

    describe Scope, "#offset" do
      it "sets fetchOffset and returns self" do
        @subject.offset(10).fetchOffset.should == 10
        @subject.limit(10).isEqual(@subject).should == true
      end
    end

    describe Scope, "#order" do
      it "returns self" do
        @subject.order("int_value").isEqual(@subject).should == true
      end

      it "creates appropriate NSSortDescriptor" do
        @subject.order("string_value")
        @subject.sortDescriptors.first.key.should == "string_value"
        @subject.sortDescriptors.first.ascending.should == true
      end

      it "processes :ascending option" do
        @subject.order("string_value", ascending: false)
        @subject.sortDescriptors.first.ascending.should == false
      end

      it "is chainable" do
        @subject.order("string_value").order("int_value").sortDescriptors.count.should == 2
      end
    end

    describe "#pluck" do
      it "returns array of column values" do
        ParentModel.create! string_value: "first", int_value: 1
        ParentModel.create! string_value: "last", int_value: 2

        @subject.order("int_value").pluck(:string_value).should == %w(first last)
      end

      it "restores result type" do
        model = ParentModel.create! string_value: "first", int_value: 1
        @subject.pluck(:string_value)
        @subject.all.should == [model]
      end
    end

    describe Scope, "#uniq" do
      it "sets returnsDistinctResults" do
        @subject.uniq.returnsDistinctResults.should == true
      end

      it "is chainable" do
        @subject.uniq.isEqual(@subject).should == true
      end
    end

    describe Scope, "#where" do
      it "accepts string as the criteria along with formatArgs" do
        @subject.where("int_value = ?", 1).predicate.predicateFormat.should == "int_value == 1"
      end

      it "accepts a hash" do
        @subject.where(int_value: 2).predicate.predicateFormat.should == "int_value == 2"
      end

      it "accepts a complex criteria" do
        @subject.where(value(:int_value) >= 2).predicate.predicateFormat.should == "int_value >= 2"
      end

      it "joins predicates with AND when chaining" do
        @subject.where(int_value: 2).where("string_value = ?", 'a').predicate.predicateFormat.should == '(int_value == 2) AND string_value == "a"'
      end
    end
  end
end