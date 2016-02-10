  Author: Marcin Gajewski

  # Overview

  This app process an input file from INPUT_PATH and classify if the flight is operating with an IATA
  or ICAO flight number. The output results in new file with path OUTPUT_PATH. Invalid entries
  are written to an error.csv file


  ## Requirements

  it require thor gem

  gem install thor


  ## Usage

  app.rb detect_code INPUT_PATH OUTPUT_PATH
