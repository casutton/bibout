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
    result = BibOut.new.process_string(@bib, @tmpl1)
    assert_equal $RESULT1, result
  end

  def test_embed
    result = BibOut.new(@data_dir).process_file(@bib, "root.tmpl")
    assert_equal $RESULT1, result
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
    result = BibOut.new(@data_dir).process_file(@bib, "by_year.tmpl")
    assert_equal $BY_YEAR_RESULT, result
  end

  $RESULT2 = <<END 

garey:johnson

robbins-monro

metropolis


garey:johnson

robbins-monro

metropolis

END

  def test_double_embed
    result = BibOut.new(@data_dir).process_file(@bib, "double_embed.tmpl")
    assert_equal $RESULT2, result
  end

$EMBED2_RESULT = <<END
<html>
   <body>
     <div id="text">


<h2>Dissertation</h2>
<ol>

   <li>Computers and Intractability: A Guide to the Theory of NP-Completeness
</li>

</ol>


      </div>
   </body>
</html>
END

  def test_embed2
    result = BibOut.new(@data_dir).process_file(@bib, "embed2_root.tmpl")
    assert_equal $EMBED2_RESULT, result
  end

end
