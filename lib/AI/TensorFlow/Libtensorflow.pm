package AI::TensorFlow::Libtensorflow;
# ABSTRACT: Bindings for TensorFlow deep learning library

use strict;
use warnings;

use AI::TensorFlow::Libtensorflow::Lib;
use AI::TensorFlow::Libtensorflow::DataType;
use AI::TensorFlow::Libtensorflow::Status;
use FFI::C;

my $ffi = AI::TensorFlow::Libtensorflow::Lib->ffi;
FFI::C->ffi($ffi);

$ffi->mangler(sub {
	my($name) = @_;
	"TF_$name";
});


# ::TensorFlow {{{
sub new {
	my ($class) = @_;
	bless {}, $class;
}

$ffi->attach( [ Version => 'version' ] => [], 'string' );#}}}




package AI::TensorFlow::Libtensorflow::ImportGraphDefOptions {#{{{
	FFI::C->struct( 'TF_ImportGraphDefOptions' => [
	]);

	$ffi->attach( [ 'NewImportGraphDefOptions' => '_New' ] => [] => 'TF_ImportGraphDefOptions' );

	$ffi->attach( [ 'DeleteImportGraphDefOptions' => '_Delete' ] => [] => 'TF_ImportGraphDefOptions' );
}#}}}
package AI::TensorFlow::Libtensorflow::Output {#{{{
	FFI::C->struct( 'TF_Output' => [
		oper  => 'TF_Operation',
		index => 'int',
	]);
}
#}}}
package AI::TensorFlow::Libtensorflow::Output_Array {#{{{
	FFI::C->array('TF_Output_array', [ 'TF_Output' ]);
}
#}}}

package AI::TensorFlow::Libtensorflow::Buffer {#{{{
	use FFI::Platypus::Buffer;
	use FFI::Platypus::Memory;

	FFI::C->struct( 'TF_Buffer' => [
		data => 'opaque',
		length => 'size_t',
		#_data_deallocator => 'opaque', # data_deallocator_t
		# this does not work?
		_data_deallocator => 'data_deallocator_t',
	]);

	sub data_deallocator {
		my ($self, $coderef) = shift;

		return $self->{_data_deallocator_closure} unless $coderef;

		my $closure = $ffi->closure( $coderef );

		$closure->sticky;
		$self->{_data_deallocator_closure} = $closure;

		my $opaque = $ffi->cast('data_deallocator_t', 'opaque', $closure);
		$self->_data_deallocator( $opaque );
	}

	$ffi->attach( [ 'NewBuffer' => '_New' ] => [] => 'TF_Buffer' );

	sub NewFromData { # TODO look at Python high-level API
		my ($class, $data) = @_;

		my $buf = $class->_New;

		my ($pointer, $size) = scalar_to_buffer $data;

		$buf->data( $pointer );
		$buf->length( $size );
		$buf->data_deallocator( sub {
			my ($pointer, $size) = @_;
			free $pointer;
		});

		$buf;
	}

	$ffi->attach( [ 'DeleteBuffer' => '_Delete' ] => [ 'TF_Buffer' ], 'void' );
}#}}}
package AI::TensorFlow::Libtensorflow::Graph {#{{{
	FFI::C->struct( 'TF_Graph' => [
	]);

	$ffi->attach( [ 'NewGraph' => '_New' ] => [] => 'TF_Graph' );

	$ffi->attach( [ 'DeleteGraph' => '_Delete' ] => [ 'TF_Graph' ], 'void' );

	$ffi->attach( [ 'GraphImportGraphDef'  => 'ImportGraphDef'  ] => [ 'TF_Graph', 'TF_Buffer', 'TF_ImportGraphDefOptions', 'TF_Status' ], 'void' );
	$ffi->attach( [ 'GraphOperationByName' => 'OperationByName' ] => [ 'TF_Graph', 'string' ], 'TF_Operation' );
}#}}}
package AI::TensorFlow::Libtensorflow::Tensor {#{{{

	# C: TF_NewTensor
	#
	# Constructor
	$ffi->attach( [ 'NewTensor' => '_New' ] =>
		[ 'TF_DataType', # dtype

			'int64_t[]',   # (dims)
			'int',         # (num_dims)

			'opaque',      # (data)
			'size_t',      # (len)

			'opaque',      # tensor_deallocator_t (deallocator)
			'opaque',      # (deallocator_arg)
		],
		=> 'TF_Tensor' => sub {
			my ($xs, $class,
				$dtype,
				$dims, $num_dims,
				$data, $len,
				$deallocator, $deallocator_arg,
			) = @_;
			my $deallocator_ptr = $ffi->cast( 'tensor_deallocator_t', 'opaque', $deallocator);
			my $obj = $xs->(
				$dtype,
				$dims, $num_dims,
				$data, $len,
				$deallocator_ptr, $deallocator_arg,
			);

			$obj->{PDL} = $$deallocator_arg;

			$obj;
		});


	# C: TF_AllocateTensor
	#
	# Constructor
	$ffi->attach( [ 'AllocateTensor', '_Allocate' ],
		[ 'TF_DataType', # dtype'
			'int64_t[]',   # (dims)
			'int',         # (num_dims)
			'size_t',      # (len)
		],
		=> 'TF_Tensor' => sub {
			my ($xs, $class, @rest) = @_;
			my $obj = $xs->(@rest);
		}
	);

	# C: TF_TensorData
	$ffi->attach( [ 'TensorData' => 'Data' ],
		[ 'TF_Tensor' ],
		=> 'opaque'
	);

	# C: TF_TensorByteSize
	$ffi->attach( [ 'TensorByteSize' => 'ByteSize' ],
		[ 'TF_Tensor' ],
		=> 'size_t'
	);

	# C: TF_TensorType
	$ffi->attach( [ 'TensorType' => 'Type' ],
		[ 'TF_Tensor' ],
		=> 'TF_DataType',
	);

	# C: TF_NumDims
	$ffi->attach( [ 'NumDims' => 'NumDims' ],
		[ 'TF_Tensor' ],
		=> 'int',
	);
}


#}}}

package AI::TensorFlow::Libtensorflow::SessionOptions {#{{{
	FFI::C->struct( 'TF_SessionOptions' => [
	]);

	$ffi->attach( [ 'NewSessionOptions' => '_New' ] =>
		[ ], => 'TF_SessionOptions' );
}
#}}}
package AI::TensorFlow::Libtensorflow::Session {#{{{
	FFI::C->struct( 'TF_Session' => [
	]);

	$ffi->attach( [ 'NewSession' => '_New' ] =>
		[ 'TF_Graph', 'TF_SessionOptions', 'TF_Status' ],
		=> 'TF_Session' => sub {
			my ($xs, $class, @rest) = @_;
			return $xs->(@rest);
		});
	$ffi->attach( [ 'SessionRun' => 'Run' ] =>
		[ 'TF_Session',
		'TF_Buffer',
		'TF_Output', 'TF_Tensor', 'int',
		'TF_Output', 'TF_Tensor', 'int',
		'opaque', 'int',
		'opaque',
		'TF_Status',
		],
		=> 'void' );
	$ffi->attach( [ 'CloseSession' => 'Close' ] =>
		[ 'TF_Session',
		'TF_Status',
		],
		=> 'void' );
}
#}}}

__END__

1;
# vim:fdm=marker
