require 'set'

# Class representing single flight row information
class FlightRow
  # Set for validating uniquness of flight code
  UNIQ_CODES = Set.new
  # Regex for matching IATA code type
  IATA_REGEX = /^[a-zA-Z0-9_]{2}\*?$/
  # Regex for matching ICAO code type
  ICAO_REGEX = /^[a-zA-Z0-9_]{3}$/
  # Regex for general carrier code
  CARRIER_CODE_REGEX = Regexp.union([IATA_REGEX, ICAO_REGEX])

  # Raised when carrier_code is in invalid format.
  class InvalidCarrierCode < StandardError; end
  # Raised when carrier_code is not unique.
  class NotUniqueCarrierCode < StandardError; end
  # Raised when row have not all required fields.
  class RequiredFieldIsMissing < StandardError; end

  attr_reader :row

  def initialize(row)
    @row = row
  end

  # Process row, if it is valid append it to output file otherwise append it to error
  # @param [CSV] output csv file for writing processed rows
  # @param [CSV] errors csv file for writing errors
  def process(output, errors)
    validate_row!
    row << { carrier_code_type: carrier_code_type }
    output << row
  rescue => e
    row << { error: e.to_s }
    errors << row
  end

  private

  # Detect carrier code type
  # @return [String] IATA, ICAO or undefined
  def carrier_code_type
    code = row.field('carrier_code')
    return 'IATA' if code.match(IATA_REGEX)
    return 'ICAO' if code.match(ICAO_REGEX)
  end

  # Validate row
  # @raise [ArgumentError] if row contan not allowed headers
  def validate_row!
    fail ArgumentError unless row.headers == App::HEADERS
    validate_flight_date!
    not_empty_fields!
    validate_carrier_code!
  end

  # Validate flight date
  # @raise [ArgumentError] if date is invalid
  def validate_flight_date!
    return if Date.parse(row.field('flight_date'))
  end

  # Validate presence of all required fields
  # @raise [RequiredFieldIsMissing] if some required field is not present or blank
  def not_empty_fields!
    # Casting to string prevent calling #empty? on nil
    fail RequiredFieldIsMissing if App::HEADERS.any? { |header| row.field(header).to_s.empty? }
  end

  # Validate carrier_code field
  # @raise [InvalidCarrierCode] if carrier_code have invalid format
  # @raise [NotUniqueCarrierCode] if carrier_code is not unique
  def validate_carrier_code!
    code = row.field('carrier_code')
    fail InvalidCarrierCode unless code.match(CARRIER_CODE_REGEX)
    # If is not uniq and have not * suffix
    fail NotUniqueCarrierCode if UNIQ_CODES.include?(code) && code[-1, 1] != '*'
    UNIQ_CODES << code
  end
end
