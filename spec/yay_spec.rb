require "spec_helper"

RSpec.describe Yay do
  it "has a version number" do
    expect(Yay::VERSION).not_to be nil
  end

  describe Yay::Parser do
    describe '#parse' do
      specify do
        expect(described_class.new('()').parse).to eq([])
        expect(described_class.new('(())').parse).to eq([[]])
        expect(described_class.new('(int 1)').parse).to eq([:int, 1])
        expect(described_class.new('(int _)').parse).to eq([:int, described_class::SOMETHING])
        expect(described_class.new('({int float} _)').parse).to eq([Yay::Any.new([:int, :float]), described_class::SOMETHING])
        expect(described_class.new('(lvasgn a (int 1))').parse).to eq([:lvasgn, :a, [:int, 1]])
      end
    end
    describe "#match?" do
      specify do
        node = Parser::CurrentRuby.parse('1')
        expect(described_class.new('(int 1)')).to be_match(node)
        expect(described_class.new('(int 2)')).not_to be_match(node)
      end

      specify do
        node_1 = Parser::CurrentRuby.parse('1')
        node_2 = Parser::CurrentRuby.parse('2')
        node_3 = Parser::CurrentRuby.parse('3.0')
        expect(described_class.new('(int _)')).to be_match(node_1)
        expect(described_class.new('(int _)')).to be_match(node_2)
        expect(described_class.new('({ int float } _)')).to be_match(node_3)
      end

      specify do
        node = Parser::CurrentRuby.parse('a = 1')
        expect(described_class.new('(lvasgn a (int 1))')).to be_match(node)
      end

      specify do
        node = Parser::CurrentRuby.parse('@a = 1')
        expect(described_class.new('({ivasgn lvasgn} _ (int _))')).to be_match(node)
      end
    end
  end
end
