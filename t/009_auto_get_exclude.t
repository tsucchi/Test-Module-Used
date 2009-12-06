#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used;
use File::Spec::Functions qw(catfile);

my $used = Test::Module::Used->new(
    test_dir     => [catfile('testdata', 't2')],
    module_dir   => [catfile('testdata', 'lib2')],
    meta_file    => catfile('testdata', 'META.yml3'),
);

#$used->ok;
is_deeply([$used->_get_packages], ['My::Test']);
is_deeply($used->{exclude_in_testdir}, ['Test::Module::Used', 'My::Test']);
done_testing();
