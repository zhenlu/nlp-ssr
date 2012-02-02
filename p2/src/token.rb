class Token
  def initialize(arg)
    @token = arg
  end
  attr_reader :token
end

class GrammarToken < Token
end

class LexiconToken < Token
end

class WordToken < Token
end
