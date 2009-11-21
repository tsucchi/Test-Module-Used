use inc::Module::Install;
name           'Test-Module-Used';
author         'Takuya Tsuchida tsucchi@cpan.org';
license        'perl';
all_from       'lib/Test/Module/Used.pm';
requires       'Module::Used';
requires       'PPI::Document';
requires       'YAML';
requires       'List::MoreUtils';
test_requires  'Test::More'  => '0.88';   #done_testing 使いたい
WriteAll;
