describe "HoldStatus" do

  context "when current status is buy" do
    before {HoldStatus.current = HoldStatus::BUY}
    specify { expect(HoldStatus.current.buy?).to be true }
    specify { expect(HoldStatus.current.sell?).to be false }
  end

  context "when current status is sell" do
    before {HoldStatus.current = HoldStatus::SELL}
    specify { expect(HoldStatus.current.buy?).to be false }
    specify { expect(HoldStatus.current.sell?).to be true }
  end
end
