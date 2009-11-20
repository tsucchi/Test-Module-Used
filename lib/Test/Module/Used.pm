package Test::Module::Used;
use base qw(Exporter);
use strict;
use warnings;
use File::Find;
use File::Spec::Functions qw(catfile);
use Module::Used qw(modules_used_in_files);
use PPI::Document;
use Module::CoreList;

our $VERSION = '0.0.1';
use 5.008;


=head1 NAME

Test::Module::Used - Test dependency between module and META.yml

=head1 SYNOPSIS

write synopsis here

=head1 DESCRIPTION

Test dependency between module and META.yml

=cut


our @test_dir = ('t');       # directoies which contains test scripts
our @module_dir = ('lib');   # directoies which contains module files
our $meta_file = 'META.yml'; # the metafile described module dependency.
our $perl_version = '5.008'; # default expected perl version

our @EXPORT = qw(used_ok);

=head1 methods

=cut

=head2 import

=cut

sub import {
    my $class = shift;
    my (%arg) = @_;
    $class->export_to_level(1, __PACKAGE__, qw(used_ok));

    for my $key (keys %arg ) {
        @test_dir     = @{$arg{$key}} if ( $key eq 'test_dir' );
        @module_dir   = @{$arg{$key}} if ( $key eq 'module_dir' );
        $meta_file    = $arg{$key}    if ( $key eq 'meta_file' );
        $perl_version = $arg{$key}    if ( $key eq 'perl_version' );
    }
}

=head2 used_ok

check used module is ok.
...

=cut



sub used_ok { # まだ仮実装
#     Test::More::plan tests => 1;
#     my $tb = Test::More->builder;
#     return $tb->ok( 1, 'ok' );
}


sub _target_files {
    my @result;
    find( sub {
              push @result, catfile($File::Find::dir, $_) if ( $_ =~ /\.pm$/ );
          },
          @module_dir);
    return @result;
}

sub _used_modules {
    return modules_used_in_files( _target_files() );
}

sub _version_from_file {
    my $version;
    for my $file ( _target_files() ) {
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
