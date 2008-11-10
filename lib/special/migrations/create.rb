class Special::Migrations::Create < ActiveRecord::Migration
  dsl_accessor :columns,    :default=>[]
  dsl_accessor :indexes,    :default=>[]
  dsl_accessor :options,    :default=>{}
  dsl_accessor :table_name, :default=>proc{|klass| klass.name.demodulize.gsub(/^Create/,'').underscore}

  class << self
    def column(*args)
      columns << args
    end

    def index(*args)
      indexes << args
    end

    def up
      create_table table_name, options do |t|
        columns.each do |args|
          t.__send__(:column, *args)
         end
      end
      indexes.each do |args|
        add_index(table_name, *args)
      end
    end

    def down
      drop_table table_name
    end
  end
end
