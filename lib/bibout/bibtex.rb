# -*- coding: iso-8859-1 -*-
# -*- ruby-mode -*-
# Library to manipulate BibTeX bibliographies. Currently relies on
# +bibtool+ to parse and normalize the BibTeX.

# Author:: Pierre-Charles David (mailto:pcdavid@tiscali.fr)
# Copyright:: Copyright (c) 2002 Pierre-Charles David
# License:: Distributed under the same terms as Ruby
# Version:: 0.0.2, alpha status

require 'open3'

module BibTeX

  # List of fields used by standard bibtex styles
  STANDARD_FIELDS = [
                     'address',
                     'author',
                     'booktitle',
                     'chapter',
                     'crossref',
                     'edition',
                     'editor',
                     'howpublished',
                     'institution',
                     'journal',
                     'key',
                     'month',
                     'note',
                     'number',
                     'organization',
                     'pages',
                     'publisher',
                     'school',
                     'series',
                     'title',
                     'type',
                     'volume',
                     'year'
  ]

  # Mapping from standard BibTeX months abbreviations (in English and
  # in French) to the corresponding month number (from 1 to 12)
  MONTHS_ABBREVS = {
    'jan' => 1,
    'feb' => 2, 'fév' => 2, 'fev' => 2,
    'mar' => 3,
    'apr' => 4, 'avr' => 3,
    'may' => 5, 'mai' => 5,
    'jun' => 6,
    'jul' => 7, 'jui' => 7,
    'aug' => 8, 'aou' => 8,
    'sep' => 9,
    'oct' => 10,
    'nov' => 11,
    'dec' => 12, 'déc' => 12
  }

  # Removes (Bib)TeX syntax artifacts
  def cleanup(bibtex)
    return bibtex.delete("{}\\").strip().gsub(/\s+/, ' ')
  end

  def shorten(name)
    name.sub(/\S+/) do |first|
      first.gsub(/[^-]+/) { |part| part[0,1] + "." }
    end
  end

  class Bibliography
    def initialize(title = '')
      @title = title
      @entries = Array.new
    end

    attr :title, true
    attr :entries, false

    def add(entry)
      @entries << entry
    end

    def remove(entry)
      @entries.delete(entry)
    end

    def [](key)
      @entries.find { |entry| entry.key == key }
    end
    
    def length()
      @entries.length
    end

    def each
      @entries.each do |entry|
        yield(entry)
      end
    end
    
    include Enumerable

#    BIBTOOL_COMMAND = '/opt/local/bin/bibtool'
    BIBTOOL_COMMAND = '/Users/csutton/local/bin/bibtool'

    BIBTOOL_OPTIONS = [
      'quiet=on',
      'expand.macros=on',
      'print.entry.types={n}',
      'print.line.length=9999999',
      'print.indent=0',
      'print.align=0',
      'print.use.tab=off',
      'print.braces=on',
      'print.newline=0'
    ].join(' -- ')


    def Bibliography.test()
      Open3.popen3(BIBTOOL_COMMAND, '-h') do
         |stdin,stdout,stderr|
         str = stderr.read
         if str !~ /^BibTool/ then
           raise "Could not start BibTool try editing BIBTOOL_COMMAND variable\nCommand line: #{BIBTOOL_COMMAND}\n#{line}"
         end
       end
    end
 
    def Bibliography.import(fileName, title = '')
      bib = Bibliography.new(title)
      Bibliography.test()
      if not File.exists?(fileName)
         raise IOError, "File not found: #{fileName}"
      end
      # FIXME::SECURITY: quote fileName
      open("|#{BIBTOOL_COMMAND} -- #{BIBTOOL_OPTIONS} #{fileName}", "r:UTF-8") { |input|
	entry = nil; field = nil
	while line = input.gets do
#          print "DEBUG: New line #{line}" #debug
	  case line
	  when /^\@STRING/o, /^\@PREAMBLE/o, /^\@COMMENT/o
	  when /^@([a-zA-Z]*)\{[ \t]*(.*),/o # Entry start
#            print "DEBUG: New Entry #{$1}" #debug
	    entry = Entry.new($1)
	    entry.key = $2
	  when /^\}$/o		# Entry end
	    # FIXME::BUG différencier fin de champ et fin d'entrée
	    clean_fields(entry)
	    bib.add(entry)
	  when /([-a-zA-Z0-9_]*)=(.*)$/o # Field start
	    entry[field = $1] = $2
	  else			# Field content
	    if entry and field
	      entry[field] << line
	    end
	  end
	end
      }
      bib.post_process
      return bib
    end

    def export(output = STDOUT)
      formatter = IO.popen("#{BIBTOOL_COMMAND} -- 'sort.order { * = author # title # booktitle # editor # journal # series # volume # number # year # month # institution # school # organization # address # publisher # pages # keywords # abstract # note # kind # lang }'", "w+")
      self.each do |entry|
	formatter.puts entry.to_bibtex
      end
      formatter.close_write
      output.print(formatter.read)
    end
      
    def Bibliography.clean_fields(entry)
      entry.each_field do |name, content|
	content.chomp!
	content.chomp!(',')
	if content[0].chr == '{' or content[0].chr == '"'
	  entry[name] = content[1..-2]
	end
      end
    end

    def Bibliography.normalize(str)
      str.strip().gsub(/\s+/, ' ')
    end

    def post_process
      self.expand_crossrefs()
    end

    def expand_crossrefs
      self.each do |entry|
	xref = entry['crossref'] or next
	parent = self[xref] or next
	parent.each do |fieldName|
	  entry[fieldName] ||= parent[fieldName]
	end
	entry.delete('crossref')
      end
    end

    def to_bibtex
      @entries.collect do |entry|
	entry.to_bibtex
      end.join("\n\n")
    end
    
    def partition(field)
      dict = {}
      self.each do |entry|
        val = entry[field]
        if not val
          val = "nil"
        end
        if dict.has_key? val
          dict[val] << entry
        else
          dict[val] = [ entry ]
        end
      end
      
      dict.sort()
    end
    
  end
  
  class Entry
    def initialize(kind = '<generic>')
      @kind = kind
      @fields = Hash.new
    end

    attr :key, true
    attr :kind, false

    def [](fieldName)
      @fields[fieldName]
    end

    def []=(fieldName, fieldValue)
      @fields[fieldName] = fieldValue
    end

    def delete(fieldName)
      @fields.delete(fieldName)
    end
   
    include Enumerable

    def each
      @fields.each_key do |name|
	yield name
      end
    end

    def each_field
      @fields.each_pair do |name, value|
	yield name, value
      end
    end

    def has_field?(f)
      return @fields.has_key? f
    end

    include Comparable

    def <=>(other)
      diff = self.year <=> other.year
      if diff != 0
	return diff
      else
	return self.month <=> other.month
      end
    end

    def to_s
      return "[ENTRY #@kind: #@key]"
    end

    def to_bibtex
      content = @fields.keys.collect do |name|
	if name == 'month'
	  "\t#{name}\t= #{@fields[name]}"
	else
	  "\t#{name}\t= {#{@fields[name]}}"
	end
      end.join(",\n")
      return "@#@kind{\t#@key,\n" + content + "\n}"
    end

    # Convenience method to ease access/management of standard fields

    def abbreviate(field)
      if self[field]
	names = self[field].split(' and ').collect do |name|
	  shorten(name)
	end.join(' and ')
	self[field] = names
      end
    end

    def author_pretty()
      if self['author']
        names = self['author'].split(' and ').collect do |name|
          name.strip!
          name
        end
        return names.join(', ')
      else 
        return ''
      end
    end
                 
    def year
      y = self['year']
      return y ? y.to_i : 0
    end

    def month
      m = self['month']
      if m
	MONTHS_ABBREVS[m]
      else
	0
      end
    end

    def prune_nonstandard_fields
      @fields.keys.each do |field|
        if not STANDARD_FIELDS.index(field)
          self.delete(field)
        end
      end
    end

  end
end
