#!/usr/bin/perl

# build.pl - create an epub file

# Eric Lease Morgan <eric_morgan@infomotions.com>
# Feburary 28, 2010 - first investigations (version 0.01)


# configure
use constant STYLE => '/home/eric/sandbox/epub/etc/tei2xhtml.xsl';
use constant LOGO  => '/home/eric/sandbox/epub/etc/logo.gif';

# require
use strict;
use XML::XPath;
use XML::LibXML;
use XML::LibXSLT;

# sanity check
my $directory = $ARGV[ 0 ];
my $xml       = $ARGV[ 1 ];
if ( ! $xml or ! $directory ) {

	print "Usage: $0 <directory> <tei file>\n";
	exit;
	
}

# extract metadata
my $xp            = XML::XPath->new( filename => $xml );
my $title         = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/titleStmt/title' );
my $creator       = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/titleStmt/author' );
my $publisher     = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/publisher' );
my $creation_date = $xp->getNodeText( '/TEI.2/teiHeader/profileDesc/creation/date' );
my $identifier    = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/idno/@type' ) . '-' . $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/idno' );
my $rights        = $xp->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/availability/p' );
my $today         = &today;
my @subjects  = ();
foreach ( $xp->findnodes( '/TEI.2/teiHeader/profileDesc/textClass/keywords/list/item' )->get_nodelist ) { push @subjects, $_->string_value() }
my $abstract      = $xp->getNodeText( '/TEI.2/text/body/div1/p' );

# echo
print "Metadata:\n";
print "          title - $title\n";
print "        creator - $creator\n";
print "      publisher - $publisher\n";
print "  creation date - $creation_date\n";
print "             id - $identifier\n";
print "         rights - $rights\n";
print "          today - $today\n";
foreach ( @subjects ) { print "        subject - $_\n" }

# create home directory
mkdir $directory;

# create mime-type file
print "Creating $directory/mimetype\n";
open  OUT, " > $directory/mimetype" or die "Can't open mimetype file: $!\n";
print OUT &mimetype;
close OUT;

# container.xml
print "Creating $directory/META-INF/container.xml\n";
mkdir "$directory/META-INF";
open  OUT, " > $directory/META-INF/container.xml" or die "Can't open container.xml: $!\n";
print OUT &container;
close OUT;

# content.opf
print "Creating $directory/OPS/content.opf\n";
my $content = &opf;
$content =~ s/##TITLE##/$title/g;
$content =~ s/##CREATOR##/$creator/g;
$content =~ s/##PUBLISHER##/$publisher/g;
$content =~ s/##CREATIONDATE##/$creation_date/g;
$content =~ s/##IDENTIFIER##/$identifier/g;
$content =~ s/##RIGHTS##/$rights/g;
$content =~ s/##TODAY##/$today/g;
my $subjects = '';
foreach ( @subjects ) { $subjects .= "<dc:subject>$_</dc:subject>\n" }
$content =~ s/##SUBJECTS##/$subjects/g;
mkdir "$directory/OPS";
open  OUT, " > $directory/OPS/content.opf" or die "Can't open content.opf: $!\n";
print OUT $content;
close OUT;

# content.ncx
print "Creating $directory/OPS/content.ncx\n";
my $ncx = &ncx;
$ncx =~ s/##TITLE##/$title/g;
$ncx =~ s/##CREATOR##/$creator/g;
$ncx =~ s/##IDENTIFIER##/$identifier/g;
open  OUT, " > $directory/OPS/content.ncx" or die "Can't open content.ncx: $!\n";
print OUT $ncx;
close OUT;

# content.xml
print "Creating OPS/content.xml\n";
my $parser     = XML::LibXML->new;
my $xslt       = XML::LibXSLT->new;
my $source     = $parser->parse_file( $xml )       or croak $!;
my $style      = $parser->parse_file( STYLE )      or croak $!;
my $stylesheet = $xslt->parse_stylesheet( $style ) or croak $!;
my $results    = $stylesheet->transform( $source ) or croak $!;
open  OUT, " > $directory/OPS/content.xml" or die "Can't open content.xml: $!\n";
print OUT $stylesheet->output_string( $results );
close OUT;

# add logo
print "Adding logo\n";
mkdir "$directory/OPS/images";
link LOGO, "$directory/OPS/images/logo.gif";

# done
print "Done\n";
exit;


sub container {

	return <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
   <rootfiles>
      <rootfile full-path="OPS/content.opf" media-type="application/oebps-package+xml"/>
   </rootfiles>
</container>
EOF

}


sub mimetype { return "application/epub+zip" }


sub opf {

	return <<EOF
<?xml version="1.0" encoding="UTF-8"?>

<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="EPB-UUID" version="2.0">
   <metadata xmlns:opf="http://www.idpf.org/2007/opf"
             xmlns:dc="http://purl.org/dc/elements/1.1/">
      <dc:title>##TITLE##</dc:title>
      <dc:creator opf:role="aut">##CREATOR##</dc:creator>
      <dc:date opf:event="original-publication">##CREATIONDATE##</dc:date>
      <dc:publisher>##PUBLISHER##</dc:publisher>
      <dc:date opf:event="epub-publication">##TODAY##</dc:date>
      ##SUBJECTS##
      <dc:rights>##RIGHTS##</dc:rights>
      <dc:identifier id="EPB-UUID">##IDENTIFIER##</dc:identifier>
      <dc:language>en</dc:language>
   </metadata>
   <manifest>
      <!-- Content Documents -->
      <item id="contents" href="content.xml" media-type="application/xhtml+xml"/>
            
      <!-- CSS Style Sheets -->
            
      <!-- Images -->
      <item id='logo' href="images/logo.gif" media-type="image/gif" />

      <!-- NCX -->
      <item id="ncx" href="content.ncx" media-type="application/x-dtbncx+xml"/>
      
   </manifest>
   <spine toc="ncx">
      <itemref idref="contents" linear="yes"/>
   </spine>
</package>
EOF

}


sub ncx {

	return <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ncx
  PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
   <head>
      <!--The following four metadata items are required for all
            NCX documents, including those conforming to the relaxed
            constraints of OPS 2.0-->
      <meta name="dtb:uid" content="##IDENTIFIER##"/>
      <meta name="epub-creator" content="Eric Lease Morgan"/>
      <meta name="dtb:depth" content="1"/>
      <meta name="dtb:totalPageCount" content="0"/>
      <meta name="dtb:maxPageNumber" content="0"/>
   </head>
   <docTitle>
      <text>##TITLE##</text>
   </docTitle>
   <docAuthor>
      <text>##CREATOR##</text>
   </docAuthor>
   <navMap>
      <navPoint id="navpoint-1" playOrder="1">
         <navLabel>
            <text>##TITLE##</text>
         </navLabel>
         <content src="content.xml"/>
      </navPoint>
   </navMap>
</ncx>
EOF

}

sub today {

	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	$mon++;
	if ( length( $mon ) < 2 ) { $mon = '0' . $mon }
	$year += 1900;
	return "$year-$mon-$mday";

}