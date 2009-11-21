#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    meta_file => 't/testdata/META.yml',
);
$used->_read_meta_yml();
is_deeply( [$used->_build_requires()],
           ['ExtUtils::MakeMaker', 'Test::More'] );

is_deeply( [$used->_requires()],
           ['Module::Used', 'PPI::Document'] );#perl 5.8.0 isn't return

done_testing();
