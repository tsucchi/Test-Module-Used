#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    module_dir => ['testdata/lib'],
    test_dir   => ['testdata/t'],
    meta_file  => ['testdata/META.yml2'],
);

$used->requires_ok();
$used->build_requires_ok();
$used->ok; #do both above2 method
ok(1); #dummy
done_testing();
