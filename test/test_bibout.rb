require 'test/unit'
require 'bibout'

class BiboutTest < Test::Unit::TestCase

  def setup
    current_dir = File.expand_path File.dirname(__FILE__) 
    @data_dir = File.join(current_dir, "data")
    @bib = BibTeX::Bibliography.import(File.join(@data_dir, "test.bib"))
    @tmpl1 = <<ENDTMPL
<% bib.each do |entry| %>
<%= entry.key %>
<%end%>
ENDTMPL
  end

  $RESULT1 = <<END 

garey:johnson

robbins-monro

metropolis

END

  def test_tmpl1
    bo = BibOut.new(@tmpl1)
    result = bo.result(@bib)
    assert_equal $RESULT1, result
  end

  def test_embed
    root_tmpl_file = File.join(@data_dir, "root.tmpl")
    File.open (root_tmpl_file) do |f|
      root_tmpl = f.read
      bo = BibOut.new(root_tmpl)
      bo.set_root_dir(File.new(@data_dir))
      result = bo.result(@bib)
      assert_equal $RESULT1, result
    end
  end

end
