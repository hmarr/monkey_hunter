require 'monkey_hunter/object_signature'
require 'monkey_hunter/object_diff'

module MonkeyHunter
  class ObjectGraphSnapshot
    attr_reader :object_sigs

    def initialize(existing_ancestors)
      @object_sigs = all_consts.inject({}) do |sigs, object|
        boring_ancestors = (object.ancestors & existing_ancestors) - [object]
        sigs[object] = ObjectSignature.new(object,
                                           imethods_for_all(boring_ancestors),
                                           smethods_for_all(boring_ancestors),
                                           constants_for_all(boring_ancestors))
        sigs
      end
    end

    def differences_to(other)
      @object_sigs.inject({}) do |diffs, (obj, sig1)|
        obj_diffs = ObjectDiff.new(obj, sig1, other.object_sigs[obj])
        diffs[obj] = obj_diffs unless obj_diffs.empty?
        diffs
      end
    end

    private

    def imethods_for_all(consts)
      consts.flat_map do |const|
        imethods_for(const)
      end.uniq
    end

    def smethods_for_all(consts)
      consts.flat_map do |const|
        smethods_for(const)
      end.uniq
    end

    def constants_for_all(consts)
      consts.flat_map do |const|
        constants_for(const)
      end.uniq
    end

    def imethods_for(const)
      @imethods_for ||= {}
      @imethods_for[const] ||= const.instance_methods
    end

    def smethods_for(const)
      @smethods_for ||= {}
      @smethods_for[const] ||= const.singleton_methods
    end

    def constants_for(const)
      @constants_for ||= {}
      @constants_for[const] ||= const.constants
    end

    def all_consts
      ObjectSpace.each_object(Module).select do |obj|
        obj.is_a?(Class) || obj.is_a?(Module)
      end
    end
  end
end
