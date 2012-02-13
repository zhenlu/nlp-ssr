require "rule"

class Token
  @@rule = Rule.new
  def initialize(token,arg)
    @token = token
    @arg = arg
  end
  attr_reader :token, :arg
end

class GrammarToken < Token
  attr_reader :visit
  def expand
    @visit = Hash.new
    result = eval "@@rule."+@token
    result.map do |r|
      r.map do |e| 
        result = eval e
        @visit[result] = e
        result
      end
    end
  end
  
  def method_missing(*arg)
    if ["N","V","PN","AUX","DET","ADV","ADJ","P","C"].include? arg[0].to_s
      # create LexiconToken
      name = arg.shift
      args = arg.map { |e| "\""+e.to_s+"\""}.join(",")
      LexiconToken.new(name.to_s + "(" + args + ")", @arg)
    else
      # create GrammarToken
      GrammarToken.new(arg[0].to_s+"(@arg)", arg[1])
    end
  end
end

class LexiconToken < Token
  def expand
    result = eval "@@rule."+@token
    # puts @token
    # puts result
    if result == nil
      nil
    else
      result.split(";").map { |e| WordToken.new(e,nil) }
    end
  end  
end

class WordToken < Token
end
