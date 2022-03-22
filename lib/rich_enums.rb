require "rich_enums/version"

module RichEnums
  class Error < StandardError; end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def rich_enum(column_symbol_value_string_options)
      # rich_enum  column1: { symbol1: [value1, string1], ... }, **options
      # will transform to
      # 1. enum column1: { symbol1: value1, ...}, to define the enums along with any options provided
      # and
      # 2. Class method "column1_names" that will map the enum values to the full String description
      # and can be accessed by ClassName.<column>_names which will return a hash like { symbol1: string1, symbol2: string2 ...}
      # e.g.
      # class Enrollment
      #  include EnumMappable
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
      # 3. Instance method "column1_name" will return the String associated with the enum value
      # e = Enrollment.new
      # e.learner_payment_path_po_check! -> normal enum method to update the object with enum value
      # e.learner_payment_path      --> :po_check      -> provides the symbol associated with enum value
      # e.learner_payment_path_name --> "P.O. / Check" -> our custom method that returns the string/description
      # TODO: explore if enum options in Array format instead of Hash format will need to be handled

      raise 'rich_enum error' unless column_symbol_value_string_options.keys.count.positive?

      # extract out the column
      column = column_symbol_value_string_options.keys.first

      # extract the Enum options for the column which may be in standard enum hash format or our custom format
      symbol_value_string = column_symbol_value_string_options.delete(column)
      # at this point, only the enum options like _prefix etc. are present in the original argument
      options = column_symbol_value_string_options
      # we allow for an option called alt: to allow the users to tag the alternate mapping. Defaults to 'name'
      alt = options.delete(:alt) || 'alt_name'

      # create two hashes from the provided input - 1 to be used to define the enum and the other for the name map
      split_hash = symbol_value_string.each_with_object({ for_enum: {}, for_display: {} }) do |(symbol, value_string), obj|
        obj[:for_enum][symbol] = value_string.is_a?(Array) ? value_string.first : value_string
        obj[:for_display][symbol.to_s] = value_string.is_a?(Array) ? value_string.second : symbol.to_s
      end

      # 1. Define the Enum
      enum "#{column}": split_hash[:for_enum], **options

      # 2. Define our custom class method
      # - the data to be returned by our custom method is available os a class instance variable
      instance_variable_set("@#{column}_#{alt.pluralize}", split_hash[:for_display])
      # - the custom method is just a getter for the class instance variable
      define_singleton_method("#{column}_#{alt.pluralize}") { instance_variable_get("@#{column}_#{alt.pluralize}") }

      # 3. Define our custom instance method to show the String associated with the enum value
      define_method("#{column}_#{alt}") { self.class.send("#{column}_#{alt.pluralize}")[send(column.to_s)] }
    end
  end
end
