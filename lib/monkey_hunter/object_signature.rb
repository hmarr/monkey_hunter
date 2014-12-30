module MonkeyHunter
  class ObjectSignature
    attr_reader :imethod_sigs
    attr_reader :smethod_sigs
    attr_reader :const_sigs

    def initialize(object, ignore_imethods, ignore_smethods, ignore_constants)
      @object = object
      snapshot_instance_methods(object, ignore_imethods)
      snapshot_singleton_methods(object, ignore_smethods)
      snapshot_constants(object, ignore_constants)
    end

    private

    def snapshot_instance_methods(object, ignore_methods)
      imethod_names = object.instance_methods - ignore_methods
      @imethod_sigs = Hash[imethod_names.map do |name|
        [name, object.instance_method(name)]
      end]
    end

    def snapshot_singleton_methods(object, ignore_methods)
      smethod_names = object.singleton_methods - ignore_methods
      @smethod_sigs = Hash[smethod_names.map do |name|
        [name, object.method(name)]
      end]
    end

    def snapshot_constants(object, ignore_constants)
      constant_names = object.constants - ignore_constants
      @const_sigs = Hash[constant_names.map do |name|
        next if object.autoload?(name)
        next unless object.const_defined?(name)
        [name, object.const_get(name)]
      end.compact]
    end
  end
end
