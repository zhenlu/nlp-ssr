# 
#  rule.rb
#  nlp-ssr
#  
#  A class load from data file and provide grammer rule and lexicon
#  for random sentence generator 
# 

class Rule
  def initialize
    # read the lexicon
    @dict = Hash.new
    File.open("data/lexicon.dat") do |f|
      while line = f.gets
        line = line.split(':')
        dict = line[1].split(',')
        @dict[line[0]] = dict
      end
    end
    # read the grammar rules
    @grammar = Hash.new
    File.open("data/grammar.dat") do |f|
      while line = f.gets
        line = line.split(':')
        grammar = line[1].split('|')
        @grammar[line[0]] = grammar
      end
    end
  end
  
  def expand(token)
    if token.class == GrammarToken
      resultlist = @grammar[token.token]
      grammar = resultlist[rand(resultlist.size)].split
      grammar.reverse
      result = []
      grammar.each do |i|
        result.push(create_token i)
      end
      result
    else
      wordlist = @dict[token.token]
      result = WordToken.new wordlist[rand(wordlist.size)]
    end
  end
  
  def create_token(token)
    if ["P", "N", "PN", "V", "ADJ", "DET", "AUX", "COM"].include? token
      LexiconToken.new token
    else
      GrammarToken.new token
    end
  end
end
