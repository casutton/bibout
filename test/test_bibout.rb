require 'test/unit'
require 'bibout'

class BiboutTest < Test::Unit::TestCase

  def setup
    current_dir = File.expand_path File.dirname(__FILE__) 
    @data_dir = File.join(current_dir, "data")
    @bib = BibTeX.open(File.join(@data_dir, "test.bib"))
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

  $BY_YEAR_RESULT = <<END


1951

Robbins, H. and Monro, S.. A stochastic approximation method. 1951.


1953

Metropolis, N. and Rosenbluth, A. and Rosenbluth, M. and Teller, A. and Teller, E.. Equations of state calculations by fast computing machines. 1953.


1979

Garey, Michael R. and Johnson, David S.. Computers and Intractability: A Guide to the Theory of NP-Completeness. 1979.


END

  def test_by_year
    root_tmpl_file = File.join(@data_dir, "by_year.tmpl")
    File.open (root_tmpl_file) do |f|
      root_tmpl = f.read
      bo = BibOut.new(root_tmpl)
      bo.set_root_dir(File.new(@data_dir))
      result = bo.result(@bib)
      assert_equal $BY_YEAR_RESULT, result
    end
  end

  $FUNNY_BIB = <<END
@book{garey:johnson,
	Address = {New York, NY, USA},
	Author = {Garey, Michael R. and Johnson, David S.},
	Publisher = {W. H. Freeman \& Co.},
	Title = {Computers and Intractability: A Guide to the Theory of NP-Completeness},
        Tags = {Classic},
        InternalCruft = xyzzy,
	Year = {1979}}
END

$CLEAN_BIB = <<END
@book{garey:johnson,
  address = {New York, NY, USA},
  author = {Garey, Michael R. and Johnson, David S.},
  publisher = {W. H. Freeman & Co.},
  title = {Computers and Intractability: A Guide to the Theory of NP-Completeness},
  year = {1979}
}
END

  def test_minimize
    bib = BibTeX.parse($FUNNY_BIB)
    entry = bib[0]

    bo = BibOut.new('')    
    entry2 = bo.minimize(entry)
    
    assert_equal $CLEAN_BIB, entry2.to_s
  end

end
