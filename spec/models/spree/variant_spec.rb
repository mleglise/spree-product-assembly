require 'spec_helper'

module Spree
  describe Variant do
    context "filter assemblies" do
      let(:mug) { create(:product) }
      let(:tshirt) { create(:product) }
      let(:variant) { create(:variant) }

      context "variant has more than one assembly" do
        before do
          variant.assemblies << mug.master
          variant.assemblies << tshirt.master
        end

        it "returns both products" do
          expect(variant.assemblies_for([mug, tshirt])).to include mug.master
          expect(variant.assemblies_for([mug, tshirt])).to include tshirt.master
        end

        it { expect(variant).to be_a_part }
      end

      context "variant no assembly" do
        it "returns both products" do
          variant.assemblies_for([mug, tshirt]).should be_empty
        end
      end
    end
  end
end
