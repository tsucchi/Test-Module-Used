#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests => 4;
use Test::Module::Used;

my $used = Test::Module::Used->new();

is_deeply($used->_test_dir, ['t']);#default directory for test
is_deeply($used->_module_dir, ['lib']);
is($used->_meta_file, 'META.yml');
is($used->_perl_version, '5.008');
