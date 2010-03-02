# $Id$
package Bio::Phylo::Util::DOM;
use strict;
use Bio::Phylo ();
use Bio::Phylo::Util::CONSTANT qw(_DOMCREATOR_);
use Bio::Phylo::Util::Exceptions qw( throw );
use File::Spec::Unix;
use vars qw(@ISA $DOM);

# store DOM factory object as a global here, to avoid proliferation of 
# function arguments

@ISA = qw(Bio::Phylo);

my $CONSTANT_TYPE = _DOMCREATOR_;
my (%format);
my $PERLNS = 'Bio::Phylo::Util::DOM';

=head1 NAME

Bio::Phylo::Util::DOM - Drop-in XML DOM support for C<Bio::Phylo>

=head1 SYNOPSIS

 use Bio::Phylo::Util::DOM;
 use Bio::Phylo::IO qw( parse );
 Bio::Phylo::Util::DOM->new(-format => 'twig');
 my $project = parse( -file=>'my.nex', -format=>'nexus' );
 my $nex_twig = $project->doc();

=head1 DESCRIPTION

This module adds C<to_dom> methods to L<Bio::Phylo::Util::XMLWritable>
classes, which provide NeXML-valid objects for document object model
manipulation. DOM formats currently available are C<XML::Twig> and
C<XML::LibXML>.  For any C<XMLWritable> object, use C<to_dom> in place
of C<to_xml> to create DOM nodes.

The C<doc()> method is also added to the C<Bio::Phylo::Project> class. It returns a NeXML document as a DOM object populated by the current contents of the C<Bio::Phylo::Project> object.

=head1 MOTIVATION

The NeXML parsing/writing capability of C<Bio::Phylo> goes a long way
towards wider adoption of this useful standard.

However, while C<Bio::Phylo> can write NeXML-valid XML, the way in
which it does this natively is somewhat hard-coded and therefore
restricted, and is essentially oriented toward text file output. As
such, there is a mismatch between the sophisticated C<Bio::Phylo> data
structure and its own ability to manipulate and serialize that
structure in sophisticated but interoperable ways. Finer manipulations
of XML-represented data are possible via through a variety of Perl
packages that can store and control XML according to a document
object model (DOM). Many of these packages allow extremely flexible
computation over large datasets stored in XML format, and admit the
use of XML-related facilities such as XPath and XSLT programmatically.

The purpose of C<Bio::Phylo::Util::DOM> is to introduce integrated DOM
object creation and manipulation to C<Bio::Phylo>, both to make DOM
computation in C<Bio::Phylo> more convenient, and also to provide a
platform for potentially more sophisticated C<Bio::Phylo> modules to
come.

=head1 DESIGN

Besides the notion that DOM capability should be optional for the user,
there are two main design ideas. First, for each C<Bio::Phylo> object
that can be parsed/written as NeXML (i.e., for each
C<Bio::Phylo::Util::XMLWritable> object), we provide analogous method
for creating a representative DOM object, or element. These elements
are aggregatable in a DOM document object, whose native stringifying
method can be used to generate valid NeXML. 

Second, we allow flexibility and extensibility in the choice of the
underlying DOM package, while maintaining a consistent DOM interface
that is similar in semantic and syntactic style to the accessors and
mutators that act on the C<Bio::Phylo> objects themselves. This is
achieved through the DOM::DocumentI and DOM::ElementI interfaces,
which define a minimal subset of DOM accessors and mutators, their
inputs and outputs. Concrete instances of these interface classes
provide the bindings between the abstract methods and their
counterparts in the desired DOM implementation. Currently, there are
bindings for two popular packages, C<XML::Twig> and C<XML::LibXML>.

Another priority was simplicity of use; most of the details remain
under the hood in practice. The C<Bio/Phylo/Util/DOM.pm> file defines the
C<to_dom()> method for each C<XMLWritable> package, as well as the
C<Bio::Phylo::Util::DOM> package proper. The C<DOM> object is a
factory that is used to create Element and Document objects; it is an
inside-out object that subclasses C<Bio::Phylo>. To curb the
proliferation of method arguments, a DOM factory instance (set by the
latest invocation of C<Bio::Phylo::Util::DOM-E<gt>new()>) is maintained in
a package global. This is used by default for object creation with DOM
methods if a DOM factory object is not explicitly provided in the
argument list.

The underlying DOM implementation is set with the C<DOM> factory
constructor's single argument, C<-format>. Even this can be left out;
the default implementation is C<XML::Twig>, which is already required
by C<Bio::Phylo>. Thus, for example, one can use the DOM to convert
a Nexus file to a DOM representation as follows:

 use Bio::Phylo::Util::DOM;
 use Bio::Phylo::IO qw( parse );
 Bio::Phylo::Util::DOM->new();
 my $project = parse( -file=>'my.nex', -format=>'nexus' );
 my $nex_twig =  $project->doc();
 # The end.

Underlying DOM packages are loaded at runtime as specified by the
C<-format> argument. Packages for unused formats do not need to be
installed.

=head1 INTERFACE METHODS

The minimal DOM interface specifies the following methods. Details can be obtained from the C<ElementI> and C<DocumentI> POD.

=head2 Bio::Phylo::Util::DOM::ElementI - DOM Element Interface

 get_tagname()
 set_tagname()
 get_attributes()
 set_attributes()
 clear_attributes()
 get_text()
 set_text()
 clear_text()

 get_parent()
 get_children()
 get_first_child()
 get_last_child()
 get_next_sibling()
 get_prev_sibling()
 get_elements_by_tagname()

 set_child()
 prune_child()

 to_xml_string()

=head2 Bio::Phylo::Util::DOM::DocumentI - DOM Document Interface

 get_encoding()
 set_encoding()

 get_root()
 set_root()

 get_element_by_id()
 get_elements_by_tagname()

 to_xml_string()
 to_xml_file()

=head1 METHODS

=head2 CONSTRUCTORS

=over

=item new()

 Type    : Factory constructor
 Title   : new
 Usage   : $dom = Bio::Phylo::Util::DOM->new(-format=>$format)
 Function: Create a new DOM factory
 Returns : DOM object
 Args    : format - DOM format (defaults to 'twig')

=cut

sub new {
    my $class = shift;
    my @args = @_;
    my ($format);
    if (!(@args % 2)) {
	my %args = @args;
	$format = $args{'-format'};
    }
    else {
	($format) = @args;
    }
    my $self = $class->SUPER::new(@args);
    unless ($self->get_format) {
		$self->set_format('twig'); # use XML::Twig bindings as default
    }
    $self->_load_dom_modules();
    $Bio::Phylo::Util::DOM::DOM = $self; 
    return $self;
}

=item create_element()

 Type    : Creator
 Title   : create_element
 Usage   : $elt = Bio::Phylo::Util::DOM->new_document(-format=>$format)
 Function: Create a new XML DOM element
 Returns : DOM document
 Args    : Optional:
           -tag => $tag_name
           -attr => \%attr_hash

=cut

sub create_element { 
    my $self = shift;
    my @args = @_;
    unless ($self->get_format) {
		throw 'BadArgs' => 'DOM creator format not set';
    }
    my $format = $self->get_format;
    return "Bio::Phylo::Util::DOM::Element::$format"->new(@args);
}

=item create_document()

 Type    : Creator
 Title   : create_document
 Usage   : $doc = Bio::Phylo::Util::DOM->new_document(-format=>$format)
 Function: Create a new XML DOM document
 Returns : DOM document
 Args    : Package-specific args

=cut

sub create_document {
    my $self = shift;
    my @args = @_;
    unless ($self->get_format) {
		throw 'BadArgs' => 'DOM creator format not set';
    }
    my $format = $self->get_format;
    return "Bio::Phylo::Util::DOM::Document::$format"->new(@args);
}

=item set_format()

 Type    : Mutator
 Title   : set_format
 Usage   : $dom->set_format($format)
 Function: Set the format (underlying DOM package bindings) for this object
 Returns : format designator as string
 Args    : format designator as string

=cut

sub set_format {
    my $self = shift;
    return $format{$$self} = shift;
}
    
=item get_format()

 Type    : Accessor
 Title   : get_format
 Usage   : $dom->get_format()
 Function: Get the format designator for this object
 Returns : format designator as string
 Args    : none

=cut

sub get_format {
    my $self = shift;
    return $format{$$self};
}
    
=item _load_dom_module()

 Type    : Internal
 Title   : _load_dom_modules
 Usage   : $obj->_load_dom_modules()
 Function: Loads requested DOM format packages
 Returns : True on success
 Args    : format

=cut

sub _load_dom_modules {
    # much ripped from BioPerl (Bio::Root::Root)/maj
    my $self = shift;
    my ($name, $load);
    my $fmt = $self->get_format;
    return 0 unless $fmt;
    foreach (qw( Element Document ) ) {
		$name = $PERLNS."::${_}::$fmt";
		if ($name !~ /^([\w:]+)$/) {
		    throw 'ExtensionError' => "$name is an illegal perl package name";
		} 
		else { 
		    $name = $1;
		}
	
		$load = "$name.pm";
		$load = File::Spec::Unix->catfile((split(/::/,$load)));
		eval {
		    require $load;
		};
		if ( $@ ) {
		    throw 'ExtensionError' => "Failed to load module $name. ".$@;
		}
    }
    return 1;
}

=begin comment

 Type    : Internal method
 Title   : _type
 Usage   : $node->_type;
 Function:
 Returns : CONSTANT
 Args    :

=end comment

=cut

sub _type { $CONSTANT_TYPE }

=back

=cut

=head1 SEE ALSO

The DOM creator interfaces: L<Bio::Phylo::Util::DOM::ElementI>, L<Bio::Phylo::Util::DOM::DocumentI>

=head1 AUTHOR

Mark A. Jensen  (maj -at- fortinbras -dot- us)

=head1 TODO

The C<Bio::Phylo::Annotation> class is not yet DOMized.

=cut
