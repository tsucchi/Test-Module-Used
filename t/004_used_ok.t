#!/usr/bin/perl -w
use strict;
use warnings;
use Test::Module::Used;
use File::Spec::Funcitons qw(catfile);

my $used = Test::Module::Used->new(
    module_dir => [catfile('testdata', 'lib')],
    test_dir   => [catfile('testdata', 't')],
    meta_file  => catfile('testdata', 'META.yml2'),
    exclude_in_testdir => ['SampleModule'],
);

$used->ok;
