require 'logger'
require 'monkey_hunter/object_graph_snapshot'
require 'monkey_hunter/terminal_formatter'

module MonkeyHunter
  def self.go_hunting!(gem, gem_require: nil, output: :terminal)
    load_stdlib!
    load_dependencies!(gem)

    existing_consts = ObjectSpace.each_object(Module).select do |obj|
      obj.is_a?(Class) || obj.is_a?(Module)
    end

    logger.info("Taking initial snapshot")
    initial_snapshot = ObjectGraphSnapshot.new(existing_consts)

    logger.info("Loading #{gem}")
    require (gem_require || gem)

    logger.info("Taking final snapshot")
    final_snapshot = ObjectGraphSnapshot.new(existing_consts)

    graph_diffs = initial_snapshot.differences_to(final_snapshot)

    case output
    when :terminal
      TerminalFormatter.new(graph_diffs).display
    when :json
      diff_hash = graph_diffs.map do |obj, diff|
        [obj.name, diff.to_h]
      end
      puts JSON.pretty_generate(Hash[diff_hash])
    else
      logger.error("Invalid output format #{output}")
      return
    end
  end

  def self.load_stdlib!
    logger.info("Loading the ruby standard library")
    Dir.entries(RbConfig::CONFIG["rubylibdir"]).grep(/\.rb$/).reject do |file|
      file =~ /^(debug|rss|webrick|dl|.*-tk|tk.*|tcltk|rdoc|profiler?).rb$/i
    end.each do |file|
      lib = file.gsub(/\.rb$/, "")
      require lib
    end
  end

  def self.load_dependencies!(gem)
    Gem::Specification.find_by_name(gem).dependencies.each do |dep|
      if dep.type == :runtime
        logger.info("Loading #{dep.name}")
        require dep.name
      end
    end
  end

  def self.logger
    @logger ||= Logger.new($stderr)
  end
end
