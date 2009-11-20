use inc::Module::Install;
name           'Test-Module-Used';
author         'Takuya Tsuchida takuya.tsuchida@gmail.com';
license        'perl';
all_from       'lib/Test/Module/Used.pm';

test_requires  'Test::More'  => '0.88';   #done_testing 使いたい
WriteAll;
