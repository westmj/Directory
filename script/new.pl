
    use strict;
    use warnings;
    use v5.10; ## say 
    ## use feature 'say';
    use diagnostics;    ## verbose errors
    use warnings FATAL => qw( all );
        ## %role2sheet = ( 'test' => 1 ) ;
use Encode qw( encode decode );
    use Data::Peek;
    use Data::Dumper;  # Instead of Data::Dumper... call DDumper instead of Dumper ... use DPeek to look at encoding

    use Directory qw( roster );

    my $here = Directory->new();    ##  perl -I ./lib  script/new.pl
    ## print "\nIn the script, got the instance: '$here'\nwith DDumper: ", DDumper($here), "\n  test: '$here->test'\n  '", ${$here}{test} , "'\n";
    ## my $file = (shift or 't/Test_Table.xlsx'); 	## or return;  ## wants a filename (source)  ## return if needs
    ## $here->roster( 't/small.xlsx' , outside => 'outsider');
    $here->roster( 't/tiny.xlsx' , outside => 'outsider');
    warn DDumper $here; 
    $here->roster( 't/Test_Table.xlsx' , inside => 'insider');
    ## print "\nPresent DDumper of \$here: ", DDumper ($here); 
    ## print "Dumper of \$here: ", Dumper ($here); 
    ## print ref $here, "\n", ${$here}{workbook}[0]{parser}, "\n", DDumper($here), "\n";
    ## print "\n\nReaching into the object like a bad boy... We got the instance: '$here'\nwith DDumper: ", DDumper($here);
    ## print ref $here, "\n", ${$here}{worksheet}[0]{parser}, "\n\n";
    ## print ref $here, "\n", ${$here}{worksheet}[1]{A1}, "\n\n";   
    ## print ref $here, "\n", $here->{worksheet}[1]{A1}, "\n\n"; 
    ## print ref $here, "\n", $here->{worksheet}[1]->{A1}, "\n\n";
    ## say ref $here, "\n We say: ", $here->{worksheet}->[1]->{A1}, "\n\n";
    ## say "\$here->workbook(): ", $here->workbook(); 
    ## say "\$here->workbook->[0]{parser}: ", $here->workbook->[0]{parser}; 
    say "\$here->workbook->people : ", DDumper $here->people ; 
   exit; 

BEGIN { $ENV{SPREADSHEET_READ_XLSX} = "Spreadsheet::ParseXLSX";} ## avoid Spreadsheet::XLSX bad reader see Merijn emails
use Spreadsheet::Read qw( ReadData);

$here = ReadData('t/small.xlsx');
    ## print "\n\nReaching into the object like a bad boy... In the ReadData, got the instance: '$here'\nwith DDumper: ", DDumper($here);
    print ref $here, "\n", ${$here}[0]{parser}, "\n\n";
    print ref $here, "\n", ${$here}[1]{A1}, "\n\n";   
    print ref $here, "\n", $here->[1]{A1}, "\n\n"; 
    print ref $here, "\n", $here->[1]->{A1}, "\n\n";
    say ref $here, "\n We say: ", $here->[1]->{A1}, "\n\n";
    ## say "\$here->workbook(): ", $here->workbook(); 