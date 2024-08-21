require "rich_enums/version"

module RichEnums
  class Error < StandardError; end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def rich_enum(column_symbol_value_string_options)
      # rich_enum  column1: { symbol1: [value1, string1], ... }, alt: 'name', **options
      # will transform to
      # 1. enum column1: { symbol1: value1, ...}, to define the enums along with any options provided
      # and
      # 2. Class method "column1_names" that will map the enum values to the full String description
      # and can be accessed by ClassName.<column>_names which will return a hash like { symbol1: string1, symbol2: string2 ...}
      # 3. Class method "column1_alt_name_to_ids" will map the enum values the string values and can
      # be accessed by ClassName.<column>_alt_name_to_ids which will return a hash like { string1: value1, string2: value2 ...}
      # e.g.
      # class Enrollment
      #  include RichEnums
      #  rich_enum learner_payment_path: {
      #     greenfig_online: [10, 'GreenFig Online'],
      #     partner: [20, 'Partner'],
      #     partner_online: [30, 'Partner Online'],
      #     po_check: [40, 'P.O. / Check'],
      #     other: [100, 'Other']
      #   }, _prefix: true
      # end
      # will result in i. enum definitions for learner_payment_path and
      # ii. a class method called learner_payment_path_names
      # Calling learner_payment_path_names returns
      # {"greenfig_online"=>"GreenFig Online", "partner"=>"Partner", "partner_online"=>"Partner Online",
      # "po_check"=>"P.O. / Check", "other"=>"Other"}
      # iii. a class method called learner_payment_path_alt_name_to_ids
      # Calling learner_payment_path_alt_name_to_ids returns
      # {"GreenFig Online"=>10, "Partner"=>20, "Partner Online"=>30, "P.O. / Check"=>40, "Other"=>100}
      # 3. Instance method "column1_name" will return the String associated with the enum value
      # e = Enrollment.new
      # e.learner_payment_path_po_check! -> normal enum method to update the object with enum value
      # e.learner_payment_path      --> :po_check      -> provides the symbol associated with enum value
      # e.learner_payment_path_name --> "P.O. / Check" -> our custom method that returns the string/description
      # TODO: explore if enum options in Array format instead of Hash format will need to be handled

      unless column_symbol_value_string_options.is_a? Hash
        raise RichEnums::Error
      end
      if column_symbol_value_string_options.keys.count.zero?
        raise RichEnums::Error
      end

      # extract out the column
      column = column_symbol_value_string_options.keys.first

      # extract the Enum options for the column which may be in standard enum hash format or our custom format
      symbol_value_string = column_symbol_value_string_options.delete(column)

      raise RichEnums::Error unless symbol_value_string.is_a? Hash

      # at this point, only the enum options like _prefix etc. are present in the original argument
      options = column_symbol_value_string_options
      # we allow for an option called alt: to allow the users to tag the alternate mapping. Defaults to 'alt_name'
      alt = options.delete(:alt).to_s || 'alt_name'
      alt_map_method = 'alt_name_to_ids'

      # create two hashes from the provided input - 1 to be used to define the enum and the other for the name map
      split_hash = symbol_value_string.each_with_object({ for_enum: {}, for_display: {}, for_filter: {} }) do |(symbol, value_string), obj|
        value = value_string.is_a?(Array) ? value_string.first : value_string
        display_string = value_string.is_a?(Array) ? value_string.second : symbol.to_s

        obj[:for_enum][symbol] = value
        obj[:for_display][symbol.to_s] = display_string
        obj[:for_filter][display_string] = value
      end

      # 1. Define the Enum
      if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('7.2')
        enum column, split_hash[:for_enum], **options
      else
        enum "#{column}": split_hash[:for_enum], **options
      end

      # 2. Define our custom class methods
      # - the data to be returned by our custom methods is available as a class instance variable
      instance_variable_set("@#{column}_#{alt.pluralize}", split_hash[:for_display])
      instance_variable_set("@#{column}_#{alt_map_method}", split_hash[:for_filter])

      # - the custom methods are just a getter for the class instance variables
      define_singleton_method("#{column}_#{alt.pluralize}") { instance_variable_get("@#{column}_#{alt.pluralize}") }
      define_singleton_method("#{column}_#{alt_map_method}") { instance_variable_get("@#{column}_#{alt_map_method}") }

      # 3. Define our custom instance method to show the String associated with the enum value
      define_method("#{column}_#{alt}") { self.class.send("#{column}_#{alt.pluralize}")[send(column.to_s)] }
    end
  end
end
