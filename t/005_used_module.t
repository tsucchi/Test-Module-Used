#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests=>10;
use File::Spec::Functions qw(catfile);
use Test::Module::Used;

my $used = Test::Module::Used->new(
    lib_dir    => [catfile('testdata', 'lib')],
    test_dir   => [catfile('testdata', 't')],
    perl_version => '5.008',
);
is_deeply([$used->_pm_files], [catfile('testdata', 'lib', 'SampleModule.pm')]);
is_deeply([$used->_test_files],   [catfile('testdata', 't', '001_test.t')]);
is_deeply([$used->_used_modules()], [qw(Net::FTP Module::Used Test::Module::Used)]);
is_deeply([$used->_used_modules_in_test()], [qw(Test::More Test::Class)]);# SampleModule is ignored
is($used->_version, '5.008');# used version

is_deeply( [$used->_remove_core(qw(Module::Used Net::FTP Test::Module::Used))],
           ['Module::Used', 'Test::Module::Used'] );



# exclude
my $used2 = Test::Module::Used->new(
    lib_dir    => [catfile('testdata', 'lib')],
    test_dir   => [catfile('testdata', 't')],
    exclude_in_libdir => ['Module::Used'],
    exclude_in_testdir   => ['Test::Class'],
);
is_deeply([$used2->_used_modules()], [qw(Net::FTP Test::Module::Used)]);
is_deeply([$used2->_used_modules_in_test()], [qw(Test::More SampleModule)]);

# exclude after constructed
my $used3 = Test::Module::Used->new(
    lib_dir  => [catfile('testdata', 'lib')],
    test_dir => [catfile('testdata', 't')],
);
$used3->push_exclude_in_libdir(qw(Module::Used Net::FTP));
is_deeply([$used3->_used_modules()], [qw(Test::Module::Used)]);
$used3->push_exclude_in_testdir( qw(Test::More Test::Class) );
is_deeply([$used3->_used_modules_in_test()], []);
