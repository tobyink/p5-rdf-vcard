use lib "lib";
use RDF::TrineShortcuts;
use HTML::Microformats;
use RDF::vCard::Exporter;

my $html = <<'HTML';
<div class="vcard">
	<span class="fn">Alice Jones</span>
	<p class="adr"><span class="locality">Lewes</span>, <span class="region">East Sussex</span></p>
</div>
<div class="vcard">
	<a class="fn url" href="/">Bob Smith</a>
</div>
HTML

my $doc = HTML::Microformats->new_document($html, "http://example.com/")->assume_all_profiles;

print rdf_string($doc->model => 'turtle');
print "#######\n";

my $exporter = RDF::vCard::Exporter->new;
print join "\n", $exporter->export_cards( $doc->model );

print "\n";