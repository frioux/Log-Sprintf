package Log::Sprintf;

# ABSTRACT: Format strings the way Log::log4perl does, without all the weight

use strict;
use warnings;

use String::Formatter;
use syntax 'junction';

my %codes = (
  C => 'package',
  c => 'category',
  d => 'date',
  F => 'file',
  H => 'host',
  L => 'line',
  l => 'location',
  M => 'subroutine',
  m => 'message',
  n => 'newline',
  P => 'pid',
  p => 'priority',
  r => 'milliseconds_since_start',
  R => 'milliseconds_since_last_log',
  T => 'stacktrace',
);

sub new { bless $_[1]||{}, $_[0] }

sub _formatter {
  my $self = shift;
  unless (defined $self->{formatter}) {
     $self->{formatter} = String::Formatter->new({
       input_processor => 'require_single_input',
       string_replacer => 'method_replace',
       codes => $self->_codes,
     });
  }
  return $self->{formatter}
}

sub sprintf {
   my ($self, $args) = @_;

   local @{$self}{keys %$args} = values %$args;

   $self->_formatter->format($self->{format}, $self);
}

sub codes { +{} }

sub _codes { return { %codes, %{$_[0]->codes} } }

{
  no strict 'refs';
  for my $name (
    grep { $_ eq none(qw( message priority newline location )) }
    values %codes
  ) {
    *{$name} = sub { shift->{$name} }
  }
}

sub message {
   my $self  = shift;
   my $chomp = shift;
   my $m     = $self->{message};

   chomp $m if defined $chomp && $chomp eq 'chomp';

   $m
}

sub priority {
   my $self   = shift;
   my $skinny = shift;
   my $p      = $self->{priority};

   return substr $p, 0, 1 if $skinny;
   $p;
}

sub location { "$_[0]->{subroutine} ($_[0]->{file}:$_[0]->{line})" }

sub newline() { "\n" }

1;

=pod

=head1 SYNOPSIS

 my $log_formatter = Log::Sprintf->new({
   category => 'DeployMethod',
   format   => '[%L][%p][%c] %m',
 });

 $log_formatter->sprintf({
   line     => 123,
   package  => 'foo',
   priority => 'trace',
   message  => 'starting connect',
 });

Or to add or override flags, make a subclass and use it instead:

 package SuprLogr;
 use base 'Log::Sprintf';

 sub codes {
   return {
     c => 'coxyx',
     x => 'xylophone',
   }
 }

 sub coxyx { 'COXYX' }

 sub xylophone { 'doink' }

and elsewhere...

 my $log_formatter = SuprLogr->new({ format => '[%c][%x] %m' });

 $log_formatter->sprintf({ message => 'GOGOGO' });

=head1 DESCRIPTION

This module is meant as a I<mostly> drop in replacement for the log formatting
system that L<Log::log4perl> uses; it doesn't bring in all of the weight of
C<Log::log4perl> and allows you to add new flags in subclasses.

=head1 DIFFERENCES FROM LOG4PERL

Instead of C<%p{1}> for a single character priority, this uses C<%{1}p>.
Similarly, instead of C<%m{chomp}> for a message with a trailing newline
removed, this uses C<%{chomp}m>.

=head1 METHODS

=head2 new

 my $log_formatter = Log::Sprintf->new({
   category     => 'WebServer',
   format       => '[%L][%C] %m',
   priority     => 'trace',
 })

returns a freshly instantiated C<Log::Sprintf> object.  Currently it has the
following options, none of which are required.

=head3 arguments

=over 1

=item *

C<format> - the format to use for logging.  See L</formats> for what's available.

=item *

C<category> - what category we are logging to

=item *

C<priority> - the priority or level we are logging to (trace, debug, etc)

=item *

C<package> - the package you are logging from

=item *

C<date> - the date the log happened

=item *

C<file> - the file you are logging from

=item *

C<host> - the host you are logging from

=item *

C<line> - the line you are logging from

=item *

C<subroutine> - the subroutine you are logging from

=item *

C<pid> - the pid you are logging from

=item *

C<priority> - the priority (level) you are logging at

=item *

C<milliseconds_since_start> - milliseconds since program start

=item *

C<milliseconds_since_last_log> -milliseconds since previous log

=item *

C<stacktrace> - full stacktrace

=back

=head3 formats

=over 1

=item *

C<C> - L</package>

=item *

C<c> - L</category>

=item *

C<d> - L</date>

=item *

C<F> - L</file>

=item *

C<H> - L</host>

=item *

C<L> - L</line>

=item *

C<l> - L</location>

=item *

C<M> - L</subroutine>

=item *

C<m> - L</message>

=item *

C<{chomp}m> - L</message>, but with any trailing newline removed

=item *

C<n> - L</newline>

=item *

C<P> - L</pid>

=item *

C<p> - L</priority>

=item *

C<{1}p> - L</priority>, but just the first character

=item *

C<r> - L</milliseconds_since_start>

=item *

C<R> - L</milliseconds_since_last_log>

=item *

C<T> - L</stacktrace>

=back

=head2 sprintf

Takes the exact same arguments as L</new> with the additional C<message>
argument.  Returns a formatted string.  Note that if a flag is included in your
format but its corresponding value is not included in the call to sprintf you
will get lots of warnings.

=head1 SUBCLASSING

This module was designed from the start to be subclassed.  All you need to know
to subclass it (to add or change formatting codes) is that the C<codes>
subroutine should be defined in your subclass, and should return a hashref
where keys are codes and values are the names of methods your class defines to
fill in the values of those codes.

=head1 MESSAGE METHODS

=head2 milliseconds_since_start

returns milliseconds since instantiation

=head2 milliseconds_since_last_log

returns milliseconds since last log

=head2 line

returns line

=head2 file

returns file

=head2 package

returns package

=head2 subroutine

returns subroutine

=head2 category

returns category

=head2 message

returns message; if passed "chomp" it will remove a trailing newline from
message

=head2 priority

returns priority; if passed a true value it will only return the first character

=head2 date

returns date

=head2 host

returns host

=head2 location

returns location (as in "C<< $subroutine $file:$line >>")

=head2 newline

returns newline

=head2 pid

returns process id

=head1 SEE ALSO

=over 2

=item L<Log::Log4perl>

this module has a lot of really neat ideas

=item L<Log::Structured>

=back

you can use this module to fill in the values for L</sprintf>
