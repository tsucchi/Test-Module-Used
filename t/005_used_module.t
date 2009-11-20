#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Test::Module::Used module_dir => ['t/lib'];


is_deeply([Test::Module::Used::_target_files()], ['t/lib/SampleModule.pm']);
is_deeply([Test::Module::Used::_used_modules()], [qw(Net::FTP Module::Used Test::Module::Used)]);
is(Test::Module::Used::_version_from_file(), '5.00803'); # perl version specified in t/lib/SampleModule.pm

done_testing();


