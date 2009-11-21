package Test::Module::Used;
use base qw(Exporter);
use strict;
use warnings;
use File::Find;
use File::Spec::Functions qw(catfile);
use Module::Used qw(modules_used_in_files);
use PPI::Document;
use Module::CoreList;
use YAML;
use Test::Builder;
use List::MoreUtils qw(any);

use 5.008;
our $VERSION = '0.0.1';

=head1 NAME

Test::Module::Used - Test dependency between module and META.yml

=head1 SYNOPSIS

write synopsis here

=head1 DESCRIPTION

Test dependency between module and META.yml

=cut

our @EXPORT = qw(used_ok);

=head1 methods

=cut

=head2 new

create new instance

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
...

=cut

sub ok {
    my $self = shift;
    my $test = Test::Builder->new();
    my $version = $self->_version_from_file || $self->_perl_version;

    my @used_in_lib     = _remove_core($version, $self->_used_modules);
    my @requires_in_lib = _remove_core($version, $self->_requires);

    my @used_in_test = _remove_core($version,
                                    $self->_used_modules_in_test(@{$self->{exclude_in_testdir}})) ;
    my @requires_in_test = _remove_core($version, $self->_build_requires);

    $test->plan(tests => @used_in_lib + @requires_in_lib + @used_in_test + @requires_in_test);
    my $status_requires_ok = $self->_requires_ok($test,
                                                 $version,
                                                 \@used_in_lib,
                                                 \@requires_in_lib);
    my $status_build_requires_ok = $self->_requires_ok($test,
                                                       $version,
                                                       \@used_in_test,
                                                       \@requires_in_test);
    return $status_requires_ok && $status_build_requires_ok;
}

sub _requires_ok {
    my $self = shift;
    my ($test, $version, $used_aref, $requires_aref) = @_;

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
    return modules_used_in_files( $self->_module_files() );
}

sub _used_modules_in_test {
    my $self = shift;
    my ( @excludes ) = @_;
    # this code is slow. optimize later
    my @result = modules_used_in_files( $self->_test_files() );
    for my $exclude ( @excludes ) {
        @result = grep { $_ ne $exclude } @result;
    }
    return @result;
}

sub _version_from_file {
    my $self = shift;
    my $version;
    for my $file ( $self->_module_files() ) {
        my $doc = PPI::Document->new($file);
        for my $item ( @{$doc->find('PPI::Statement::Include')} ) {
            for my $token ( @{$item->{children}} ) {
                next if ( !$token->isa('PPI::Token::Number::Float') );
                $version = $token->content;
            }
        }
    }
    return $version;
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
    $self->_read_meta_yml if !defined $self->{build_requires};
    return sort keys %{$self->{build_requires}};
}

sub _requires {
    my $self = shift;
    $self->_read_meta_yml if !defined $self->{requires};
    return sort keys %{$self->{requires}}
}

1;
__END__

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.org<gt>

=head1 SEE ALSO

L<Test::Dependencies> has almost same feature.

=head1 REPOSITORY

L<http://github.com/tsucchi/Test-Module-Used>


=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
