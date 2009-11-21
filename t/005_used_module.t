#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Module::Used;

my $used = Test::Module::Used->new(
    module_dir => ['t/lib'],
);
is_deeply([$used->_target_files], ['t/lib/SampleModule.pm']);
is_deeply([$used->_used_modules()], [qw(Net::FTP Module::Used Test::Module::Used)]);
is($used->_version_from_file(), '5.00803'); # perl version specified in t/lib/SampleModule.pm

is_deeply( [Test::Module::Used::_remove_core('5.00803', qw(Net::FTP Module::Used Test::Module::Used))],
           ['Module::Used', 'Test::Module::Used'] );
done_testing();


