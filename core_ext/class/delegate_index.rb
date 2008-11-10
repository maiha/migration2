class Class
  def delegate_index(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key"
    end

    methods.each do |method|
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{method}
          #{to}[#{method.inspect}]
        end
      EOS
    end
  end
end
