#!/usr/bin/perl -w
use strict;
use warnings;

use Test::Module::Used;
use File::Spec::Functions qw(catdir catfile);

my $used = Test::Module::Used->new(
    test_dir  => [catdir('testdata', 't')],
    lib_dir   => [catdir('testdata', 'lib')],
    meta_file => catfile('testdata', 'META.yml5'),
);

# Module::Used is missing in META.yml but it's ok
$used->requires_ok();

