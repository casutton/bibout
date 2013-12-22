# -*- coding: iso-8859-1 -*-
# -*- ruby-mode -*-
# Thin wrapper over 'bibtex-ruby' library that adds some convenience methods.

# Author:: Charles Sutton (mailto:csutton@inf.ed.ac.uk)
# Copyright:: Copyright (c) 2013 Charles Sutton
# License:: MIT

require 'bibtex'

module BibTeX

  class Bibliography

    #  Returns a list of all values of the specified field trype, across all entries in the bibliography
    #
    #  This generalizes the names method to arbitrary field types
    #
    #  Ex: all_values(:year)
    #   --> list of all years that appear in the bibliography
    def all_values(field)
      map { |e| e[field] }.flatten.compact
    end

  end

end
