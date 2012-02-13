class SemanticNode
  def initialize
    @hash = Hash.new
    @visit = Hash.new
  end
  
  def method_missing(*arg)
    if arg[1] != nil
      @hash[arg[0].to_s] = arg[1] 
      @visit[arg[0].to_s] = false
    end
    @hash[arg[0].to_s]
  end
  
  def visit(arg)
    old_value = @visit[arg]
    @visit[arg] = true
    old_value
  end
  
  def visit?(arg)
    @visit[arg]
  end
  
  def clear(arg,value)
    @visit[arg] = value
  end
  
  def validate
    @hash.each_key do |key|
      if @hash[key].class == SemanticNode
        v = @hash[key].validate
      else
        v = @visit[key]
      end
      unless v != false or \
        ["speechact","size","state","color","shape","taste","details","cause","next","oppose"].include? key or \
        (key == "polarity" and @hash[key] == "POS") or
        (key == "identifiable" and @hash[key] == "false")
        # puts key
        return false
      end
    end
    true
  end
end
