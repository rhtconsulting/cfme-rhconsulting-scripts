# @class RhconsultingModelAttributes
# @brief Simple class to ensure we don't keep unneeded/unwanted/illegal attributes
class RhconsultingModelAttributes

  # define a common set of attributes which we do not want to belong to any
  # object which is exported/imported
  #
  # NOTE: expected symbol format for elements
  COMMON_REJECTED_ATTRS = [
    :id,             # rails creates the id attribute upon import
    :created_on,     # rails creates the created_on attribute upon import
    :created_at,     # rails creates the created_at attribute upon import
    :region_number,  # rails creates the region_number attribute upon import
    :updated_at      # rails creates the updated_at attribute upon import
  ].freeze

  def self.parse_attributes(attrs_hash, addl_attrs = [])
    return {} unless attrs_hash

    rejected_attrs = [
      COMMON_REJECTED_ATTRS, 
      attr_keys_to_sym(addl_attrs)
    ].flatten

    attrs_hash.deep_symbolize_keys.except(*rejected_attrs)
  end

  private

  def self.attr_keys_to_sym(attr_keys)
    return [] unless attr_keys
    if attr_keys.is_a?(Array)
      return attr_keys.map(&:to_sym)
    elsif attr_keys.is_a?(String) || attr_keys.is_a?(Symbol)
      return [ attr_keys.to_sym ]
    else
      []
    end
  end

end # class RhconsultingModelAttributes
