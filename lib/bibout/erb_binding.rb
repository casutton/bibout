# Contains variables and methods that are useful for bibout templates.
# 
# When a template is formatted using #BibOut.result or ErbBinding#embed,
# it is evaluated within the context of an ErbBinding object, 
# so all instance varaibles and methods are available within
# code blocks of the template.
class ErbBinding < OpenStruct

  # Name of the base directory for finding any sub-templates using #embed
  attr_accessor :root_dir

  # The current bibliography being processed. Of type #BibTeX::Bibliography
  attr_accessor :bib

  # Creates an Erb binding that can be used to process a template.
  # Params:
  # +bib+:: Bibliography object to run the template on
  # +root_dir+:: Name of the directory to run the template in. This is used 
  # as the "current directory" if sub-templates are called using #embed
  # +hash+:: Contains any keyword arguments that should be passed to the template
  def initialize(bib, root_dir, hash=nil)
    super(hash)
    @bib = bib
    @root_dir = root_dir
  end

  # Processes a given string as a bibout template
  # Params:
  # +tmpl+:: String containing text of template to process
  # +fname+:: Name that should be used to identify template in error messages
  # +hash+:: Contains any keyword arguments that should be passed to the template
  def process_string(tmpl, fname='(bibout)', hash=nil)
    bind = ErbBinding.new(@bib, @root_dir, hash).get_binding()
    erb = ERB.new(tmpl)
    erb.filename = fname
    erb.result(bind)
  end

  # Processes a file as a bibout template, and returns the result.
  #
  # The file is assumed to reside in the directory #@root_dir
  # Keyword options can be passed to the template.
  # The sub-template will be passed in the same bibliography as this template.
  #
  # Params:
  # +fname+:: Name of file containing template to process
  # +hash+:: Contains any keyword arguments that should be passed to the template
  def embed(fname, hash=nil)
    if not @root_dir.nil?
      fname = File.join(@root_dir, fname)
    end
    File.open(fname) do |f|
      tmpl = f.read()
      process_string(tmpl, fname, hash)
    end
  end

  # Should not be called by external users
  def get_binding
    return binding()
  end

end
