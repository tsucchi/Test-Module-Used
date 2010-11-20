#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests=>2;
use Test::Module::Used;
use File::Spec::Functions qw(catfile);

my $used = Test::Module::Used->new(
    meta_file => catfile('testdata', 'META.json'),
);
$used->_read_meta();
is_deeply( [$used->_build_requires()],
           ['ExtUtils::MakeMaker', 'Test::More'] );

is_deeply( [$used->_requires()],
           ['Module::Used', 'PPI::Document'] );


