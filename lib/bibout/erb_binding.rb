# Contains variables and methods that are useful for bibout templates.
# 
# When a template is formatted using #BibOut.result or ErbBinding#embed,
# it is evaluated within the context of an ErbBinding object, 
# so all instance varaibles and methods are available within
# code blocks of the template.
class ErbBinding < OpenStruct
  attr_accessor :root_dir
  attr_accessor :bib

  def initialize(bib, root_dir, hash=nil)
    super(hash)
    @bib = bib
    @root_dir = root_dir
  end

  def process_string(tmpl, fname='(bibout)', hash=nil)
    bind = ErbBinding.new(@bib, @root_dir, hash).get_binding()
    erb = ERB.new(tmpl)
    erb.filename = fname
    erb.result(bind)
  end

  def embed(fname, hash=nil)
    if not @root_dir.nil?
      fname = File.join(@root_dir, fname)
    end
    File.open(fname) do |f|
      tmpl = f.read()
      process_string(tmpl, fname, hash)
    end
  end

  def get_binding
    return binding()
  end

end
