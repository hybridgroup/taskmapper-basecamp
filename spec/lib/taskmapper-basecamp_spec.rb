require 'spec_helper'

describe "TaskMapper::Basecamp" do
  let(:tm) { create_instance }

  it { tm.should be_an_instance_of(TaskMapper) }
  it { tm.should be_a_kind_of(TaskMapper::Provider::Basecamp) }

  it "should be able to validate it's authentication" do
    pending
    @ticketmaster.valid?.should be_true
  end

  it "should have a version" do
    expect(TaskMapper::Provider::Basecamp::VERSION).to be_a String
  end
end
