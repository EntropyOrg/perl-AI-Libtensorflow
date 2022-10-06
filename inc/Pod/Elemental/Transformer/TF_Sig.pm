package Pod::Elemental::Transformer::TF_Sig;
# ABSTRACT: TensorFlow signatures

use Moose;
extends 'Pod::Elemental::Transformer::List';

use lib 'lib';
use AI::TensorFlow::Libtensorflow::Lib;
use AI::TensorFlow::Libtensorflow::Lib::Types qw(-all);
use Types::Standard qw(Maybe Str);
use Type::Registry qw(t);

use namespace::autoclean;

sub __is_xformable {
  my ($self, $para) = @_;

  return unless $para->isa('Pod::Elemental::Element::Pod5::Region')
         and $para->format_name =~ /^(?:param|returns)$/;

  confess("list regions must be pod (=begin :" . $self->format_name . ")")
    unless $para->is_pod;

  return 1;
}

my %region_types = (
  'param'   => 'Parameters',
  'returns' => 'Returns',
);

around _expand_list_paras => sub {
  my ($orig, $self, $para) = @_;

  die "Need description list for @{[ $para->as_pod_string ]}"
    unless $para->children->[0]->content =~ /^=/;
  my $prefix;
  if( $para->isa('Pod::Elemental::Element::Pod5::Region')
    && exists $region_types{$para->format_name}
  ) {
    $prefix = Pod::Elemental::Element::Pod5::Ordinary->new({
      content => "B<@{[ $region_types{$para->format_name} ]}>",
    });
  }

  my @replacements = $orig->($self, $para);

  unshift @replacements, $prefix if defined $prefix;

  @replacements;
};

sub __paras_for_num_marker { die "only support definition lists" }
sub __paras_for_bul_marker { die "only support definition lists" }

around __paras_for_def_marker => sub {
  my ($orig, $self, $rest) = @_;

  my $ffi = AI::TensorFlow::Libtensorflow::Lib->ffi;
  my @types = ($rest);
  for my $type (@types) {
    if( my $which = eval { t($type); 'TT' } || eval { $ffi->type_meta($type); 'FFI' } ) {
      #print STDERR "Found $type via $which\n";
    } else {
      die "Could not find type constraint or FFI::Platypus type $type";
    }
  }

  my @replacements = $orig->($self, $rest);

  @replacements;
};

1;
