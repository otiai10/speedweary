puts "Your Ruby Version : %s" % RUBY_VERSION.to_s
# @ok : v1.8.7

class Loader
  @file
  def initialize(fp)
    @file = open(fp)
  end
  def to_array()
    res = []
    if @file
      @file.each do |ln|
        res.push(ln.strip)
      end
    end
    return res
  end
end

class Result
  attr_accessor :file,:line, :content
  def initialize(line, content)
    instance_variable_set "@line",       file
    instance_variable_set "@line",       line
    instance_variable_set "@content", content
  end
end

class Presentation
  def initialize(result, fname)
    puts "RESULT---------> %s" % fname
    if result
      puts "\e[#{31}m>>DUPULICATION IS DETECTED<<\e[#{0}m"
      puts "LINE : %s" % result.line.to_s
      puts "CONT : %s" % result.content.to_s
    else
      puts "\e[#{32}m<<there is no duplication>>\e[#{0}m"
    end
  end
end

def get_diff_index(arr1, arr2)
  arr1.each_with_index do |el,i|
    unless el == arr2[i]
      return i
    end
  end
  return nil
end

class SingleCheck
  def execute(target)
    cnt_orig = target.count
    cnt_uniq = target.uniq.count
    unless cnt_orig == cnt_uniq
      index = get_diff_index(target, target.uniq)
      return Result.new(index, target[index])
    end
  end
end

#class IntegCheck
#  def execute(target)
#    return Result.new(100, '(´・ω・`)')
#  end
#end

class Caliculate
  @target = []
  def initialize(arr)
    @target = arr 
  end
  def singlecheck()
    return SingleCheck.new().execute(@target)
  end
  def integcheck()
    return IntegCheck.new().execute(@target)
  end
end

#execute(ARGV[0], ARGV[1])
def main(args)
  integrated = []
  args.each_with_index do |fname,i|
    arr = Loader.new(fname).to_array()
    result = Caliculate.new(arr).singlecheck()
    Presentation.new(result, ARGV[i])
    integrated.push(arr)
  end
  #puts integrated.count
  #integ_result = Caliculate.new(integrated).integcheck()
  #Presentation.new(integ_result, 'Integrated')
end

main(ARGV)
