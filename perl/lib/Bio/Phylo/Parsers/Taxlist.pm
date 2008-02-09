# $Id: Taxlist.pm 4786 2007-11-28 07:31:19Z rvosa $
package Bio::Phylo::Parsers::Taxlist;
use strict;
use Bio::Phylo::Taxa;
use Bio::Phylo::Taxa::Taxon;
use Bio::Phylo::IO;
use vars qw(@ISA);
@ISA=qw(Bio::Phylo::IO);

=head1 NAME

Bio::Phylo::Parsers::Taxlist - Parses lists of taxon names. No serviceable parts
inside.

=head1 DESCRIPTION

This module is used for importing sets of taxa from plain text files, one taxon
on each line. It is called by the L<Bio::Phylo::IO|Bio::Phylo::IO> object, so
look there for usage examples. If you want to parse from a string, you
may need to indicate the field separator (default is '\n') to the
Bio::Phylo::IO->parse call:

 -fieldsep => '\n',

=begin comment

 Type    : Constructor
 Title   : new
 Usage   : my $taxlist = Bio::Phylo::Parsers::Taxlist->new;
 Function: Initializes a Bio::Phylo::Parsers::Taxlist object.
 Returns : A Bio::Phylo::Parsers::Taxlist object.
 Args    : none.

=end comment

=cut

sub _new {
    my $class = $_[0];
    my $self  = {};
    bless $self, $class;
    return $self;
}

=begin comment

 Type    : parser
 Title   : from_handle(%options)
 Usage   : $taxlist->from_handle(%options);
 Function: Reads taxon names from file, populates taxa object
 Returns : A Bio::Phylo::Taxa object.
 Args    : -handle => (\*FH), -file => (filename)
 Comments:

=end comment

=cut

*_from_handle = \&_from_both;
*_from_string = \&_from_both;

sub _from_both {
    my $self = shift;
    my %opts = @_;
    if ( !$opts{'-fieldsep'} ) {
        $opts{'-fieldsep'} = "\n";
    }
    my $taxa = Bio::Phylo::Taxa->new;
    if ( $opts{'-handle'} ) {
        while ( readline $opts{'-handle'} ) {
            chomp;
            if ($_) {
                $taxa->insert( Bio::Phylo::Taxa::Taxon->new( -name => $_ ) );
            }
        }
    }
    elsif ( $opts{'-string'} ) {
        foreach ( split /$opts{'-fieldsep'}/, $opts{'-string'} ) {
            chomp;
            if ($_) {
                $taxa->insert( Bio::Phylo::Taxa::Taxon->new( -name => $_ ) );
            }
        }
    }
    return $taxa;
}

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The taxon list parser is called by the L<Bio::Phylo::IO> object.
Look there for examples.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 REVISION

 $Id: Taxlist.pm 4786 2007-11-28 07:31:19Z rvosa $

=cut

1;