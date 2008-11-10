class Special::Migrations::Import < ActiveRecord::Migration
  dsl_accessor :models,     :default=>[]
  dsl_accessor :model_class, :default=>proc{|klass|
    klass.name.demodulize.underscore.gsub(/^import_/,'').classify.constantize rescue
      raise "#{name} can't find class name. Please set it by 'model_class' method."}

  class << self
    def model(attribute)
      models << attribute
    end

    def concreate_model(model)
      model = model.call if model.is_a?(Proc)
      case model
      when ActiveRecord::Base then model
      when Hash               then
        returning(model_class.new(model)) do |record|
          record.id = model[model_class.primary_key] || model[model_class.primary_key.intern] || nil
        end
      else
        raise TypeError, "unknown model type. got '#{model.class}'"
      end
    end

    def up
      models.each{|model| concreate_model(model).save!}
    end

    def down
      model_class.delete_all
    end
  end
end
