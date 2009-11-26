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
test_requires  'Test::More';

no_index       directory => 'testdata';
WriteAll;
