require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Player" do

  let(:player) { Player.new }

  let(:codes) {[1301, 1302]}

  let(:buy_order) do
    Order::Buy.new(
      code: codes[0],
      price: 1000,
      volume: 20,
      edit_url: "something_url",
      cancel_url: "something_url",
      force: false,
    )
  end

  let(:sell_order) do
    Order::Buy.new(
      code: codes[1],
      price: 1000,
      volume: 10,
      edit_url: "something_url",
      cancel_url: "something_url",
      force: false,
    )
  end

  let(:buy_orders) do
      [Order::Buy.new(
        code: codes[0] ,
        price: 1000 ,
        volume: 10 ,
       ),
       Order::Buy.new(
         code: codes[1],
         price: 1100 ,
         volume: 10 ,
       )
      ]
  end

  let(:sell_orders) do
    [Order::Sell.new(
      code: codes[0],
      price: 1000 ,
      volume: 10 ,
     ),
     Order::Sell.new(
       code: codes[1],
       price: 1100 ,
       volume: 10 ,
     )
    ]
  end

  let(:board1) do
    Board.new(
      code: codes[0],
      price: 50,
      buy: 50,
      sell: 60,
      volume: 20
    )
  end

  let(:board2) do
    Board.new(
      code: codes[1],
      price: 50,
      buy: 40,
      sell: 50,
      volume: 20
    )
  end

  let(:buy_hand) do
    Hand.new(
      code: codes[0],
      price: 1000,
      order_price: 1100,
      trade_kbn: :buy,
      volume: 30, 
      url: 'something.url'
    )
  end

  let(:sell_hand) do
    Hand.new(
      code: codes[1],
      price: 1200,
      order_price: 1300,
      trade_kbn: :sell,
      volume: 30, 
      url: 'something.url'
    )
  end

  let(:buy_hand2) do
    Hand.new(
      code: codes[1],
      price: 1000,
      order_price: 1100,
      trade_kbn: :buy,
      volume: 30, 
      url: 'something.url'
    )
  end

  let(:sell_hand2) do
    Hand.new(
      code: codes[0],
      price: 1200,
      order_price: 1300,
      trade_kbn: :sell,
      volume: 30, 
      url: 'something.url'
    )
  end

  let(:buy_order_in_dealing) do
    Order::Buy.new(
      code: codes[0],
      price: 1200,
      volume: 50,
      status: Status::Edited.new
    )
  end

  describe "#decide" do

    context "assemble_status.be_contarcted" do
      before {allow(player).to receive(:assemble_status).and_return(AssembleStatus::BE_CONTRACTED)}

      context "when buy order is left" do
        before{player.orders = [buy_order]}

        specify{expect{player.decide {}}.to change{buy_order.force}.from(false).to(true)}
      end

      context "when buy and sell order is left" do
        before{player.orders = [buy_order, sell_order]}

        specify{expect{player.decide {}}.to change{buy_order.force}.from(false).to(true)}

        specify{expect{player.decide {}}.to change{sell_order.force}.from(false).to(true)}
      end
    end

    context "assemble_status.processing" do
      before{allow(player).to receive(:assemble_status).and_return(AssembleStatus::PROCESSING)}

      context "when buy order is left" do
        before{player.orders = [buy_order]}

        specify{expect{player.decide {}}.not_to change{buy_order.force}}
      end

      context "when buy and sell order is left" do
        before{player.orders = [buy_order, sell_order]}

        specify{expect{player.decide {}}.not_to change{buy_order.force}}

        specify{expect{player.decide {}}.not_to change{sell_order.force}}
      end
    end

    context "assemble_status.complete" do
      before {allow(player).to receive(:assemble_status).and_return(AssembleStatus::COMPLETE)}

      context "hold_status.none" do
        before {allow(player).to receive(:hold_status).and_return(HoldStatus::NONE)}

        context "order_status.pending" do
          before {allow(player).to receive(:order_status).and_return(OrderStatus::PENDING) }

          specify "should not create order" do 
            count = 0
            expect{player.decide {count+=1}}.not_to change{count}
          end
        end

        context "order_status.buy" do
          before do
            allow(player).to receive(:order_status).and_return(OrderStatus::BUY)
            allow(player).to receive(:buy).and_return(buy_orders)
          end

          specify{ expect(player.decide{}.length).to eq 2 }

          specify do "order must be created at Player#buy"
            player.decide do |order| 
              expect(buy_orders.include? order).to be true
            end
          end

          specify do "Player#repay must not be called"
            expect(player).not_to receive(:repaly)
            player.decide {}
          end

          specify do "Player#sell must not be called"
            expect(player).not_to receive(:sell)
            player.decide {}
          end

          specify do "AssembleStatus change to PROCESSING"
            expect(AssembleStatus).to receive(:current=).with(AssembleStatus::PROCESSING)
            player.decide {}
          end
        end

        context "order_status.sell" do
          before do
            allow(player).to receive(:order_status).and_return(OrderStatus::SELL)
            allow(player).to receive(:sell).and_return(sell_orders)
          end

          specify{ expect(player.decide{}.length).to eq 2 }

          specify do "order must be created at Player#sell"
            player.decide do |order| 
              expect(sell_orders.include? order).to be true
            end
          end

          specify do "Player#repay must not be called"
            expect(player).not_to receive(:repaly)
            player.decide {}
          end

          specify do "Player#buy must not be called"
            expect(player).not_to receive(:buy)
            player.decide {}
          end
        end

        context "order_status.loss_cut" do
          before { allow(player).to receive(:order_status).and_return(OrderStatus::LOSS_CUT) }

          specify do "Player#repay must not be called"
            expect(player).not_to receive(:repaly)
            player.decide {}
          end
        end
      end

      context "hold_status.buy" do
        before { allow(player).to receive(:hold_status).and_return(HoldStatus::BUY) }

        context "order_status.pending" do
        end

        context "order_status.buy" do
        end

        context "order_status.sell" do
        end

        context "order_status.loss_cut" do
        end
      end

      context " hold_status.sell" do
        before { allow(player).to receive(:hold_status).and_return(HoldStatus::SELL) }

        context "order_status.pending" do
          before { allow(player).to receive(:order_status).and_return(OrderStatus::PENDING) }

          specify "should not create order" do 
            count = 0
            expect{player.decide {count+=1}}.not_to change{count}
          end
        end

        context "order_status.buy" do
          before { allow(player).to receive(:order_status).and_return(OrderStatus::BUY) }

          specify do
            allow(player).to receive(:buy).and_return([])
            expect(player).to receive(:repay) 
            player.decide {}
          end

          specify do
            allow(player).to receive(:repay) 
            expect(player).to receive(:buy) 
            player.decide {}
          end

          specify do
            allow(player).to receive(:repay) 
            allow(player).to receive(:buy) 
            expect(player).not_to receive(:sell) 
            player.decide {}
          end
        end

        context "order_status.sell" do
          before { allow(player).to receive(:order_status).and_return(OrderStatus::SELL) }

          specify "should not create order" do 
            count = 0
            expect{player.decide {count+=1}}.not_to change{count}
          end
        end

        context "order_status.loss_cut" do
          before { allow(player).to receive(:order_status).and_return(OrderStatus::LOSS_CUT) }

          specify do "Player#repay must be called"
            expect(player).to receive(:repay).and_return([])
            player.decide {}
          end

          specify do "Player#buy must not be called"
            allow(player).to receive(:repay).and_return([])
            expect(player).not_to receive(:buy) 
            player.decide {}
          end

          specify do "Player#sell must not be called"
            allow(player).to receive(:repay).and_return([])
            expect(player).not_to receive(:sell) 
            player.decide {}
          end

        end
      end
    end
  end

  describe "#buy" do

    before do 
      player.codes = [board1.code, board2.code]
      player.boards = [board1, board2] 
      player.ticks = [10, 10]
      player.volumes = [50, 50]
    end

    specify do
      expect(player).to receive(:validate_board)
      player.buy
    end

    specify{expect(player.buy.length).to eq 2}

    specify{expect(player.buy[0].buy?).to be true}

    specify{expect(player.buy[1].sell?).to be true}

    specify{expect(player.buy[0].price).to eq board1.buy + player.ticks[0] }

    specify{expect(player.buy[0].volume).to eq player.volumes[0]}

    specify{expect(player.buy[1].price).to eq board2.sell - player.ticks[1]}

    specify{expect(player.buy[1].volume).to eq player.volumes[1]} 

  end

  describe "#sell" do

    before do 
      player.codes = [board1.code, board2.code]
      player.boards = [board1, board2] 
      player.ticks = [10, 10]
      player.volumes = [50,40]
    end

    specify do
      expect(player).to receive(:validate_board)
      player.sell
    end

    specify{expect(player.sell.length).to eq 2}

    specify{expect(player.sell[0].sell?).to be true}

    specify{expect(player.sell[1].buy?).to be true}

    specify{expect(player.sell[0].price).to eq board1.sell - player.ticks[0] }

    specify{expect(player.sell[0].volume).to eq player.volumes[0]}

    specify{expect(player.sell[1].price).to eq board2.buy + player.ticks[1]}

    specify{expect(player.sell[1].volume).to eq player.volumes[1]} 
  end

  describe "#repay" do

    before do 
      player.codes = codes
      player.boards = [board1, board2] 
      player.hands = [buy_hand, sell_hand]
      player.ticks = [10, 10]
      player.volumes = [50, 40]
    end

    specify do
      expect(player).to receive(:validate_board)
      player.repay
    end

    specify{expect(player.repay.length).to eq 2}

    specify{expect(player.repay[0].repay?).to be true}

    specify{expect(player.repay[1].repay?).to be true}

    specify{expect(player.repay[0].price).to eq board1.sell - player.ticks[0]}

    specify{expect(player.repay[1].price).to eq board2.buy + player.ticks[1]}

  end

  describe "#valid_board?" do

    context "when boads is nil" do

      specify{expect{player.validate_board}.to raise_error Player::InvalidBoadError}

    end

    context "when boads is blank" do

      before {player.boards = []}

      specify{expect{player.validate_board}.to raise_error Player::InvalidBoadError}

    end

    context "when boads dont have two codes" do

      before do 
        player.codes = codes
        player.boards = [board1] 
      end

      specify{expect{player.validate_board}.to raise_error Player::InvalidBoadError}

    end
  end

  describe "#hold_status" do
    before { player.codes = codes }

    specify "when none code in hand" do
      player.hands = []
      expect(player.hold_status).to eq HoldStatus::NONE
    end

    specify "when one code in hand" do
      player.hands = [buy_hand]
      expect(player.hold_status).to eq HoldStatus::INVALID
    end

    context "when all code in hand" do
      
      specify "and code1 is buy and code2 is sell " do
        player.hands = [buy_hand, sell_hand]
        expect(player.hold_status).to eq HoldStatus::BUY
      end

      specify "and code1 is sell and code2 is buy " do
        player.hands = [buy_hand2, sell_hand2]
        expect(player.hold_status).to eq HoldStatus::SELL
      end

      specify "but volume is different" do
        buy_hand2.volume = 10
        sell_hand2.volume = 20
        player.hands = [buy_hand2, sell_hand2]
        expect(player.hold_status).to eq HoldStatus::INVALID
      end
    end
  end

  describe "#assemble_status" do
    before{player.codes = codes}
    before{player.boards = [board1, board2]}

    specify "when none order" do
      player.orders = []
      expect(player.assemble_status).to eq AssembleStatus::COMPLETE
    end

    specify "when one order in dealing" do
      player.orders = [buy_order_in_dealing]
      expect(player.assemble_status).to eq AssembleStatus::PROCESSING
    end
  end

  describe "#order_status" do
  end
end
