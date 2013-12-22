require 'test/unit'
require 'bibout'

class BibliographyTest < Test::Unit::TestCase

  def setup
    current_dir = File.expand_path File.dirname(__FILE__) 
    @data_dir = File.join(current_dir, "data")
    @bib = BibTeX.open(File.join(@data_dir, "test.bib"))
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

end
