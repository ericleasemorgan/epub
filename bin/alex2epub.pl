#!/usr/bin/perl

# alex2epub - transform Alex TEI files into ePub documents

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 23, 2010 - added title page and style; calling it version 0.9
# April 21, 2010 - beginning to add transformations (in Grand Rapids)
# April 20, 2010 - first investigations; based on elm2epub.pl


# configure
use constant STYLESHEET => '/home/eric/sandbox/epub/etc/alex2html.xsl';
use constant LOGO       => '/home/eric/sandbox/epub/etc/logo.gif';


# require
use strict;
use XML::LibXML;
use XML::LibXSLT;
use XML::XPath;

# sanity check
my $directory = $ARGV[ 0 ];
my $xml       = $ARGV[ 1 ];
if ( ! $xml or ! $directory ) {

	print "Usage: $0 <directory> <tei file>\n";
	exit;
	
}


# initialize
my @contents  = ();
my @navpoints = ();
my @subjects  = ();
my $contents  = '';
my $index     = 0;
my $libxml    = XML::LibXML->new;
my $spine     = '';
my $subjects  = '';
my $xpath     = XML::XPath->new( filename => $xml );
my $xslt      = XML::LibXSLT->new;
my $navpoints = '';

# extract metadata
my $title         = $xpath->getNodeText( '/TEI.2/teiHeader/fileDesc/titleStmt/title[@type="main"]' );
my $creator       = $xpath->getNodeText( '/TEI.2/teiHeader/fileDesc/titleStmt/author/name[@type="main"]' );
my $publisher     = $xpath->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/publisher' );
my $creation_date = $xpath->getNodeText( '/TEI.2/teiHeader/profileDesc/creation/date' );
my $identifier    = $xpath->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/idno/@type' ) . ':' . $xpath->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/idno' );
my $rights        = $xpath->getNodeText( '/TEI.2/teiHeader/fileDesc/publicationStmt/availability/p' );
my $today         = &today;
foreach ( $xpath->findnodes( '/TEI.2/teiHeader/profileDesc/textClass/keywords/list/item' )->get_nodelist ) { push @subjects, $_->string_value() }
my $abstract      = $xpath->getNodeText( '/TEI.2/text/body/div1/p' );

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

# create working directory
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

# parse and process each "chapter"
my $chapters = $xpath->find( '//div1' );

print "Creating $directory/OPS/content.opf\n";
mkdir "$directory/OPS";
foreach my $chapter ( $chapters->get_nodelist ) {
	
	# save navpoints
	push @navpoints, $xpath->findvalue( './head', $chapter );
	
	# transform
	my $source     = $libxml->parse_string( $xpath->findnodes_as_string( '.', $chapter )) or croak $!;
	my $style      = $libxml->parse_file( STYLESHEET ) or croak $!;
	my $stylesheet = $xslt->parse_stylesheet( $style ) or croak $!;
	my $results    = $stylesheet->transform( $source ) or croak $!;

	# save
	$index++;
	my $filename = 'chapter-' . $index . '.xml';
	push @contents, $filename;
	open  OUT, " > $directory/OPS/$filename" or die "Can't open $filename: $!\n";
	print OUT $stylesheet->output_string( $results );
	close OUT;

}

# build the contents and spine
foreach ( @contents ) {

	my $id = $_;
	$id =~ s/\.xml//;
	$contents .= "<item id='$id' href='$_' media-type='application/xhtml+xml'/>\n";
	$spine    .= "<itemref idref='$id' linear='yes'/>\n";
	
}

# build and write contents.opf
my $content = &opf;
$content =~ s/##TITLE##/$title/g;
$content =~ s/##CREATOR##/$creator/g;
$content =~ s/##PUBLISHER##/$publisher/g;
$content =~ s/##CREATIONDATE##/$creation_date/g;
$content =~ s/##IDENTIFIER##/$identifier/g;
$content =~ s/##RIGHTS##/$rights/g;
$content =~ s/##TODAY##/$today/g;
foreach ( @subjects ) { $subjects .= "<dc:subject>$_</dc:subject>\n" }
$content =~ s/##SUBJECTS##/$subjects/g;
$content =~ s/##CONTENTS##/$contents/;
$content =~ s/##SPINE##/$spine/;
open  OUT, " > $directory/OPS/content.opf" or die "Can't open content.opf: $!\n";
print OUT $content;
close OUT;

# build the navpoints
$index        = 2;
foreach ( @navpoints ) {

	$index++;
	my $content = $contents[ $index - 3 ];
	$navpoints .= "<navPoint id='navpoint-$index' playOrder='$index'><navLabel><text>$_</text></navLabel><content src='$content'/></navPoint>\n";

}

# build and write content.ncx
print "Creating $directory/OPS/content.ncx\n";
mkdir "$directory/OPS";
my $ncx = &ncx;
$ncx =~ s/##TITLE##/$title/g;
$ncx =~ s/##CREATOR##/$creator/g;
$ncx =~ s/##IDENTIFIER##/$identifier/g;
$ncx =~ s/##NAVPOINTS##/$navpoints/g;
open  OUT, " > $directory/OPS/content.ncx" or die "Can't open content.ncx: $!\n";
print OUT $ncx;
close OUT;

# add logo
print "Adding logo\n";
mkdir "$directory/OPS/images";
link LOGO, "$directory/OPS/images/logo.gif";

# add css
print "Adding CSS\n";
mkdir "$directory/OPS/css";
open  OUT, " > $directory/OPS/css/style.css" or die "Can't open style.css: $!\n";
print OUT &css;
close OUT;

# add title page
print "Adding title page\n";
my $title_page = &titlepage;
$title_page =~ s/##TITLE##/$title/g;
$title_page =~ s/##AUTHOR##/$creator/g;
$title_page =~ s/##DATE##/$creation_date/g;
open  OUT, " > $directory/OPS/title-page.xml" or die "Can't open title page: $!\n";
print OUT $title_page;
close OUT;

# add publisher's  page
print "Adding publisher's page\n";
my $publisher_page = &publisherspage;
$publisher_page =~ s/##TODAY##/$today/g;
open  OUT, " > $directory/OPS/publisher-page.xml" or die "Can't open publisher page: $!\n";
print OUT $publisher_page;
close OUT;

# done
exit;


sub mimetype { return "application/epub+zip" }


sub css {

	return <<EOF
body {
	margin-left: 1em;
	margin-right: 1em;
}
.title-page {
	text-align: center
}
EOF

}


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


sub today {

	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	$mon++;
	if ( length( $mon ) < 2 ) { $mon = '0' . $mon }
	$year += 1900;
	return "$year-$mon-$mday";

}


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
      <item id='title-page' href='title-page.xml' media-type='application/xhtml+xml'/>
      <item id='publisher-page' href='publisher-page.xml' media-type='application/xhtml+xml'/>
      ##CONTENTS##
            
      <!-- CSS Style Sheets -->
      <item id="css" href="css/style.css" media-type="text/css"/>

      <!-- Images -->
      <item id='logo' href="images/logo.gif" media-type="image/gif" />

      <!-- NCX -->
      <item id="ncx" href="content.ncx" media-type="application/x-dtbncx+xml"/>
      
   </manifest>
   <spine toc="ncx">
      <itemref idref='title-page' linear='yes'/>
      <itemref idref='publisher-page' linear='yes'/>
      ##SPINE##
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
      <meta name="epub-creator" content="Eric Lease Morgan (Infomotions, Inc.)"/>
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
      <navPoint id='navpoint-1' playOrder='1'><navLabel><text>Title page</text></navLabel><content src='title-page.xml'/></navPoint>
      <navPoint id='navpoint-2' playOrder='2'><navLabel><text>Publisher's page</text></navLabel><content src='publisher-page.xml'/></navPoint>
      ##NAVPOINTS##
   </navMap>
</ncx>
EOF

}


sub titlepage {

	return <<EOF
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>##TITLE## / ##AUTHOR##</title>
    <link rel="stylesheet" href="css/style.css" type="text/css" />
</head>
<body>
    <div class='title-page'>
    <h1>##TITLE##</h1>
    <p>by</p>
    <h1>##AUTHOR##</h1>
    <br />
    <br />
    <p>Written in ##DATE##</p>
    </div>
</body>
</html>
EOF

}

sub publisherspage {

	return <<EOF
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Publisher's page</title>
    <link rel="stylesheet" href="css/style.css" type="text/css" />
</head>
<body>
    <div class='title-page'>
	<p>This book was published ##TODAY##</p>
	<p>by</p>
	<p>Infomotions, Inc.</p>
	<p>see also</p>
	<p><a href="http://infomotions.com/alex/">http://infomotions.com/alex/</a></p>
	<br />
	<p><img src='images/logo.gif' alt='logo' /></p>	
	<p>Infomotions Man says, "Give back to the 'Net."</p>
	</div>
	</body>
</html>
EOF

}