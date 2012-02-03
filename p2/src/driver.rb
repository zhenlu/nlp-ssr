require "rule"
require "token"

# initialize

stack = []
first_token = GrammarToken.new "S"
stack.push first_token
rule = Rule.new
sentence = ""

# generate a random sentence
until stack.empty?
  the_token = stack.pop
  if the_token.class == WordToken
    if sentence == ""
      sentence = "" + the_token.token
    else
      sentence += " " + the_token.token
    end
  else
    result = rule.expand the_token
    result.reverse.each { |e| stack.push e }
  end
end

puts sentence
