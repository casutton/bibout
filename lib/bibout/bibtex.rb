# -*- coding: iso-8859-1 -*-
# -*- ruby-mode -*-
# Extensions to 'bibtex-ruby' library that adds some convenience methods.

# Author:: Charles Sutton (mailto:csutton@inf.ed.ac.uk)
# Copyright:: Copyright (c) 2013 Charles Sutton
# License:: MIT


require 'bibtex'

module BibTeX

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

  class Bibliography

    #  Returns a list of all values of the specified field trype, across all entries in the bibliography
    #
    #  This generalizes the names method to arbitrary field types
    #
    #  Ex: all_values(:year)
    #   --> list of all years that appear in the bibliography
    def all_values(field)
      return map { |e| e[field] }.flatten.compact.map { |v| v.to_s }.sort.uniq
    end

  end

  class Entry

    # Returns a copy of this entry that has all non-standard BibTeX fields removed.
    def minimize
      result = clone
      fields.each do |k,v|
              if not $STANDARD_FIELDS.include? k
                result.delete k
              end
            end
      result
    end

  end


  class Names

    # Returns a string containing the list of names in first-last order,
    # correctly delimited by commas and and
    def pretty(options={})
      names = map { |n| n.display_order(options) }
      return to_s if names.nil? or names.length < 1
      return names[0].to_s if names.length == 1
      names[0..-2].join(", ") + " and " + names[-1]
    end

  end


end
