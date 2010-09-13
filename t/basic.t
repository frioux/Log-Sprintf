use strict;
use warnings;

use Test::More;
use Log::Sprintf;

#%m{chomp} The message to be logged, stripped off a trailing newline
#%p Priority of the logging event (%p{1} shows the first letter)

#%T A stack trace of functions called

my $log_formatter = Log::Sprintf->new({
   category => 'DeployMethod',
   format   => '[%p][%c] %m',
});

is($log_formatter->sprintf({
  priority => 'trace',
  message => 'starting connect',
}), '[trace][DeployMethod] starting connect', 'log formats correctly');

done_testing;
