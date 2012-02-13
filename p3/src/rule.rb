class Rule
  def initialize
    @lex = Hash.new
    File.open("data/lexicon.dat") do |f|
      while line = f.gets 
        pair = line.strip.split("->")
        @lex[pair[0]] = pair[1]
      end
    end
    @grammar = Hash.new
    File.open("data/grammar.dat") do |f|
      while line = f.gets
        pair = line.strip.split("->")
        @grammar[pair[0].strip] = [] if @grammar[pair[0].strip] == nil
        @grammar[pair[0].strip].push pair[1].strip
      end
    end
  end
  
  def method_missing(*arg)
    if ["N","V","PN","AUX","DET","ADV","ADJ", "P", "C"].include? arg[0].to_s
      key1 = arg.join(",")
      arg[1] = "*"
      key2 = arg.join(",")
      if @lex[key1] == nil
        @lex[key2]
      else
        @lex[key1]
      end
    else
      @grammar[arg[0].to_s+"(arg)"].map do |g|
        g.split.map do |e|
          e.gsub("arg","@arg")
        end
      end
    end
  end
  
  def ADJLIST(arg)
    result = []
    if arg.state != nil
      result.push "ADJ(\""+arg.state+"\")"
    end
    if arg.size != nil
      result.push "ADJ(\""+arg.size+"\")"
    end
    if arg.color != nil
      result.push "ADJ(\""+arg.color+"\")"
    end  
    if arg.shape != nil
      result.push "ADJ(\""+arg.shape+"\")"
    end  
    if arg.taste != nil
      result.push "ADJ(\"taste\",\""+arg.taste+"\")"
    end 
    [result]
  end
  
  def PPLIST(arg)
    result = []
    if arg.destination != nil
      current = ["P(\"to\")", "NP(@arg.destination)"]
      result.push current
    end
    if arg.place != nil
      current = ["P(\"in\")", "NP(@arg.place)"]
      result.push current
    end
    if arg.about != nil
      current = ["P(\"about\")", "NP(@arg.about)"]
      result.push current
    end
    if arg.like != nil
      current = ["P(\"like\")", "NP(@arg.like)"]
      result.push current
    end
    if arg.location != nil
      current = ["P(\"at\")", "NP(@arg.location)"]
      result.push current
    end
    result
  end
  
  def S(arg)
    if arg.speechact == "ASSERTION"
      [["NP(@arg.agent)","VP(@arg)"]]
    elsif arg.speechact == "QUESTION"
      [["AUX(@arg.type,@arg.polarity,@arg.speechact,@arg.time)","NP(@arg.agent)","VP(@arg)"]]
    else
      []
    end
  end
end
