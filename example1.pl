use lib "lib";
use RDF::TrineShortcuts;
use HTML::Microformats;
use RDF::vCard;
use JSON -convert_blessed_universally;

my $html = <<'HTML';
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Example</title>
	</head>
	<body>
		<div class="vcard">
			<h1><a href="/" class="fn url">Alice Jones</a></h1>
			<p class="adr"><span class="locality">Lewes</span>, <span class="region">East Sussex</span></p>
			<div class="agent vcard">
				<span class="role">Secretary</span>
				<a class="fn email" href="mailto:bob@example.com">Bob Smith</a>
			</div>
			<div>Updated: <span class="rev">2011-01-06T11:00:00Z</span></div>
		</div>
	</body>
</html>
HTML

my $doc = HTML::Microformats->new_document($html, "http://example.com/", type=>'application/xhtml+xml')->assume_all_profiles;

my $model = rdf_parse(<<'MORE', type=>'turtle', model => $doc->model);
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix v: <http://www.w3.org/2006/vcard/ns#> .

  <http://example.com/> a v:VCard ;
     v:fn "Example.Com LLC" ;
     v:org
         [   v:organisation-name "Example.Com LLC" ;
             v:organisation-unit "Corporate Division"
         ] ;
     v:adr
         [ a v:Work ;
             v:country-name "Australia" ;
             v:locality "WonderCity" ;
             v:postal-code "5555" ;
             v:street-address "33 Enterprise Drive"
         ] ;
     v:geo
         [ v:latitude "43.33" ;
             v:longitude "55.45"
         ] ;
     v:tel
         [ a v:Fax, v:Work ;
             rdf:value "+61 7 5555 0000"
         ] ; 
     v:email <mailto:info@example.com> ;
     v:logo <http://example.com/logo.png> .
MORE

#print rdf_string($model => 'rdfxml');
#print "#######\n";

my $exporter = RDF::vCard::Exporter->new;
my @cards = $exporter->export_cards($model);
foreach my $c (@cards)
{
	print $c;
}