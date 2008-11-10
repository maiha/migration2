class Special::Migrations::TableSchema
  attr_accessor :columns, :options, :table_name, :up_commands, :down_commands

  def initialize(table_name, &block)
    @table_name = table_name
    @columns    = []
    @options    = {}
    @up_commands = []
    @down_commands = []
    @fallback   = :error
    instance_eval(&block) if block
  end

  def fallback(*args)
    if args.empty?
      @fallback
    else
      @fallback = args.first
    end
  end

  def column(*args)
    columns << args
  end

  def index(*args)
    up_commands   << [:add_index,    table_name, *args]
    down_commands << [:remove_index, table_name, args.first]
  end

  def add(*args)
    up_commands   << [:add_column,    table_name, *args]
    down_commands << [:remove_column, table_name, args.first]
  end

  def remove(*args)
    up_commands << [:remove_column, table_name, *args]
  end

  def change(*args)
    up_commands << [:change_column, table_name, *args]
  end

  def belongs_to(klass, name = nil)
    name ||= klass.name.demodulize.singularize.underscore + "_id"
    column name, :integer
    index name
  end

  def do_fallback(err)
    case @fallback
    when :none                  # nop
    when :log
      ActiveRecord::Base.logger.warn "Migration Error(%s): %s" % [err.class, err.message]
    else
      raise
    end
  end

  def up_table(migration)
    return false if columns.empty?
    migration.create_table table_name, options do |t|
      columns.each do |args|
        t.__send__(:column, *args)
      end
    end
  rescue => err
    do_fallback(err)
  end

  def up_alter(migration)
    up_commands.each do |args|
      alter_command(migration, *args)
    end
  end

  def alter_command(migration, *args)
    migration.__send__(*args)
  rescue => err
    do_fallback(err)
  end

  def up(migration)
    up_table(migration)
    up_alter(migration)
  end

  def down_table(migration)
    return false if columns.empty?
    migration.drop_table table_name
  rescue => err
    do_fallback(err)
  end

  def down_alter(migration)
    down_commands.reverse_each do |args|
      alter_command(migration, *args)
    end
  end

  def down(migration)
    down_alter(migration)
    down_table(migration)
  end
end
