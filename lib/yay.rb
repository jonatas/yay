require "yay/version"
require 'parser/current'

module Yay
  class Any < Struct.new(:tokens)
  end
  class Parser

    SOMETHING = '_'

    def initialize(expression)
      @expression = expression
      @tokens = expression.scan(/\+|\d+|\(|\)|\{|\}|\w+/)
      p @tokens
    end

    def parse
      case token=@tokens.shift
      when '('
        parse_until(')')
      when '{'
        Any.new(parse_until('}'))
      when /\d+/
        token.to_i
      when SOMETHING
        SOMETHING
      else
        token.to_sym
      end
    end

    def parse_until(reach_this)
      arr = []
      arr << parse until @tokens.first == reach_this
      @tokens.shift
      arr
    end

    def match?(expression=parse, node)
      head, *tail = expression
      if node.respond_to?(:type)
        if head.is_a?(Any)
          return false unless head.tokens.any?{|sub_token| match?(sub_token, node) }
        else
          puts "comparing head #{head} == #{node.type}"
          return false if head != node.type
        end
      else
        puts "comparing node #{head} == #{node}"
        case head
        when SOMETHING
          return false if node.nil?
        else
          return false if head != node
        end
      end

      tail.each_with_index do |sub_expression, i|
        puts "sub match?(#{sub_expression}, #{node.children[i]})"
        return false unless match?(sub_expression, node.children[i])
      end

      true
    end

  end
end
