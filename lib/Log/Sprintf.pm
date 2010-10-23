package Log::Sprintf;

use strict;
use warnings;

use Time::HiRes qw(gettimeofday tv_interval);
use String::Formatter;

sub new {
   my $self = bless $_[1]||{}, $_[0];
   $self->{last_event} = [ gettimeofday ];
   $self->{start_time} = [ gettimeofday ];
   $self->{caller_depth} ||= 4;
   return $self
}

sub formatter {
  my $self = shift;
  if (!defined $self->{formatter}) {
     $self->{formatter} = String::Formatter->new({
       input_processor => 'require_single_input',
       string_replacer => 'method_replace',
       codes => $self->codes,
     });
  }
  return $self->{formatter}
}

sub sprintf {
   my $self = shift;
   my $args = shift;

   local $self->{caller_depth} = $args->{caller_depth}
      if defined $args->{caller_depth};

   local $self->{category} = $args->{category} if defined $args->{category};
   local $self->{format}   = $args->{format}   if defined $args->{format};

   local $self->{message}  = $args->{message};
   local $self->{priority} = $args->{priority};

   my $ret = $self->formatter->format($self->{format}, $self);
   $self->{last_event} = [ gettimeofday ];

   return $ret
}

sub codes {
  return {
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
  }
}

sub milliseconds_since_start {
   int tv_interval(shift->{start_time}, [ gettimeofday ]) * 1000
}

sub milliseconds_since_last_log {
   int tv_interval(shift->{last_event}, [ gettimeofday ]) * 1000
}

sub line { shift->_caller->[2] }

sub file { shift->_caller->[1] }

sub package { shift->_caller->[0] }

sub subroutine { shift->_caller->[3] }

sub category { shift->{category} }

sub message { shift->{'message'} }

sub priority { shift->{priority} }

sub _caller { [caller $_[0]->{caller_depth}] }

sub date {
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
 $year += 1900;
 $mon++;
 return CORE::sprintf '%04d/%02d/%02d %02d:%02d:%02d', $year, $mon, $mday, $hour, $min, $sec;
}

sub host {
 require Sys::Hostname;
 return Sys::Hostname::hostname()
}

sub location {
 my $self = shift;

 my @c = @{$self->_caller};
 return "$c[3] ($c[1]:$c[2])"
}

sub newline() { "\n" }

sub pid { $$ }

1;
