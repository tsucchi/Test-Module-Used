#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    test_dir     => ['testdata/t2'],
    module_dir   => ['testdata/lib2'],
    meta_file    => 'testdata/META.yml3',
);

#$used->ok;
is_deeply([$used->_get_packages], ['My::Test']);
is_deeply($used->{exclude_in_testdir}, ['Test::Module::Used', 'My::Test']);
done_testing();
