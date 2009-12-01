use inc::Module::Install;
name           'Test-Module-Used';
author         'Takuya Tsuchida tsucchi@cpan.org';
license        'perl';
all_from       'lib/Test/Module/Used.pm';
requires       'Module::Used';
requires       'Perl::MinimumVersion';
requires       'YAML';
requires       'List::MoreUtils';
requires       'Module::CoreList';
requires       'PPI::Document';
test_requires  'Test::More';

author_tests   'xt';

no_index       directory => 'testdata';
WriteAll;
