package RDF::vCard::Exporter;

use 5.008;
use common::sense;

use RDF::TrineShortcuts qw[:all];

# kinda constants
sub V    { return 'http://www.w3.org/2006/vcard/ns#' . shift; }
sub VX   { return 'http://buzzword.org.uk/rdf/vcardx#' . shift; }
sub RDF  { return 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' . shift; }

sub new
{
	my ($class, %options) = @_;
	bless { %options }, $class;
}

sub export_cards
{
	my ($self, $model) = @_;
	$model = RDF::TrineShortcuts::rdf_parse($model);
	
	my @subjects =  $model->subjects(rdf_resource(RDF('type')), rdf_resource(V('VCard')));
	push @subjects, $model->subjects(rdf_resource(V('fn')), undef);
	
	my %subjects = map { flatten_node($_) => $_ } @subjects;
	
	my @cards;
	foreach my $s (values %subjects)
	{
		my $card = ["BEGIN:VCARD"];
		my $triples = $model->get_statements($s, undef, undef);
		while (my $triple = $triples->next)
		{
			next unless (substr($triple->predicate->uri, 0, length(&V)) eq &V or substr($triple->predicate->uri, 0, length(&VX)) eq &VX);

			if ($triple->predicate->uri eq V('adr'))
				{ push @$card, $self->_export_adr($model, $triple); }
			elsif ($triple->predicate->uri eq V('n'))
				{ push @$card, $self->_export_n($model, $triple); }
			elsif (! $triple->object->is_blank)
				{ push @$card, $self->_export_simple($model, $triple); }
		}
		push @$card, "END:VCARD";
		push @cards, join "\n", @$card;
	}
	
	return @cards;
}

sub _export_simple
{
	my ($self, $model, $triple) = @_;
	
	my $prop = 'x-data';
	if ($triple->predicate->uri =~ m/([^\#\/]+)$/)
	{
		$prop = $1;
	}
	
	return sprintf("%s:%s", uc $prop, flatten_node($triple->object));
}

sub _export_adr
{
	my ($self, $model, $triple) = @_;
	
	my $adr;
	foreach my $part (qw(post-office-box extended-address street-address locality
		region postal-code country-name))
	{
		my @objects = $model->objects($triple->object, rdf_resource(V($part)));
		$adr .= join ",", map { flatten_node($_) } @objects;
		$adr .= ";"
	}
	$adr =~ s/;+$//;
	
	# todo: types
	return "ADR:$adr";
}

sub _export_n
{
	my ($self, $model, $triple) = @_;
	
	my $n;
	foreach my $part (qw(family-name given-name additional-name honorific-prefix honorific-suffix))
	{
		my @objects = $model->objects($triple->object, rdf_resource(V($part)));
		$n .= join ",", map { flatten_node($_) } @objects;
		$n .= ";"
	}
	$n =~ s/;+$//;
	
	return "N:$n";
}

1;

__END__

=head1 NAME

RDF::vCard::Exporter - export RDF data to vCard format

=head1 DESCRIPTION

This module expects RDF models to contain data using the W3C vCard vocabulary.


