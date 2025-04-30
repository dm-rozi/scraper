class DataRequestValidator
  attr_reader :url, :fields, :errors

  def initialize(params)
    @url = params[:url]
    @fields = extract_fields(params[:fields])
    @errors = []
  end

  def valid?
    validate_url
    validate_fields
    errors.empty?
  end

  private

  def extract_fields(fields_param)
    if fields_param.respond_to?(:to_unsafe_h)
      fields_param.to_unsafe_h
    else
      fields_param
    end
  end

  def validate_url
    if url.blank?
      errors << "URL is required"
    elsif !url.is_a?(String)
      errors << "URL must be a string"
    elsif !url.match?(URI::DEFAULT_PARSER.make_regexp(%w[http https]))
      errors << "URL must be a valid http(s) address"
    end
  end

  def validate_fields
    if !fields.is_a?(Hash)
      errors << "Fields must be a JSON object"
    elsif fields.empty?
      errors << "Fields cannot be empty"
    end
  end
end
