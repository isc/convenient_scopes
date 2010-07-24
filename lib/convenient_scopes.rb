module ConvenientScopes

    def method_missing(name, *args, &block)
      if scope_arg = (define_scope name)
        scope name, scope_arg
        return send name, *args, &block
      else
        super
      end
    end
    
    module Conditions
      
      def equals_scope name
        return unless (column = match_suffix_and_column_name name, %w(eq is equals))
        lambda {|value| where(column => value)}
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
        where(name => true)
      end
      
      def negative_boolean_column_scope name
        str_name = name.to_s
        return unless str_name.gsub!(/^not_/, '')
        return unless column_names.include? str_name
        return unless boolean_column? str_name
        where(str_name => false)
      end
      
    end
    
    include Conditions
    
    def association_scope name
      assoc = reflect_on_all_associations.detect {|assoc| name.to_s.starts_with? assoc.name.to_s}
      return unless assoc
      next_scope = name.to_s.split("#{assoc.name}_").last
      if scope_arg = (assoc.klass.define_scope next_scope.to_sym)
        if scope_arg.is_a? ActiveRecord::Relation
          scope_arg.joins(assoc.name)
        else
          lambda {|value| scope_arg.call(value).joins(assoc.name) }
        end
      end
    end
    
    def define_scope name
      Conditions.instance_methods.each do |scope_type|
        if scope_arg = (send scope_type.to_sym, name)
          return scope_arg unless scope_arg.nil?
        end
      end
      return association_scope name
    end
    
    def match_and_define_scope name, suffixes, sql_format, value_format = nil
      return unless (column = match_suffix_and_column_name name, suffixes)
      sql = sql_format % "#{quoted_table_name}.#{column}"
      lambda {|value| where([sql, value_format ? (value_format % value) : value])}
    end
    
    def match_and_define_scope_without_value name, suffixes, sql_format
      return unless (column = match_suffix_and_column_name name, suffixes)
      sql = sql_format % "#{quoted_table_name}.#{column}"
      where(sql)
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
end

ActiveRecord::Base.extend ConvenientScopes
ActiveRecord::Relation.send :include, ConvenientScopes
