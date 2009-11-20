#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used;

is_deeply(\@Test::Module::Used::test_dir, ['t']);#default directory for test
is_deeply(\@Test::Module::Used::module_dir, ['lib']);#default directory for module
is($Test::Module::Used::meta_file, 'META.yml');
is($Test::Module::Used::perl_version, '5.008'); #default expected perl version
done_testing();
