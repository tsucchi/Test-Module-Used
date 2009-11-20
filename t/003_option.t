#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used test_dir     => ['t', 'xt'],
                       module_dir   => ['lib', 'libs'],
                       meta_file    => 'Meta.yml',
                       perl_version => '5.010';

is_deeply(\@Test::Module::Used::test_dir, ['t', 'xt']);
is_deeply(\@Test::Module::Used::module_dir, ['lib', 'libs']);
is($Test::Module::Used::meta_file, 'Meta.yml');
is($Test::Module::Used::perl_version, '5.010');
done_testing();
