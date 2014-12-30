module MonkeyHunter
  class TerminalFormatter
    def initialize(graph_diff)
      @graph_diff = graph_diff
    end

    def display
      puts
      @graph_diff.each do |obj, obj_diff|
        puts obj
        obj_diff.imethods.each do |name, info|
          puts "  ##{method_sig(info[:original])}" if info[:original]
          puts "   ->" if info[:original] && info[:new]
          puts "  ##{method_sig(info[:new])}" if info[:new]
          puts "    (from #{info[:new].owner})" if info[:new].owner != obj
        end

        obj_diff.smethods.each do |name, info|
          puts "  .#{method_sig(info[:original])}" if info[:original]
          puts "   ->" if info[:original] && info[:new]
          puts "  .#{method_sig(info[:new])}" if info[:new]
        end

        obj_diff.consts.each do |name, info|
          puts "  ::#{info[:original]}" if info[:original]
          puts "   ->" if info[:original] && info[:new]
          puts "  ::#{info[:new]}" if info[:new]
        end
        puts
      end
    end

    private

    def method_sig(method)
      params = method.parameters.map do |type, name|
        name ||= "<unnamed>"
        case type
        when :req   then name
        when :rest  then "*#{name}"
        when :key   then "#{name}:"
        when :block then "&#{name}"
        end
      end.join(", ")
      "#{method.name}(#{params})"
    end
  end
end
