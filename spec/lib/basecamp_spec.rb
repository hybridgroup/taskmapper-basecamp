require 'spec_helper'

describe TaskMapper::Provider::Basecamp do
  let(:tm) { create_instance }

  describe "#new" do
    it "creates a new TaskMapper instance" do
      expect(tm).to be_a TaskMapper
    end

    it "can be explicitly called as a provider" do
      tm = TaskMapper::Provider::Basecamp.new(
        :token => token,
        :domain => domain
      )

      expect(tm).to be_a TaskMapper
    end
  end

  describe "#valid?" do
    context "with a correctly authenticated Basecamp user" do
      it "returns true" do
        expect(tm.valid?).to be_true
      end
    end
  end
end
