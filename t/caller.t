use strict;
use warnings;

use Test::More;
use Log::Sprintf;

my $log_formatter = Log::Sprintf->new({
   category => 'DeployMethod',
   caller_clan => '^Log::Sprintf|^Awesome|^Gnarly',
   format   => '[%L] %m',
});

is($log_formatter->sprintf({ message => 'm' }), '[' . __LINE__ . '] m', 'log formats correctly');

{
   package Awesome;

   sub station {
      $log_formatter->sprintf({ message => 'm' })
   }
};

{
   package Gnarly;

   sub station {
      Awesome::station();
   }
};

is(Awesome::station, '[' . __LINE__ . '] m', 'Nesting once works correctly');
is(Gnarly::station, '[' . __LINE__ . '] m', 'Nesting twice works correctly');
done_testing;

