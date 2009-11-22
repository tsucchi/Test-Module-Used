#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests=>6;

use Test::Module::Used;

my $used = Test::Module::Used->new(
    module_dir => ['testdata/lib'],
    test_dir   => ['testdata/t'],
);
is_deeply([$used->_module_files], ['testdata/lib/SampleModule.pm']);
is_deeply([$used->_test_files],   ['testdata/t/001_test.t']);
is_deeply([$used->_used_modules()], [qw(Net::FTP Module::Used Test::Module::Used)]);
is_deeply([$used->_used_modules_in_test()], [qw(Test::More Test::Class SampleModule)]);
is($used->_version_from_file(), '5.00803'); # perl version specified in testdatalib/SampleModule.pm

is_deeply( [Test::Module::Used::_remove_core('5.00803', qw(Net::FTP Module::Used Test::Module::Used))],
           ['Module::Used', 'Test::Module::Used'] );



