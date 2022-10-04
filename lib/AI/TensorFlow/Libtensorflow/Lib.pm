package AI::TensorFlow::Libtensorflow::Lib;
# ABSTRACT: Private class for AI::TensorFlow::Libtensorflow

use strict;
use warnings;

use feature qw(state);
use FFI::CheckLib 0.28 qw( find_lib_or_die );
use Alien::Libtensorflow;
use FFI::Platypus;

sub lib {
	find_lib_or_die(
		lib => 'tensorflow',
		symbol => ['TF_Version'],
		alien => ['Alien::Libtensorflow'] );
}

sub ffi {
	state $ffi;
	$ffi ||= do {
		my $ffi = FFI::Platypus->new( api => 2 );
		$ffi->lib( __PACKAGE__->lib );

=head2 C<tensorflow/c/c_api.h>
=cut

=head3 TF_SessionOptions

=begin TF_CAPI_DEF

typedef struct TF_SessionOptions TF_SessionOptions;

=end TF_CAPI_DEF

=cut
		$ffi->type('opaque' => 'TF_SessionOptions');

=head3 TF_Graph

L<AI::TensorFlow::Libtensorflow::Graph>

=begin TF_CAPI_DEF

typedef struct TF_Graph TF_Graph;

=end TF_CAPI_DEF
=cut
		$ffi->type('object(AI::TensorFlow::Libtensorflow::Graph)' => 'TF_Graph');

=head3 TF_OperationDescription

=begin TF_CAPI_DEF

typedef struct TF_OperationDescription TF_OperationDescription;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_OperationDescription');

=head3 TF_Operation

=begin TF_CAPI_DEF

typedef struct TF_Operation TF_Operation;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_Operation');
		#$ffi->type('object(AI::TensorFlow::Libtensorflow::Operation)' => 'TF_Operation');

=head3 TF_Function

=begin TF_CAPI_DEF

typedef struct TF_Function TF_Function;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_Function');

=head3 TF_FunctionOptions

=begin TF_CAPI_DEF

typedef struct TF_FunctionOptions TF_FunctionOptions;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_FunctionOptions');

=head3 TF_ImportGraphDefOptions

=begin TF_CAPI_DEF

typedef struct TF_ImportGraphDefOptions TF_ImportGraphDefOptions;

=end TF_CAPI_DEF
=cut
		$ffi->type('object(AI::TensorFlow::Libtensorflow::ImportGraphDefOptions)' => 'TF_ImportGraphDefOptions');

=head3 TF_ImportGraphDefResults

=begin TF_CAPI_DEF

typedef struct TF_ImportGraphDefResults TF_ImportGraphDefResults;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_ImportGraphDefResults');

=head3 TF_Session

=begin TF_CAPI_DEF

typedef struct TF_Session TF_Session;

=end TF_CAPI_DEF
=cut
		$ffi->type('object(AI::TensorFlow::Libtensorflow::Session)' => 'TF_Session');

=head3 TF_DeprecatedSession

=begin TF_CAPI_DEF

typedef struct TF_DeprecatedSession TF_DeprecatedSession;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_DeprecatedSession');

=head3 TF_DeviceList

=begin TF_CAPI_DEF

typedef struct TF_DeviceList TF_DeviceList;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_DeviceList');

=head3 TF_Library

=begin TF_CAPI_DEF

typedef struct TF_Library TF_Library;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_Library');

=head3 TF_ApiDefMap

=begin TF_CAPI_DEF

typedef struct TF_ApiDefMap TF_ApiDefMap;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_ApiDefMap');

=head3 TF_Server

=begin TF_CAPI_DEF

typedef struct TF_Server TF_Server;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_Server');


=head2 C<tensorflow/c/c_api_experimental.h>
=cut

=head3 TF_CheckpointReader

=begin TF_CAPI_DEF

typedef struct TF_CheckpointReader TF_CheckpointReader;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_CheckpointReader');

=head3 TF_AttrBuilder

=begin TF_CAPI_DEF

typedef struct TF_AttrBuilder TF_AttrBuilder;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_AttrBuilder');

=head3 TF_ShapeAndType

=begin TF_CAPI_DEF

typedef struct TF_ShapeAndType TF_ShapeAndType;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_ShapeAndType');

=head3 TF_ShapeAndTypeList

=begin TF_CAPI_DEF

typedef struct TF_ShapeAndTypeList TF_ShapeAndTypeList;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_ShapeAndTypeList');


=head2 C<tensorflow/c/env.h>
=cut

=head3 TF_WritableFileHandle

=begin TF_CAPI_DEF

typedef struct TF_WritableFileHandle TF_WritableFileHandle;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_WritableFileHandle');

=head3 TF_StringStream

=begin TF_CAPI_DEF

typedef struct TF_StringStream TF_StringStream;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_StringStream');

=head3 TF_Thread

=begin TF_CAPI_DEF

typedef struct TF_Thread TF_Thread;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_Thread');

=head2 C<tensorflow/c/kernels.h>
=cut

=head3 TF_KernelBuilder

=begin TF_CAPI_DEF

typedef struct TF_KernelBuilder TF_KernelBuilder;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_KernelBuilder');

=head3 TF_OpKernelConstruction

=begin TF_CAPI_DEF

typedef struct TF_OpKernelConstruction TF_OpKernelConstruction;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_OpKernelConstruction');

=head3 TF_OpKernelContext

=begin TF_CAPI_DEF

typedef struct TF_OpKernelContext TF_OpKernelContext;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_OpKernelContext');

=head2 C<tensorflow/c/kernels_experimental.h>
=cut

=head3 TF_VariableInputLockHolder

=begin TF_CAPI_DEF

typedef struct TF_VariableInputLockHolder TF_VariableInputLockHolder;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_VariableInputLockHolder');

=head3 TF_CoordinationServiceAgent

=begin TF_CAPI_DEF

typedef struct TF_CoordinationServiceAgent TF_CoordinationServiceAgent;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_CoordinationServiceAgent');

=head2 C<tensorflow/c/tf_shape.h>
=cut

=head3 TF_Shape

=begin TF_CAPI_DEF

typedef struct TF_Shape TF_Shape;

=end TF_CAPI_DEF
=cut
		$ffi->type('opaque' => 'TF_Shape');

=head2 C<tensorflow/c/tf_status.h>
=cut

=head3 TF_Status

L<AI::TensorFlow::Libtensorflow::Status>

=begin TF_CAPI_DEF

typedef struct TF_Status TF_Status;

=end TF_CAPI_DEF
=cut
		$ffi->type('object(AI::TensorFlow::Libtensorflow::Status)' => 'TF_Status');

=head2 C<tensorflow/c/tf_tensor.h>
=cut

=head3 TF_Tensor

L<AI::TensorFlow::Libtensorflow::Tensor>

=begin TF_CAPI_DEF

typedef struct TF_Tensor TF_Tensor;

=end TF_CAPI_DEF
=cut
		$ffi->load_custom_type('::PtrObject', 'TF_Tensor' => 'AI::TensorFlow::Libtensorflow::Tensor');



		## Callbacks for deallocation
		# For TF_Buffer
		$ffi->type('(opaque,size_t)->void'        => 'data_deallocator_t');
		# For TF_Tensor
		$ffi->type('(opaque,size_t,opaque)->void' => 'tensor_deallocator_t');

		$ffi;
	};
}

sub mangler_default {
	sub {
		my ($name) = @_;
		"TF_$name";
	}
}

sub mangler_for_object {
	my ($class, $object_name) = @_;
	sub {
		my ($name) = @_;

		# constructor and destructors
		return "TF_New${object_name}" if $name eq 'New';
		return "TF_Delete${object_name}" if $name eq 'Delete';

		return "TF_${object_name}$name";
	};
}

1;