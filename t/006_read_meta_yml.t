#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests=>6;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    meta_file => 'testdata/META.yml',
);
$used->_read_meta_yml();
is_deeply( [$used->_build_requires()],
           ['ExtUtils::MakeMaker', 'Test::More'] );

is_deeply( [$used->_requires()],
           ['Module::Used', 'PPI::Document'] );#perl 5.8.0 isn't return

my $used2 = Test::Module::Used->new(
    meta_file => 'testdata/META.yml2',
);
$used2->_read_meta_yml();
is_deeply( [$used2->_build_requires()],
           ['ExtUtils::MakeMaker', 'Test::Class', 'Test::More' ] );

is_deeply( [$used2->_requires()],
           ['Module::Used', 'Test::Module::Used'] );#perl 5.8.0 isn't return


# exclude
my $used3 = Test::Module::Used->new(
    meta_file => 'testdata/META.yml2',
    exclude_in_build_requires => ['Test::Class'],
    exclude_in_requires       => ['Module::Used'],
);
$used3->_read_meta_yml();
is_deeply( [$used3->_build_requires()],
           ['ExtUtils::MakeMaker', 'Test::More' ] );

is_deeply( [$used3->_requires()],
           ['Test::Module::Used'] );#perl 5.8.0 isn't return


