use Test::More;
use Test::Pod::Coverage;

my @modules = qw(RDF::vCard::Importer RDF::vCard::Exporter RDF::vCard::Entity RDF::vCard::Line);
pod_coverage_ok($_, "$_ is covered")
	foreach @modules;
done_testing(scalar @modules);

