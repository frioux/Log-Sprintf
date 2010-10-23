use strict;
use warnings;

use Test::More;
use Log::Sprintf;

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

is($log_formatter->sprintf({
   message => 'x',
   priority => 'trace',
   format => ']%{1}p[ %m',
}), ']t[ x', 'log formats correctly with arguments passed to method');

is($log_formatter->sprintf({
   message => "woot\n",
   format => '%{chomp}m',
}), 'woot', 'chomp option for %m works');

sub log_awesome {
   $log_formatter->sprintf({
     caller_depth => 1,
     priority => 'trace',
     message => 'starting connect',
   })
}

is(log_awesome(), '[' . __LINE__ . '][trace][DeployMethod] starting connect', 'log depths correctly');

done_testing;
