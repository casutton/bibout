require 'test/unit'
require 'bibout'

class BibliographyTest < Test::Unit::TestCase

  def setup
    current_dir = File.expand_path File.dirname(__FILE__) 
    @data_dir = File.join(current_dir, "data")
    @bib = BibTeX.open(File.join(@data_dir, "test.bib"))
    @bib_sutton = BibTeX.open(File.join(@data_dir, "sutton.bib"), :format => :latex)
  end

  def test_years
    years = @bib.all_values(:year).sort
    assert_equal ["1951", "1953", "1979"], years
  end

  def test_all_values2
    vols = @bib.all_values(:volume).sort
    assert_equal ["21", "22"], vols
  end

  def test_names_pretty
    e = @bib["robbins-monro"]
    name_str = e.author.pretty
    assert_equal "H. Robbins and S. Monro", name_str

    e = @bib["metropolis"]
    name_str = e.author.pretty
    assert_equal "N. Metropolis, A. Rosenbluth, M. Rosenbluth, A. Teller and E. Teller", name_str
  end

  def test_names_single_pretty
    e = @bib_sutton["sutton:thesis"]
    assert_equal "Charles Sutton", e.author.pretty
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
    entry = BibTeX.parse($FUNNY_BIB)[0]
    entry2 = entry.minimize
    assert_equal $CLEAN_BIB, entry2.to_s
  end

end
