use Test::More;
use Test::Pod::Coverage;

my @modules = qw(RDF::vCard::Import RDF::vCard::Export RDF::vCard::Entity RDF::vCard::Line);
pod_coverage_ok($_, "$_ is covered")
	foreach @modules;
done_testing(scalar @modules);

