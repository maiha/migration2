class Special::Migrations::Table < ActiveRecord::Migration
  dsl_accessor :table_name,    :default=>proc{|klass| klass.name.demodulize.underscore.gsub(/^(table|create)_/,'')}
  dsl_accessor :schemas,       :default=>{}

  class << self
    delegate :column, :index, :add, :remove, :change, :options, :belongs_to, :fallback, :to=>"schema"

    def new_table(table_name, &block)
      Special::Migrations::TableSchema.new(table_name, &block)
    end

    def schema(name = table_name, &block)
      schemas[name] ||= new_table(name, &block)
    end

    def up
      schemas.values.each do |schema|
        schema.up(self)
      end
    end

    def down
      schemas.values.each do |schema|
        schema.down(self)
      end
    end

    def has_many(association_id, &block)
      singular_name    = table_name.singularize
      child_table_name = "%s_%s" % [singular_name, association_id]
      block          ||= proc{
        column singular_name + "_id", :integer
        column association_id.to_s.singularize, :string
      }
      schemas[child_table_name] = new_table(child_table_name, &block)
    end

    def habtm(ar1, ar2, table_name = nil)
      models     = [ar1, ar2]
      table_name ||= models.map{|ar| ar.to_s.tableize}.sort.join('_')

      schema(table_name) do
        models.each do |ar|
          col_name = "%s_id" % ar.to_s.underscore.split('/').last
          column col_name, :integer
          index  col_name
        end
        options[:id] = false
      end
    end
  end
end
