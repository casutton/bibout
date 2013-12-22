#  Author: Charles Sutton <csutton@inf.ed.ac.uk>
#  Created: 2008-03-03.
#  Copyright (c) 2008. All rights reserved.

require 'erb'
require 'ostruct'
require 'bibout/bibtex'

$STANDARD_FIELDS = [
:address,
:annote,
:author,
:booktitle,
:chapter,
:crossref,
:edition,
:editor,
:howpublished,
:institution,
:journal,
:month,
:number,
:organization,
:pages,
:publisher,
:school,
:series,
:title,
:type,
:volume,
:year
].freeze

class BibOut
  def initialize(template_string)
    @template_string = template_string
    @root_dir = nil
  end

  def set_root_dir(root)
    @root_dir = root
  end

  def embed(fname, hsh)
    if not @root_dir.nil?
      fname = File.join(@root_dir, fname)
    end
    File.open(fname) do |f|
      tmpl = f.read()
      bind = ErbBinding.new(hsh).get_binding()
      ERB.new(tmpl).result(bind)
    end
  end

  def minimize(entry)
    fields = entry.fields
    result = entry.clone
    fields.each do |k,v|
      if not $STANDARD_FIELDS.include? k
        result.delete k
      end
    end
    result
  end

  def result(bib)
    erb = ERB.new(@template_string)
    return erb.result(binding())
  end

end

# sort of like partials in rails
class ErbBinding < OpenStruct
    def get_binding
        return binding()
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


# main

# need to add this
#   by_year = bib.partition("year")
#   by_year = by_year.sort { |t1,t2| t2[0].to_i <=> t1[0].to_i }   


