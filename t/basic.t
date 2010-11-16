use strict;
use warnings;

use Test::More;
use Log::Sprintf;

my $log_formatter = Log::Sprintf->new({
   category => 'DeployMethod',
   format   => '[%p][%c] %m',
});

my $args = {
  priority => 'trace',
  message => 'starting connect',
};

is($log_formatter->sprintf($args), '[trace][DeployMethod] starting connect', 'log formats correctly');

is($log_formatter->sprintf({
   message => 'x',
   priority => 'trace',
   format => ']%{1}p[ %m',
}), ']t[ x', 'log formats correctly with arguments passed to method');

is($log_formatter->sprintf({
   message => "woot\n",
   format => '%{chomp}m',
}), 'woot', 'chomp option for %m works');

done_testing;
