module ActiveRecord
  class Base
    # def validate_uniqueness_of_in_memory(collection, attrs, message)
    #   hashes = collection.inject({}) do |hash, record|
    #     key = attrs.map {|a| record.send(a).to_s }.join
    #     if key.blank? || record.marked_for_destruction?
    #       key = record.object_id
    #     end
    #     hash[key] = record unless hash[key]
    #     hash
    #   end
    #   if collection.length > hashes.length
    #     self.errors.add(:base, message)
    #   end
    # end

    def self.validate_nested_uniqueness_of(*nested_attrs)
      opts           = nested_attrs.extract_options!
      uniq_key       = opts[:uniq_key]
      case_sensitive = opts[:case_sensitive]
      scope          = opts[:scope    ] || []
      error_key      = opts[:error_key] || :nested_taken
      message        = opts[:message  ] || nil
      raise ArgumentError unless uniq_key.present?
      validates_each(nested_attrs) do |record, nested_attr, nested_values|
        dupes = Set.new
        nested_values.reject(&:marked_for_destruction?).map do |nested_val|
          dupe        = scope.each.inject({}) { |memo, (k)| memo[k] = nested_val.try(k); memo }
          dupe[uniq_key] = nested_val.try(uniq_key)
          dupe[uniq_key] = dupe[uniq_key].try(:downcase) if (case_sensitive == false && dupe[uniq_key].class == 'String')
          if dupes.member?(dupe)
            record.errors.add(:base, error_key, message: message)
          else
            dupes.add(dupe)
          end
        end
      end
    end


  end
end