#!/usr/bin/perl -w
use strict;
use warnings;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    test_dir     => ['testdata/t2'],
    module_dir   => ['testdata/lib2'],
    meta_file    => 'testdata/META.yml3',
    exclude_in_testdir => ['Test::Module::Used'],
);

$used->ok;
