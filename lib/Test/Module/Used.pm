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

sub ok { # まだ仮実装
    my $self = shift;
    $self->build_requires_ok;
    $self->requires_ok;
}

=head2 requires_ok

check META.yml and modules

=cut

sub requires_ok {
    my $self = shift;
    return;
}

=head2 build_requires_ok

check META.yml and testcode

=cut

sub build_requires_ok {
    my $self = shift;
    return;
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
    return modules_used_in_files( $self->_test_files() );
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
