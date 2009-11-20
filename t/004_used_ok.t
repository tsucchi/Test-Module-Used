#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used module_dir => ['t/lib'];

used_ok();
ok(1); #dummy
done_testing();
