module MonkeyHunter
  class ObjectDiff
    attr_reader :imethods, :smethods, :consts

    def initialize(object, sig1, sig2)
      @object = object
      @imethods = Hash[sig_hash_compare(sig1.imethod_sigs, sig2.imethod_sigs)]
      @smethods = Hash[sig_hash_compare(sig1.smethod_sigs, sig2.smethod_sigs)]
      @consts = Hash[sig_hash_compare(sig1.const_sigs, sig2.const_sigs)]
    end

    def empty?(*opts)
      imethods.empty? && smethods.empty? && consts.empty?(*opts)
    end

    def consts
      if [Class, Object, Module].include?(@object)
        @consts.reject { |_, info| info[:action] == :defined }
      else
        @consts
      end
    end

    private

    def sig_hash_compare(a, b)
      (a.keys + b.keys).uniq.map do |key|
        a_val, b_val = a[key], b[key]
        action = if a_val == b_val || a_val.equal?(b_val)
                   nil
                 elsif a_val.nil? && !b_val.nil?
                   :defined
                 elsif !a_val.nil? && b_val.nil?
                   :undefined
                 else
                   :redefined
                 end
        unless action.nil?
          [key, { action: action, original: a_val, new: b_val }]
        end
      end.compact
    end
  end
end
