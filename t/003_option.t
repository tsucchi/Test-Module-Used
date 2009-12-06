#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests=> 4;
use Test::Module::Used;
use File::Spec::Functions qw(catfile);

my $used = Test::Module::Used->new(
    test_dir     => ['t', 'xt'],
    module_dir   => ['lib', catfile('testdata', 'lib')],
    meta_file    => 'Meta.yml',
    perl_version => '5.010',
);

is_deeply($used->_test_dir, ['t', 'xt']);
is_deeply($used->_module_dir, ['lib', catfile('testdata', 'lib')]);
is($used->_meta_file, 'Meta.yml');
is($used->_perl_version, '5.010');

