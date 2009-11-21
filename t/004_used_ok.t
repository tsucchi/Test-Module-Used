#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    module_dir => ['t/lib'],
);
$used->ok;
ok(1); #dummy
done_testing();
