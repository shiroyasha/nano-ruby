EMPTY = /^\s+/
NUMBER = /^[1-9][0-9]*/
OPERATOR = /^\+/

class Token
  attr_reader :type
  attr_reader :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def number?
    @type == :number
  end

  def operator?
    @type == :operator
  end

  def to_s
    "#{value} (#{type})"
  end
end

def tokens(string)
  result = []

  while !string.empty?
    if match = string.match(EMPTY)
      string = string[match[0].length..-1]
      next
    end

    if match = string.match(NUMBER)
      result << Token.new(:number, match[0].to_i)
      string = string[match[0].length..-1]
      next
    end

    if match = string.match(OPERATOR)
      result << Token.new(:operator, match[0])
      string = string[match[0].length..-1]
      next
    end
  end

  result
end

class AST
  attr_reader :token
  attr_reader :left
  attr_reader :right

  def initialize(token, left = nil, right = nil)
    @token = token
    @left = left
    @right = right
  end

  def to_s(indent = 0)
    if @left && @right
      "#{" " * indent}#{@token}\n#{@left.to_s(indent+2)}\n#{@right.to_s(indent+2)}"
    elsif @left
      "#{" " * indent}#{@token}\n#{@left.to_s(indent+2)}"
    elsif @right
      "#{" " * indent}#{@token}\n#{@right.to_s(indent+2)}"
    else
      "#{" " * indent}#{@token}"
    end
  end
end

def parse_expression(tokens)
  if tokens.length == 1 && tokens.first.number?
    return AST.new(tokens.shift)
  end

  if tokens[0].number? && tokens[1].operator?
    number = tokens.shift
    operator = tokens.shift

    AST.new(operator, AST.new(number), parse_expression(tokens))
  end
end

def parse(tokens)
  result = []

  while !tokens.empty?
    result << parse_expression(tokens)
  end

  result
end

ast = parse(tokens("1 + 23 + 100"))

puts ast

def evaluate(ast)
  return ast.token.value if ast.token.number?

  if ast.token.operator? && ast.token.value == "+"
    evaluate(ast.left) + evaluate(ast.right)
  end
end

puts evaluate(ast.first)
