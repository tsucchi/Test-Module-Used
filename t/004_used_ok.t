#!/usr/bin/perl -w
use strict;
use warnings;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    module_dir => ['testdata/lib'],
    test_dir   => ['testdata/t'],
    meta_file  => 'testdata/META.yml2',
    exclude_in_testdir => ['SampleModule'],
);

$used->ok;
