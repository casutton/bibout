#  Author: Charles Sutton <csutton@inf.ed.ac.uk>
#  Created: 2008-03-03.
#  Copyright (c) 2008. All rights reserved.

require 'erb'
require 'ostruct'
require 'bibout/bibtex'
require 'bibout/erb_binding'

# Toplevel class for processing templates.
# Delegates everything to ErbBinding
class BibOut

  # Name of a directory containing template files. 
  # This is used as the base directory when one template is embedded within another.
  attr_accessor :root_dir

  def initialize(root_dir=nil)
    @root_dir = root_dir
  end

  # Processes a file containing a bibout template.
  # Params:
  # +bib+:: Name of BibTeX file
  # +filename+:: Name of BibOut template file
  def process_file(bib, filename)
    ErbBinding.new(bib, @root_dir).embed(filename)
  end

  # Processes a string containing a bibout template.
  # Params:
  # +bib+:: Name of BibTeX file
  # +filename+:: String containing text of BibOut template
  def process_string(bib, string)
    ErbBinding.new(bib, @root_dir).process_string(string)
  end

end


