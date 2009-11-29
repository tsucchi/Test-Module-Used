#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests=>9;
use File::Spec::Functions qw(catfile);
use Test::Module::Used;

my $used = Test::Module::Used->new(
    module_dir => ['testdata/lib'],
    test_dir   => ['testdata/t'],
    perl_version => '5.008',# version specified but this is ignored because 'use 5.00803' is written in .pm file
);
is_deeply([$used->_module_files], [catfile('testdata', 'lib', 'SampleModule.pm')]);
is_deeply([$used->_test_files],   [catfile('testdata', 't', '001_test.t')]);
is_deeply([$used->_used_modules()], [qw(Net::FTP Module::Used Test::Module::Used)]);
is_deeply([$used->_used_modules_in_test()], [qw(Test::More Test::Class SampleModule)]);
is($used->_version_from_file(), '5.00803'); # perl version specified in testdatalib/SampleModule.pm
is($used->_version, '5.00803');# used version

is_deeply( [$used->_remove_core(qw(Module::Used Net::FTP Test::Module::Used))],
           ['Module::Used', 'Test::Module::Used'] );



# exclude
my $used2 = Test::Module::Used->new(
    module_dir => ['testdata/lib'],
    test_dir   => ['testdata/t'],
    exclude_in_moduledir => ['Module::Used'],
    exclude_in_testdir   => ['Test::Class'],
);
is_deeply([$used2->_used_modules()], [qw(Net::FTP Test::Module::Used)]);
is_deeply([$used2->_used_modules_in_test()], [qw(Test::More SampleModule)]);
