package Test::Module::Used;
use base qw(Exporter);
use strict;
use warnings;
use File::Find;
use File::Spec::Functions qw(catfile);
use Module::Used qw(modules_used_in_files);
use Module::CoreList;
use YAML;
use Test::Builder;
use List::MoreUtils qw(any);
use Perl::MinimumVersion;

use 5.008;
our $VERSION = '0.0.5';

=head1 NAME

Test::Module::Used - Test required module is really used and vice versa bitween lib/t and META.yml

=head1 SYNOPSIS

  #!/usr/bin/perl -w
  use strict;
  use warnings;
  use Test::Module::Used;
  my $used = Test::Module::Used->new(
    exclude_in_testdir => ['Test::Module::Used', 'My::Module'],
  );
  $used->ok;


=head1 DESCRIPTION

Test dependency between module and META.yml.

This module reads I<META.yml> and get I<build_requires> and I<requires>. It compares required module is really used and used module is really required.

=cut


=head1 methods

=cut

=head2 new

create new instance

all parameters are passed by hash-style, and optional.

in ordinary use.

  my $used = Test::Module::Used->new(
    exclude_in_testdir => ['Test::Module::Used', 'My::Module'],
  );

use I<exclude_in_testdir>. If this parameter is specified. Test::Module::Used ignore modules used in testdir.

all parameter is as follows.(specified values are default)

  my $used = Test::Module::Used->new(
    test_dir     => ['t'],            # directory(ies) which contains test scripts.
    module_dir   => ['lib'],          # directory(ies) which contains modules.
    meta_file    => 'META.yml',       # META.yml (contains module requirement information)
    perl_version => '5.008',          # expected perl version which is used for ignore core-modules in testing
    exclude_in_testdir => [],         # ignored module(s) for test even if it is used.
    exclude_in_moduledir => [],       # ignored module(s) for your module(lib) even if it is used.
    exclude_in_build_requires => [],  # ignored module(s) even if it is written in build_requires of META.yml.
    exclude_in_requires => [],        # ignored module(s) even if it is written in requires of META.yml.
  );

if your module source contains I<use 5.XXX> statement, I<perl_version> passed in constructor is ignored (prior to use version in module source code).

=cut

sub new {
    my $class = shift;
    my (%opt) = @_;
    my $self = {
        test_dir     => $opt{test_dir}     || ['t'],
        module_dir   => $opt{module_dir}   || ['lib'],
        meta_file    => $opt{meta_file}    || 'META.yml',
        perl_version => $opt{perl_version} || '5.008',
        exclude_in_testdir => $opt{exclude_in_testdir} || [],
        exclude_in_moduledir => $opt{exclude_in_moduledir} || [],
        exclude_in_build_requires => $opt{exclude_in_build_requires} || [],
        exclude_in_requires => $opt{exclude_in_requires} || [],
    };
    bless $self, $class;
}


sub _test_dir {
    return shift->{test_dir};
}

sub _module_dir {
    return shift->{module_dir};
}

sub _meta_file {
    return shift->{meta_file};
}

sub _perl_version {
    return shift->{perl_version};
}

=head2 ok

check used module is ok.

  my $used = Test::Module::Used->new(
    exclude_in_testdir => ['Test::Module::Used', 'My::Module'],
  );
  $used->ok;


First, This module reads I<META.yml> and get I<build_requires> and I<requires>. Next, reads module directory (by default I<lib>) and test directory(by default I<t>), and compare required module is really used and used module is really required. If all these requirement information is OK, test will success.

=cut

sub ok {
    my $self = shift;
    my $test = Test::Builder->new();
    my $version = $self->_version_from_file || $self->_perl_version;

    my @used_in_lib     = _remove_core($version,
                                       $self->_used_modules);
    my @requires_in_lib = _remove_core($version, $self->_requires);

    my @used_in_test = _remove_core($version,
                                    $self->_used_modules_in_test);
    my @requires_in_test = _remove_core($version,
                                        $self->_build_requires);

    my $num_tests = @used_in_lib + @requires_in_lib + @used_in_test + @requires_in_test;
    if ( $num_tests > 0 ) {
        $test->plan(tests => $num_tests);
        my $status_requires_ok = $self->_requires_ok($test,
                                                     \@used_in_lib,
                                                     \@requires_in_lib);
        my $status_build_requires_ok = $self->_requires_ok($test,
                                                           \@used_in_test,
                                                           \@requires_in_test);
        return $status_requires_ok && $status_build_requires_ok;
    }
    else {
        $test->plan(tests => 1);
        $test->ok(1, "no tests run");
        return 1;
    }
}

sub _requires_ok {
    my $self = shift;
    my ($test, $used_aref, $requires_aref) = @_;

    my $status1 = $self->_check_required_but_not_used($test, $requires_aref, $used_aref);
    my $status2 = $self->_check_used_but_not_required($test, $requires_aref, $used_aref);

    return $status1 && $status2;
}


sub _check_required_but_not_used {
    my $self = shift;
    my ($test, $requires_aref, $used_aref) = @_;
    my @requires = @{$requires_aref};
    my @used     = @{$used_aref};

    my $result = 1;
    for my $require ( @requires ) {
        my $status = any { $_ eq $require } @used;
        $test->ok( $status, "check required module: $require" );
        if ( !$status ) {
            $test->diag("module $require is required but not used");
            $result = 0;
        }
    }
    return $result;
}

sub _check_used_but_not_required {
    my $self = shift;
    my ($test, $requires_aref, $used_aref) = @_;
    my @requires = @{$requires_aref};
    my @used     = @{$used_aref};

    my $result = 1;
    for my $used ( @used ) {
        my $status = any { $_ eq $used } @requires;
        $test->ok( $status, "check used module: $used" );
        if ( !$status ) {
            $test->diag("module $used is used but not required");
            $result = 0;
        }
    }
    return $result;
}

sub _module_files {
    my $self = shift;
    my @result;
    find( sub {
              push @result, catfile($File::Find::dir, $_) if ( $_ =~ /\.pm$/ );
          },
          @{$self->_module_dir});
    return @result;
}

sub _test_files {
    my $self = shift;
    my @result;
    find( sub {
              push @result, catfile($File::Find::dir, $_) if ( $_ =~ /\.t$/ );
          },
          @{$self->_test_dir});
    return @result;
}

sub _used_modules {
    my $self = shift;
    my @excludes = @{$self->{exclude_in_moduledir}};
    my @result = modules_used_in_files( $self->_module_files() );
    return _array_difference(\@result, \@excludes);
}

sub _used_modules_in_test {
    my $self = shift;
    my @excludes = @{$self->{exclude_in_testdir}};
    my @result = modules_used_in_files( $self->_test_files() );
    return _array_difference(\@result, \@excludes);
}

sub _array_difference {
    my ( $aref1, $aref2 ) = @_;
    my @a1 = @{$aref1};
    my @a2 = @{$aref2};

    for my $a2 ( @a2 ) {
        @a1 = grep { $_ ne $a2 } @a1;
    }
    return @a1;
}

sub _version_from_file {
    my $self = shift;

    my $highest_version;
    for my $file ( $self->_module_files() ) {
        my $minimum_version = Perl::MinimumVersion->new($file);
        my $version = $minimum_version->minimum_explicit_version;
        $highest_version = $version if ( !defined $highest_version || $version > $highest_version );
    }
    return $highest_version;
}

sub _remove_core {
    my( $version, @modules ) = @_;
    my @result;
    for my $module ( @modules ) {
        my $first_release = Module::CoreList->first_release($module);
        push @result, $module if ( !defined $first_release || $first_release >= $version );
    }
    return @result;
}

sub _read_meta_yml {
    my $self = shift;
    my $yaml = YAML::LoadFile( $self->_meta_file );
    $self->{build_requires} = $yaml->{build_requires};
    delete $yaml->{requires}->{perl};
    $self->{requires} = $yaml->{requires};
}

sub _build_requires {
    my $self = shift;
    my @excludes = @{$self->{exclude_in_build_requires}};

    $self->_read_meta_yml if !defined $self->{build_requires};
    my @result = sort keys %{$self->{build_requires}};
    return _array_difference(\@result, \@excludes);
}

sub _requires {
    my $self = shift;
    my @excludes = @{$self->{exclude_in_requires}};

    $self->_read_meta_yml if !defined $self->{requires};
    my @result = sort keys %{$self->{requires}};
    return _array_difference(\@result, \@excludes);
}

1;
__END__

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=head1 SEE ALSO

L<Test::Dependencies> has almost same feature.

=head1 REPOSITORY

L<http://github.com/tsucchi/Test-Module-Used>


=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
