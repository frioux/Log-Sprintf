use strict;
use warnings;

use Test::More;
use Log::Sprintf;

#%m{chomp} The message to be logged, stripped off a trailing newline
#%p Priority of the logging event (%p{1} shows the first letter)

#%T A stack trace of functions called

my $log_formatter = Log::Sprintf->new({
   category => 'DeployMethod',
   format   => '[%L][%p][%c] %m',
});

my $args = {
  priority => 'trace',
  message => 'starting connect',
};

is($log_formatter->sprintf($args), '[' . __LINE__ . '][trace][DeployMethod] starting connect', 'log formats correctly');

sub log_awesome {
   $log_formatter->sprintf({
     caller_depth => 5,
     priority => 'trace',
     message => 'starting connect',
   })
}

is(log_awesome(), '[' . __LINE__ . '][trace][DeployMethod] starting connect', 'log depths correctly');

done_testing;
