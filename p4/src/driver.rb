require "rule"
require "semantic_node"
require "token"
require "jcode"

def dfs(stack, current, result, arg)
  # stack.each { |e| print e.token }
  # puts
  if stack.empty?
    # puts current.join " "
    if arg.validate
      result.push current.clone
    end
  else
    tok = stack.pop
    if tok.class == WordToken
      current.push tok.token
      dfs(stack, current, result, arg)
      current.pop
    elsif tok.class == LexiconToken
      token = tok.expand
      if token != nil
        token.each do |e|
          stack.push e
          dfs(stack, current, result, arg)
          stack.pop
        end
      end
    else
      lists = tok.expand
      lists.each do |list|
        old_arg = Hash.new
        list.reverse.each do |e|  
          # backtracking
          stack.push e
          tok.visit[e].split("(")[1].split(")")[0].split(",").each do |e|  
            key = e.split(".")[1]
            if key != nil
              old_arg[key] = tok.arg.visit(key)
            end
          end
        end
        dfs(stack, current, result, arg)
        list.each do |e| 
          stack.pop 
          tok.visit[e].split("(")[1].split(")")[0].split(",").each do |e|  
            key = e.split(".")[1]
            if key != nil
              tok.arg.clear(key,old_arg[key])
            end
          end
        end
      end 
    end
    stack.push tok
  end
end

def realize(arg)
  stack = []
  result = []
  stack.push GrammarToken.new("S(@arg)", arg)
  dfs(stack, [], result, arg)
  result[0]
end

def construct(str)
  state = 1
  result = SemanticNode.new
  base = "result."
  key = ""
  value = ""
  clause = ""
  pcount = 0
  str.each_char do |chr|  
    if state == 1
      if chr != ":"
        key += chr
      else
        state = 2
      end
    elsif state == 2
      if chr == ";"
        state = 1
        eval base+key+"(\""+value+"\")"
        key = ""
        value = ""
      elsif chr == "("
        state = 3
        pcount = 1
      else
        value += chr
      end
    elsif state == 3
      if chr == ")" and pcount == 1
        node = construct(clause)
        eval base+key+"(node)"
        state = 4
        key = ""
        clause = ""
      else
        pcount += 1 if chr == "("
        pcount -= 1 if chr == ")"
        clause += chr
      end
    else
      state = 1
    end
  end
  return result
end

def input(f)
  File.open(f) do |f|
    str = ""
    while line = f.gets
      str += line.strip
    end
    result = construct(str)
  end
end

def details(n,s)
  [find_goal(n),"",find_goal(s)]
end

def next_one(n,s)
  words = ["then","and","after that","next"]
  item = words[rand(words.length)]
  [find_goal(n),item,find_goal(s)]
end

def cause(n,s)
  words = ["so","therefore"]
  item = words[rand(words.length)]
  [find_goal(n),item,find_goal(s)]
end

def oppose(n,s)
  words = ["but","however"]
  item = words[rand(words.length)]
  [find_goal(n),item,find_goal(s)]
end


def find_goal(arg)
  if arg.oppose != nil and arg.visit?("oppose") == false
    arg.visit("oppose")
    "oppose"
  elsif arg.details != nil and arg.visit?("details") == false
    arg.visit("details")
    "details"
  elsif arg.cause != nil and arg.visit?("cause") == false
    arg.visit("cause")
    "cause"
  elsif arg.next_one != nil and arg.visit?("next_one") == false
    arg.visit("next_one")
    "next_one"
  else 
    "realize"
  end
end

def print_tree(level, node, file)
  level.downto(1) { file.print "\t" }
  file.puts node
end

def plan(arg,start,process,tree)
  goal = eval "find_goal(arg.#{start})"
  stack = []
  n = eval "arg.#{start}"
  s = nil
  s = eval "arg.#{eval "n.#{goal}"}" if goal != "realize"
  label = eval "n.#{goal}"
  stack.push [goal, n, s, 0, start, label]
  until stack.empty?
    k = stack.pop
    level = k[3]
    goal = k[0]
    n = k[1]
    s = k[2]
    nl = k[4]
    sl = k[5]
    if nl != nil
      node = goal + " " + nl
      print_tree(level, node, tree)
    end
    process.puts "Expanding #{goal} #{nl}"
    if goal == "realize"
      process.puts "Result: realize a sentence"
      sen = realize(n)
      process.puts sen.join " "
      print sen.join " "
      print ". "
    elsif ["next_one", "cause", "details", "oppose"].include? goal
      goals = eval "#{goal}(n,s)"
      n2 = s
      s2 = nil
      s2 = eval "arg.#{eval "n2.#{goals[2]}"}" if goals[2] != "realize"
      s2l = eval "n2.#{goals[2]}"
      stack.push [goals[2], n2, s2, level+1, sl, s2l]
      stack.push [goals[1], nil, nil, level+1, nil, nil]
      n1 = n
      s1 = nil
      s1 = eval "arg.#{eval "n1.#{goals[0]}"}" if goals[0] != "realize"
      s1l = eval "n1.#{goals[0]}"
      p = [goals[0], n1, s1, level+1, nl, s1l]
      stack.push p 
      process.puts "Result: #{goals[0]} #{nl} #{goals[1]} #{goals[2]} #{sl}"
    else
      print goal
      print " " if goal != ""
    end
  end
end

puts ARGV[0]
a = input(ARGV[0])
process = File.new(ARGV[1],"w")
tree = File.new(ARGV[2],"w")
sen = plan(a,ARGV[3],process,tree)
puts
# puts sen
