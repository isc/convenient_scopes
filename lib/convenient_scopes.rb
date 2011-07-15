module ConvenientScopes

  def method_missing(name, *args, &block)
    if scope_data = (define_scope name)
      scope name, convert_to_scope_arg(scope_data)
      send name, *args, &block
    else
      super
    end
  end

  def define_scope name
    (ScopeDefinitions.instance_methods.inject nil do |memo, scope_type|
      memo ||= send scope_type.to_sym, name
    end) || (association_scope name)
  end
  
  def search search_scopes
    res = scoped
    search_scopes.each do |name, args|
      if scopes.keys.include?(name.to_sym) || !respond_to?(name)
        res = res.send name, args unless args == false
      else
        raise InvalidScopes
      end
    end
    res
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
  
  private
  
  class InvalidScopes < Exception ; end

  module ScopeDefinitions

    SCOPE_DEFINITIONS = [ 
      [%w(does_not_equal doesnt_equal ne is_not), "%s != ?"],
      [%w(less_than lt before), "%s < ?"],
      [%w(less_than_or_equal lte), "%s <= ?"],
      [%w(greater_than gt after), "%s > ?"],
      [%w(greater_than_or_equal gte), "%s >= ?"],
      [%w(like matches contains includes), "%s like ?", "%%%s%%"],
      [%w(not_like does_not_match doesnt_match does_not_contain doesnt_contain does_not_include doesnt_include), "%s not like ?", "%%%s%%"],
      [%w(begins_with bw starts_with sw), "%s like ?", "%s%%"],
      [%w(not_begin_with does_not_begin_with doesnt_begin_with does_not_start_with doesnt_start_with), "%s not like ?", "%s%%"],
      [%w(ends_with ew), "%s like ?", "%%%s"],
      [%w(not_end_with does_not_end_with doesnt_end_with), "%s not like ?", "%%%s"],
      [%w(between), "%s >= ? AND %s < ?"]
    ]

    SCOPE_WITHOUT_VALUE_DEFINITIONS = [
      [%w(null nil missing), "%s is null"],
      [%w(not_null not_nil not_missing), "%s is not null"],
      [%w(blank not_present), "%s is null OR %s = ''"],
      [%w(not_blank present), "%s is not null AND %s <> ''"]
    ]
    
    ORDERING_SCOPE_DEFINITIONS = [
      [/^ascend_by_/, 'asc'],
      [/^descend_by_/, 'desc']
    ]

    def scopes_with_value name
      SCOPE_DEFINITIONS.inject nil do |memo, definition|
        memo ||= match_and_define_scope name, *definition
      end
    end
    
    def scopes_without_value name
      SCOPE_WITHOUT_VALUE_DEFINITIONS.inject nil do |memo, definition|
        memo ||= match_and_define_scope_without_value name, *definition
      end
    end

    def ordering_scopes name
      ORDERING_SCOPE_DEFINITIONS.inject nil do |memo, definition|
        memo ||= match_ordering_scope name, *definition
      end
    end

    def equals_scope name
      return unless (column = match_suffix_and_column_name name, %w(equals eq is))
      lambda {|value| unscoped.where(column => value)}
    end

    def boolean_column_scopes name
      str_name = name.to_s
      value = !str_name.gsub!(/^not_/, '')
      unscoped.where(str_name => value) if boolean_column? str_name
    end

  end

  include ScopeDefinitions

  def match_ordering_scope name, prefix, direction
    str_name = name.to_s
    return unless str_name.gsub!(prefix, '')
    determine_order_scope_data str_name, direction
  end

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

  def match_and_define_scope name, suffixes, sql_format, value_format = nil
    return unless (column = match_suffix_and_column_name name, suffixes)
    sql = formatted_sql column, sql_format
    lambda {|*value| unscoped.where([sql, value_format ? (value_format % value) : value].flatten) }
  end

  def match_and_define_scope_without_value name, suffixes, sql_format
    return unless (column = match_suffix_and_column_name name, suffixes)
    unscoped.where(formatted_sql column, sql_format)
  end

  def formatted_sql column, sql_format
    sql = sql_format % (["#{quoted_table_name}.#{column}"] * sql_format.each("%s").count)
  end

  def match_suffix_and_column_name name, suffixes
    str_name = name.to_s.dup
    regexp_str = suffixes.map {|suffix| "(_#{suffix})"}.join('|') + '$'
    return unless str_name.gsub!(Regexp.new(regexp_str), '')
    return unless column_names.include? str_name
    str_name
  end

  def boolean_column? name
    columns.detect {|c|c.name == name.to_s}.try(:type) == :boolean
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
