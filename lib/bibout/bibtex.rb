# -*- coding: iso-8859-1 -*-
# -*- ruby-mode -*-
# Extensions to 'bibtex-ruby' library that adds some convenience methods.

# Author:: Charles Sutton (mailto:csutton@inf.ed.ac.uk)
# Copyright:: Copyright (c) 2013 Charles Sutton
# License:: MIT


require 'bibtex'

module BibTeX

  # A list of Symbols naming fields that are commonly used in BibTeX entries.
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

  
  # This class represents a bibliography, usually a single BibTeX file.
  #
  # This is the same class as {BibTeX::Bibliography}[http://rubydoc.info/gems/bibtex-ruby/BibTeX/Bibliography] from bibtex-ruby.
  # See those class docs for more information.
  class Bibliography

    #  Returns a list of all values of the specified field type, across all entries in the bibliography
    #
    #  This generalizes the names method to arbitrary field types
    #
    #  Ex: all_values(:year)
    #   --> list of all years that appear in the bibliography
    def all_values(field)
      return map { |e| e[field] }.flatten.compact.map { |v| v.to_s }.sort.uniq
    end

    #  Returns a list of all of the Entries in this bibliography,
    #  sorted by calling the given block. Fixes a problem with the 
    #  sort_by method in the bibtex-ruby version
    #  of this class.
    def sort_by(*arguments, &block)
      data.sort_by(*arguments, &block)
    end

    #  Returns a list of all of the Entries in this bibliography,
    #  sorted by in the specified order. Fixes a problem with bibtex-ruby.
    def sort(*arguments, &block)
      data.sort(*arguments, &block)
    end

  end

  # This class represents a single entry in a bibliography.
  # This is the same class as {BibTeX::Entry}[http://rubydoc.info/gems/bibtex-ruby/BibTeX/Entry] from bibtex-ruby.
  # See those class docs for more information.
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


  # This class represents a list of names.
  # This is the same class as {BibTeX::Names}[http://rubydoc.info/gems/bibtex-ruby/BibTeX/Names] from bibtex-ruby.
  # See those class docs for more information.
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
