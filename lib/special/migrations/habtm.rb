class Special::Migrations::Habtm < Special::Migrations::Table
  raise NotImplementedError, "Habtm has been deprecated. Use Table#habtm instead."

  dsl_accessor :models, :default=>proc{|klass|
    klass.name.demodulize.underscore.split('_', 2).map(&:classify)}

  class << self
    def setup
      models.each do |ar|
        col_name = "%s_id" % ar.to_s.underscore
        column col_name, :integer
        index  col_name
      end
      options[:id] = false
    end
  end
end
