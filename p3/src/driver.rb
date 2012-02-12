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
  result
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

puts ARGV[0]
a = input(ARGV[0])
sen = realize(a)
sen.each { |e| puts e.join " " }