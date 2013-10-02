require 'spec_helper'

describe HTMLStripper do
  describe "#remove_tags" do
    context "with a blank string" do
      let(:string) { "".extend HTMLStripper }

      it "returns the blank string" do
        expect(string.remove_tags).to eq ""
      end
    end

    context "with simple tags" do
      let(:string) { "<div>Hello World!</div>".extend HTMLStripper }

      it "strips out tags" do
        expect(string.remove_tags).to eq "Hello World!"
      end
    end
  end
end
