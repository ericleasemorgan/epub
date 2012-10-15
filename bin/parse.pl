#!/usr/bin/perl

# configure
use constant STYLE => '/home/eric/sandbox/epub/etc/div2xhtml.xsl';

use strict;
use XML::XPath;
use XML::LibXML;
use XML::LibXSLT;

my $xml = $ARGV[ 0 ];
if ( ! $xml ) {

	print "Usage: $0 <file>\n";
	exit;
	
}

# extract
my $xp       = XML::XPath->new( filename => $xml );
my $title    = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/titleStmt/title' );
my $creator  = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/titleStmt/author' );
my $id       = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/idno/@type' ) . '-' . $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/idno' );
my $rights   = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/availability/p' );
my $abstract = $xp->getNodeText( '/TEI.2/text/body/div1/p' );
my @subjects = ();
foreach ( $xp->findnodes( '/TEI.2/teiHeader/profileDesc/textClass/keywords/list/item' )->get_nodelist ) { push @subjects, $_->string_value() }

# echo
print "    title: $title\n";
print "  creator: $creator\n";
print "       id: $id\n";
print "   rights: $rights\n";
foreach ( @subjects ) { print "  subject: $_\n" }
print " abstract: $abstract\n";

my $parser     = XML::LibXML->new;
my $xslt       = XML::LibXSLT->new;
my $style      = $parser->parse_file( STYLE )      or croak $!;
my $stylesheet = $xslt->parse_stylesheet( $style ) or croak $!;
my $div2s      = $xp->findnodes( '/TEI.2/text/body/div1/div2' );
my $div2->pos(1);
print $div2->to_literal;


#foreach ( $xp->find( '/TEI.2/text/body/div1/div2' )->get_nodelist ) {

	#print $_, "\n";
	#my $source     = $parser->parse_file( $_ )         or croak $!;
	#my $results    = $stylesheet->transform( $source ) or croak $!;
	#print $stylesheet->output_string( $results );
	
#}
