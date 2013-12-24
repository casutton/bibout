#  Author: Charles Sutton <csutton@inf.ed.ac.uk>
#  Created: 2008-03-03.
#  Copyright (c) 2008. All rights reserved.

require 'erb'
require 'ostruct'
require 'bibout/bibtex'
require 'bibout/erb_binding'

class BibOut
  attr_accessor :root_dir

  def initialize(root_dir=nil)
    @root_dir = root_dir
  end

  def process_file(bib, filename)
    ErbBinding.new(bib, @root_dir).embed(filename)
  end

  def process_string(bib, string)
    ErbBinding.new(bib, @root_dir).process_string(string)
  end

end


# other method

def is_workshop entry
  entry['tags'] =~ /workshop/ 
end

def is_tr entry
  entry.kind == "TechReport"
end

def is_thesis entry
  entry.kind == "PhDThesis"
end

