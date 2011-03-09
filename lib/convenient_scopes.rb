module ConvenientScopes

  def method_missing(name, *args, &block)
    if scope_data = (define_scope name)
      scope name, convert_to_scope_arg(scope_data)
      return send name, *args, &block
    else
      super
    end
  end

  module Conditions

    def equals_scope name
      return unless (column = match_suffix_and_column_name name, %w(equals eq is))
      lambda {|value| unscoped.where(column => value)}
    end

    def does_not_equal_scope name
      match_and_define_scope name, %w(does_not_equal doesnt_equal ne is_not), "%s != ?"
    end

    def less_than_scope name
      match_and_define_scope name, %w(less_than lt before), "%s < ?"
    end

    def less_than_or_equal_scope name
      match_and_define_scope name, %w(less_than_or_equal lte), "%s <= ?"
    end

    def greater_than_scope name
      match_and_define_scope name, %w(greater_than gt after), "%s > ?"
    end

    def greater_than_or_equal_scope name
      match_and_define_scope name, %w(greater_than_or_equal gte), "%s >= ?"
    end

    def like_scope name
      match_and_define_scope name, %w(like matches contains includes), "%s like ?", "%%%s%%"
    end

    def not_like_scope name
      suffixes = %w(not_like does_not_match doesnt_match does_not_contain doesnt_contain does_not_include doesnt_include)
      match_and_define_scope name, suffixes, "%s not like ?", "%%%s%%"
    end

    def begins_with_scope name
      match_and_define_scope name, %w(begins_with bw starts_with sw), "%s like ?", "%s%%"
    end

    def not_begin_with_scope name
      suffixes = %w(not_begin_with does_not_begin_with doesnt_begin_with does_not_start_with doesnt_start_with)
      match_and_define_scope name, suffixes, "%s not like ?", "%s%%"
    end

    def ends_with_scope name
      match_and_define_scope name, %w(ends_with ew), "%s like ?", "%%%s"
    end

    def not_end_with_scope name
      match_and_define_scope name, %w(not_end_with does_not_end_with doesnt_end_with), "%s not like ?", "%%%s"
    end

    def null_scope name
      match_and_define_scope_without_value name, %w(null nil missing), "%s is null"
    end

    def not_null_scope name
      match_and_define_scope_without_value name, %w(not_null not_nil not_missing), "%s is not null"
    end

    def boolean_column_scope name
      return unless column_names.include? name.to_s
      return unless boolean_column? name
      unscoped.where(name => true)
    end

    def negative_boolean_column_scope name
      str_name = name.to_s
      return unless str_name.gsub!(/^not_/, '')
      return unless column_names.include? str_name
      return unless boolean_column? str_name
      unscoped.where(str_name => false)
    end

  end

  include Conditions

  module Ordering
    
    def ascend_by_scope name
      ordering_scope name, /^ascend_by_/, 'asc'
    end
    
    def descend_by_scope name
      ordering_scope name, /^descend_by_/, 'desc'
    end
    
  end
  
  def ordering_scope name, prefix, direction
    str_name = name.to_s
    return unless str_name.gsub!(prefix, '')
    determine_order_scope_data str_name, direction
  end
  
  def determine_order_scope_data name, direction
    if column_names.include? name.to_s
      unscoped.order("#{quoted_table_name}.#{name} #{direction}")
    elsif assoc = (possible_association_for_scope name)
      next_scope = extract_next_scope name, assoc
      scope_arg = assoc.klass.determine_order_scope_data next_scope, direction
      scope_arg.is_a?(Array) ? [assoc.name] + scope_arg : [assoc.name, scope_arg] if scope_arg
    end    
  end
  
  include Ordering

  def association_scope name
    return unless assoc = (possible_association_for_scope name)
    next_scope = extract_next_scope name, assoc
    scope_arg = (assoc.klass.define_scope next_scope) || assoc.klass.scopes[next_scope]
    scope_arg.is_a?(Array) ? [assoc.name] + scope_arg : [assoc.name, scope_arg] if scope_arg
  end

  def possible_association_for_scope name
    reflect_on_all_associations.detect {|assoc| name.to_s.starts_with? assoc.name.to_s}
  end
  
  def extract_next_scope name, assoc
    name.to_s.split(/^#{assoc.name}_/).last.to_sym
  end
  
  def define_scope name
    [Conditions, Ordering].map(&:instance_methods).flatten.each do |scope_type|
      if scope_arg = (send scope_type.to_sym, name)
        return scope_arg
      end
    end
    association_scope name
  end

  def match_and_define_scope name, suffixes, sql_format, value_format = nil
    return unless (column = match_suffix_and_column_name name, suffixes)
    sql = formatted_sql column, sql_format
    lambda {|value| unscoped.where([sql, value_format ? (value_format % value) : value])}
  end

  def match_and_define_scope_without_value name, suffixes, sql_format
    return unless (column = match_suffix_and_column_name name, suffixes)
    unscoped.where(formatted_sql column, sql_format)
  end

  def formatted_sql column, sql_format
    sql = sql_format % "#{quoted_table_name}.#{column}"
  end

  def match_suffix_and_column_name name, suffixes
    str_name = name.to_s
    regexp_str = suffixes.map {|suffix| "(_#{suffix})"}.join('|') + '$'
    return unless str_name.gsub!(Regexp.new(regexp_str), '')
    return unless column_names.include? str_name
    str_name
  end

  def boolean_column? name
    columns.detect {|c|c.name == name.to_s}.type == :boolean
  end

  def convert_to_scope_arg scope_data
    return scope_data unless scope_data.is_a? Array
    relation_or_proc = scope_data.pop
    joins_arg = (scope_data.size == 1) ? scope_data.first : {scope_data.first => scope_data.last}
    if relation_or_proc.is_a? ActiveRecord::Relation
      relation_or_proc.joins joins_arg
    else
      lambda {|*value| relation_or_proc.call(*value).joins joins_arg }
    end
  end
  
end

ActiveRecord::Base.extend ConvenientScopes
ActiveRecord::Relation.send :include, ConvenientScopes
