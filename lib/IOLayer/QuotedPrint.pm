
package IOLayer::QuotedPrint;

# Make sure we do things by the book
# Set the version info

use strict;
$IOLayer::QuotedPrint::VERSION = 0.01;

# Make sure the encoding/decoding stuff is available

use MIME::QuotedPrint (); # no need to pollute this namespace

#-----------------------------------------------------------------------
#  IN: 1 class
#      2 mode string (ignored)
#      3 file handle of PerlIO layer below (ignored)
# OUT: 1 blessed object

sub PUSHED {

# Initialize the buffer to be used
# Bless it as the object we're gonna use and return that

    my $write = '';
    return bless \$write,$_[0];
} #PUSHED

#-----------------------------------------------------------------------
#  IN: 1 instantiated object (ignored)
#      2 handle to read from
# OUT: 1 decoded string

sub FILL {

# Read the line from the handle
# Decode if there is something decode and return result or signal eof

    my $line = readline( $_[1] );
    return (defined $line) ? MIME::QuotedPrint::decode_qp( $line ) : undef;
} #FILL

#-----------------------------------------------------------------------
#  IN: 1 instantiated object (reference to buffer)
#      2 buffer to be written
#      3 handle to write to (ignored)
# OUT: 1 number of bytes "written"

sub WRITE {

# Encode whatever needs to be encoded and add to our buffer
# Return indicating we read the entire buffer

    $$_[0] .= MIME::QuotedPrint::encode_qp( $_[1] );
    return length( $_[1] );
} #WRITE

#-----------------------------------------------------------------------
#  IN: 1 instantiated object (reference to buffer)
#      2 handle to write to
# OUT: 1 flag indicating error

sub FLUSH {

# Write out what we have in the buffer
# Reset the buffer
# Return indicating success

    print {$_[1]} $$_[0] or return -1;
    $$_[0] = '';
    return 0;
} #FLUSH

# Satisfy -require-

1;

__END__

package IOLayer::QuotedPrint;

=head1 NAME

IOLayer::QuotedPrint - PerlIO layer for quoted-printable strings

=head1 SYNOPSIS

 use IOLayer::QuotedPrint;

 open( my $in,'<Via(IOLayer::QuotedPrint)','file.qp' )
  or die "Can't open file.qp for reading: $!\n";
 
 open( my $out,'>Via(IOLayer::QuotedPrint)','file.qp' )
  or die "Can't open file.qp for writing: $!\n";

=head1 DESCRIPTION

This module implements a PerlIO layer that works on files encoded in the
quoted-printable format.  It will decode from quoted-printable while reading
from a handle, and it will encode as quoted-printable while writing to a handle.

=head1 COPYRIGHT

Copyright 2002 Elizabeth Mattijsen.  Based on example that was initially
added to MIME::QuotedPrint.pm for the 5.8.0 distribution of Perl.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
