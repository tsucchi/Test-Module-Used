use inc::Module::Install;
name           'Test-Module-Used';
author         'Takuya Tsuchida tsucchi@cpan.org';
license        'perl';
all_from       'lib/Test/Module/Used.pm';
requires       'Module::Used';
requires       'CPAN::Meta';
requires       'List::MoreUtils';
requires       'Module::CoreList';
requires       'PPI::Document';
requires       'version' => 0.77;
test_requires  'Test::More';

author_tests    'xt';

author_requires 'Test::Perl::Critic';
author_requires 'Test::Synopsis';
author_requires 'Test::Pod';
author_requires 'Test::Pod::Coverage';

no_index       directory => 'testdata';
repository     'http://github.com/tsucchi/Test-Module-Used';
WriteAll;
