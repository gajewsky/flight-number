require 'thor'
require 'csv'
require_relative 'flight_row'

# Thor class used as interface to parse flights
class App < Thor
  # List of allowed csv headers
  HEADERS = %w( id carrier_code flight_number flight_date )

  desc 'detect_code INPUT_PATH OUTPUT_PATH',
    'Process an input file from INPUT_PATH and generate processed  output in new file
    with path OUTPUT_PATH.'
  def detect_code(input_path, output_path)
    # Output file
    output = CSV.open(output_path, 'w', write_headers: true, headers: HEADERS + %w(carrier_code_type))
    # File for storing errors
    errors = CSV.open('errorddd.csv', 'w', write_headers: true, headers: HEADERS + %w(error))

    CSV.foreach(input_path, headers: :first_row) do |input_row|
      FlightRow.new(input_row).process(output, errors)
    end
    puts "yay! #{output_path} and error.csv and were generated successfully!"
  end
end

App.start ARGV
