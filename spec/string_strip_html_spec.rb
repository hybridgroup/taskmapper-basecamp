require 'spec_helper'

describe HTMLStripper do
  context "Blank string" do
    subject { "".extend(HTMLStripper) }
    its(:remove_tags) { should == "" }
  end

  context "With simple tags" do
    subject { "<div>hello world</div>".extend(HTMLStripper) }
    its(:remove_tags) { should == "hello world" }
  end
end
