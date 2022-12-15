package AI::TensorFlow::Libtensorflow::Session;
# ABSTRACT: Session for driving ::Graph execution

use namespace::autoclean;
use AI::TensorFlow::Libtensorflow;
use AI::TensorFlow::Libtensorflow::Lib qw(arg);;

use AI::TensorFlow::Libtensorflow::Tensor;
use AI::TensorFlow::Libtensorflow::Output;
use FFI::Platypus::Buffer qw(window scalar_to_pointer);

my $ffi = AI::TensorFlow::Libtensorflow::Lib->ffi;
$ffi->mangler(AI::TensorFlow::Libtensorflow::Lib->mangler_default);

=construct New

TODO

=for :param
= TFGraph $graph
TODO
= TFSessionOptions $opt
TODO
= TFStatus $status

=for :returns
= TFSession
TODO

=tf_capi TF_NewSession

=cut
$ffi->attach( [ 'NewSession' => 'New' ] =>
	[
		arg 'TF_Graph' => 'graph',
		arg 'TF_SessionOptions' => 'opt',
		arg 'TF_Status' => 'status',
	],
	=> 'TF_Session' => sub {
		my ($xs, $class, @rest) = @_;
		return $xs->(@rest);
	});

=construct LoadFromSavedModel

=tf_capi TF_LoadSessionFromSavedModel

=cut
$ffi->attach( [ 'LoadSessionFromSavedModel' => 'LoadFromSavedModel' ] => [
    arg TF_SessionOptions => 'session_options',
    arg opaque => { id => 'run_options', ffi_type => 'TF_Buffer', maybe => 1 },
    arg string => 'export_dir',
    arg 'string[]' => 'tags',
    arg int => 'tags_len',
    arg TF_Graph => 'graph',
    arg opaque => { id => 'meta_graph_def', ffi_type => 'TF_Buffer', maybe => 1 },
    arg TF_Status => 'status',
] => 'TF_Session' => sub {
	my ($xs, $class, @rest) = @_;
	my ( $session_options,
		$run_options,
		$export_dir, $tags,
		$graph, $meta_graph_def,
		$status) = @rest;


	$run_options = $ffi->cast('TF_Buffer', 'opaque', $run_options)
		if defined $run_options;
	$meta_graph_def = $ffi->cast('TF_Buffer', 'opaque', $meta_graph_def)
		if defined $meta_graph_def;

	my $tags_len = @$tags;

	$xs->(
		$session_options,
		$run_options,
		$export_dir,
		$tags, $tags_len,
		$graph, $meta_graph_def,
		$status
	);
} );

=method Run

TODO

=for :param
= Maybe[TFBuffer] $run_options
TODO
= ArrayRef[TFOutput] $inputs
TODO
= ArrayRef[TFTensor] $input_values
TODO
= ArrayRef[TFOutput] $outputs
TODO
= ArrayRef[TFTensor] $output
TODO
= ArrayRef[TFOperation] $target_opers
TODO
= Maybe[TFBuffer] $run_metadata
TODO
= TFStatus $status
TODO

=tf_capi TF_SessionRun

=cut
$ffi->attach( [ 'SessionRun' => 'Run' ] =>
	[
		arg 'TF_Session' => 'session',

		# RunOptions
		arg 'opaque'  => { id => 'run_options', ffi_type => 'TF_Buffer', maybe => 1 },

		# Input TFTensors
		arg 'TF_Output_struct_array' => 'inputs',
		arg 'TF_Tensor_array' => 'input_values',
		arg 'int'             => 'ninputs',

		# Output TFTensors
		arg 'TF_Output_struct_array' => 'outputs',
		arg 'TF_Tensor_array' => 'output_values',
		arg 'int'             => 'noutputs',

		# Target operations
		arg 'opaque'         => { id => 'target_opers', ffi_type => 'TF_Operation_array', maybe => 1 },
		arg 'int'            => 'ntargets',

		# RunMetadata
		arg 'opaque'      => { id => 'run_metadata', ffi_type => 'TF_Buffer', maybe => 1 },

		# Output status
		arg 'TF_Status' => 'status',
	],
	=> 'void' => sub {
		my ($xs,
			$self,
			$run_options,
			$inputs , $input_values,
			$outputs, $output_values,
			$target_opers,
			$run_metadata,
			$status ) = @_;

		die "Mismatch in number of inputs and input values" unless $#$inputs == $#$input_values;
		my $input_v_a  = AI::TensorFlow::Libtensorflow::Tensor->_as_array(@$input_values);
		my $output_v_a = AI::TensorFlow::Libtensorflow::Tensor->_adef->create( 0+@$outputs );

		$inputs  = AI::TensorFlow::Libtensorflow::Output->_as_array( @$inputs );
		$outputs = AI::TensorFlow::Libtensorflow::Output->_as_array( @$outputs );
		$xs->($self,
			$run_options,

			# Inputs
			$inputs, $input_v_a , $input_v_a->count,

			# Outputs
			$outputs, $output_v_a, $output_v_a->count,

			_process_target_opers_args($target_opers),

			$run_metadata,

			$status
		);

		@{$output_values} = @{ AI::TensorFlow::Libtensorflow::Tensor->_from_array( $output_v_a ) };
	}
);

sub _process_target_opers_args {
	my ($target_opers) = @_;
	my @target_opers_args = defined $target_opers
		? do {
			my $target_opers_a = AI::TensorFlow::Libtensorflow::Operation->_as_array( @$target_opers );
			( $target_opers_a, $target_opers_a->count )
		}
		: ( undef, 0 );

	return @target_opers_args;
}

=method PRunSetup

=tf_capi TF_SessionPRunSetup

=cut
$ffi->attach([ 'SessionPRunSetup' => 'PRunSetup' ] => [
    arg TF_Session => 'session',
    # Input names
    arg TF_Output_struct_array => 'inputs',
    arg int => 'ninputs',
    # Output names
    arg TF_Output_struct_array => 'outputs',
    arg int => 'noutputs',
    # Target operations
    arg opaque => { id => 'target_opers', ffi_type => 'TF_Operation_array', maybe => 1 },
    arg int => 'ntargets',
    # Output handle
    arg 'opaque*' => { id => 'handle', ffi_type => 'string*', window =>  1 },
    # Output status
    arg TF_Status => 'status',
] => 'void' => sub {
	my ($xs, $session, $inputs, $outputs, $target_opers, $status) = @_;

	$inputs  = AI::TensorFlow::Libtensorflow::Output->_as_array( @$inputs );
	$outputs = AI::TensorFlow::Libtensorflow::Output->_as_array( @$outputs );

	my $handle;
	$xs->($session,
		$inputs, $inputs->count,
		$outputs, $outputs->count,
		_process_target_opers_args($target_opers),
		\$handle,
		$status,
	);

	return undef unless defined $handle;

	window( my $handle_window, $handle );

	my $handle_obj = bless \\$handle_window,
		'AI::TensorFlow::Libtensorflow::Session::_PRHandle';

	return $handle_obj;
});

=method AI::TensorFlow::Libtensorflow::Session::_PRHandle::DESTROY

=tf_capi TF_DeletePRunHandle

=cut
$ffi->attach( [ 'DeletePRunHandle' => 'AI::TensorFlow::Libtensorflow::Session::_PRHandle::DESTROY' ] => [
	arg 'opaque' => 'handle',
] => 'void' => sub {
	my ($xs, $handle_obj) = @_;
	my $handle = scalar_to_pointer($$$handle_obj);
	$xs->( $handle );
} );

=method PRun

=tf_capi TF_SessionPRun

=cut
$ffi->attach( [ 'SessionPRun' => 'PRun' ] => [
	arg TF_Session => 'session',
	arg 'opaque' => 'handle',

	# Inputs
	arg TF_Output_struct_array => 'inputs',
	arg TF_Tensor_array => 'input_values',
	arg int => 'ninputs',

	# Outputs
	arg TF_Output_struct_array => 'outputs',
	arg TF_Tensor_array => 'output_values',
	arg int => 'noutputs',

	# Targets
	arg 'opaque*' => { id => 'target_opers', ffi_type => 'TF_Operation_array', maybe => 1 },
	arg int => 'ntargets',

	arg TF_Status => 'status',
] => 'void' => sub {
	my ($xs, $session, $handle_obj,
		$inputs, $input_values,
		$outputs, $output_values,
		$target_opers,
		$status) = @_;

	die "Mismatch in number of inputs and input values" unless $#$inputs == $#$input_values;
	my $input_v_a  = AI::TensorFlow::Libtensorflow::Tensor->_as_array(@$input_values);
	my $output_v_a = AI::TensorFlow::Libtensorflow::Tensor->_adef->create( 0+@$outputs );

	$inputs  = AI::TensorFlow::Libtensorflow::Output->_as_array( @$inputs );
	$outputs = AI::TensorFlow::Libtensorflow::Output->_as_array( @$outputs );
	my $handle = scalar_to_pointer( $$$handle_obj );
	$xs->($session, $handle,
		# Inputs
		$inputs, $input_v_a , $input_v_a->count,

		# Outputs
		$outputs, $output_v_a, $output_v_a->count,

		_process_target_opers_args($target_opers),

		$status,
	);

	@{$output_values} = @{ AI::TensorFlow::Libtensorflow::Tensor->_from_array( $output_v_a ) };
} );

=method ListDevices

=tf_capi TF_SessionListDevices

=cut
$ffi->attach( [ 'SessionListDevices' => 'ListDevices' ] => [
	arg TF_Session => 'session',
	arg TF_Status => 'status',
] => 'TF_DeviceList');

=method Close

TODO

=tf_capi TF_CloseSession

=cut
$ffi->attach( [ 'CloseSession' => 'Close' ] =>
	[ 'TF_Session',
	'TF_Status',
	],
	=> 'void' );

sub DESTROY {
	my ($self) = @_;
	my $s = AI::TensorFlow::Libtensorflow::Status->New;
	$self->Close($s);
	# TODO this may not be needed with automatic Status handling
	die "Could not close session" unless $s->GetCode == AI::TensorFlow::Libtensorflow::Status::OK;
}

1;
