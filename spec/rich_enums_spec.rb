require "spec_helper"

RSpec.describe RichEnums do
  describe "error scenarios" do
    it "raises an error if the argument to rich_enum is not a Hash" do
      expect do
        Temping.create(:course_class) do
          include RichEnums
          rich_enum([])
        end
      end.to raise_error(RichEnums::Error)
    end

    it "raises an error if an empty Hash is passed to rich_enum" do
      expect do
        Temping.create(:course_class) do
          include RichEnums
          rich_enum({})
        end
      end.to raise_error(RichEnums::Error)
    end

    it "raises an error if the enum definition uses the Array form" do
      # This is not supported yet
      expect do
        Temping.create(:course_class) do
          include RichEnums
          rich_enum({status: [:active, :inactive]})
        end
      end.to raise_error(RichEnums::Error)
    end
  end

  describe "rich_enum usage" do
    context "it calls the ActiveRecord::Enum.enum method" do
      let(:course_class) do
        Temping.create(:course_class) do
          with_columns do |t|
            t.integer :status
            t.string :category
          end

          include RichEnums
        end
      end

      if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('7.2')
        it "invokes the enum method with the correct arguments" do
          allow(course_class).to receive(:enum).and_call_original

          course_class.rich_enum status: { active: 0, inactive: 1 }, alt: :name
          expect(course_class).to have_received(:enum).with(:status, { active: 0, inactive: 1 })
        end

        it "invokes the enum method with the correct arguments" do
          allow(course_class).to receive(:enum).and_call_original

          course_class.rich_enum status: { active: [0, 'LIVE'], inactive: [1, 'NOT_LIVE'] }, alt: :name
          expect(course_class).to have_received(:enum).with(:status, { active: 0, inactive: 1 })
        end

        it "invokes the enum method with the correct arguments" do
          allow(course_class).to receive(:enum).and_call_original
          course_class.rich_enum status: { active: [0, 'LIVE'], inactive: [1, 'NOT_LIVE'] }, prefix: true, alt: 'state'

          expect(course_class).to have_received(:enum).with(:status, { active: 0, inactive: 1 }, prefix: true)
        end
      else
        it "invokes the enum method with the correct arguments" do
          allow(course_class).to receive(:enum).and_call_original

          course_class.rich_enum status: { active: 0, inactive: 1 }, alt: :name
          expect(course_class).to have_received(:enum).with(status: { active: 0, inactive: 1 })
        end

        it "invokes the enum method with the correct arguments" do
          allow(course_class).to receive(:enum).and_call_original

          course_class.rich_enum status: { active: [0, 'LIVE'], inactive: [1, 'NOT_LIVE'] }, alt: :name
          expect(course_class).to have_received(:enum).with(status: { active: 0, inactive: 1 })
        end

        it "invokes the enum method with the correct arguments" do
          allow(course_class).to receive(:enum).and_call_original
          course_class.rich_enum status: { active: [0, 'LIVE'], inactive: [1, 'NOT_LIVE'] }, _prefix: true, alt: 'state'

          expect(course_class).to have_received(:enum).with(status: { active: 0, inactive: 1 }, _prefix: true)
        end
      end
    end

    context "with only an alternate name specified without additional mapping" do
      let(:course_class) do
        Temping.create(:course_class) do
          with_columns do |t|
            t.integer :status
            t.string :category
          end

          include RichEnums
          rich_enum status: { active: 0, inactive: 1 }, alt: :name
        end
      end
      let(:test_instance) { course_class.new }

      it "defines a class method for each enum" do
        expect(course_class).to respond_to(:status_names)
      end

      it "returns a hash of enum values and names" do
        expect(course_class.status_names).to eq({"active"=>"active", "inactive"=>"inactive"})
      end

      it "defines an instance method for each enum" do
        expect(test_instance).to respond_to(:status_name)
      end

      it "returns the value in response to alternate name" do
        test_instance.status = 0
        expect(test_instance.status_name).to eq(test_instance.status)
        test_instance.status = 1
        expect(test_instance.status_name).to eq(test_instance.status)
        test_instance.status = :active
        expect(test_instance.status_name).to eq(test_instance.status)
        test_instance.status = 'inactive'
        expect(test_instance.status_name).to eq(test_instance.status)
      end
    end

    context "with an alternate name and mapping specified" do
      let(:course_class) do
        Temping.create(:course_class) do
          with_columns do |t|
            t.string :status
          end

          include RichEnums
          rich_enum status: { active: [0, 'LIVE'], inactive: [1, 'NOT_LIVE'] }, alt: :name
        end
      end

      let(:test_instance) { course_class.new }

      it "defines a class method for each enum" do
        expect(course_class).to respond_to(:status_names)
      end

      it "returns a hash of enum values and names" do
        expect(course_class.status_names).to eq({"active"=>"LIVE", "inactive"=>"NOT_LIVE"})
      end

      it "defines an instance method for each enum" do
        expect(test_instance).to respond_to(:status_name)
      end

      it "returns the alternate name of the enum value" do
        test_instance.status = 0
        expect(test_instance.status_name).to eq("LIVE")
        test_instance.status = 1
        expect(test_instance.status_name).to eq("NOT_LIVE")
        test_instance.status = :active
        expect(test_instance.status_name).to eq("LIVE")
        test_instance.status = 'inactive'
        expect(test_instance.status_name).to eq("NOT_LIVE")
      end
    end
  end
end
