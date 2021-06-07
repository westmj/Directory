
    use strict;
    use warnings;
    use diagnostics;    ## verbose errors
    use warnings FATAL => qw( all );
    use Encode qw( encode decode );
    use Data::Peek;
    use Data::Dumper;  # Instead of Data::Dumper... call DDumper instead of Dumper ... use DPeek to look at encoding

    use Directory qw( roster );

    my $here = Directory->new;    ##  perl -I ./lib  script/new.pl
    print "\nIn the script, got the instance: '$here'\nwith DDumper: ", DDumper($here);
    ## my $file = (shift or 't/Test_Table.xlsx'); 	## or return;  ## wants a filename (source)  ## return if needs
    $here->roster( 't/small.xlsx' , outside => 'outsider');
    ## $here->roster( 't/Test_Table.xlsx' , outside => 'outsider');
    print "\nPresent DDumper of \$here: ", DDumper ($here); 
    ## print "Dumper of \$here: ", Dumper ($here); 
    print ref $here, "\n", ${$here}{workbook}[0]{parser}, "\n";

BEGIN { $ENV{SPREADSHEET_READ_XLSX} = "Spreadsheet::ParseXLSX";} ## avoid Spreadsheet::XLSX bad reader see Merijn emails
use Spreadsheet::Read qw( ReadData);

$here = ReadData('t/small.xlsx');
    print "\n\nIn the ReadData, got the instance: '$here'\nwith DDumper: ", DDumper($here);
    print ref $here, "\n", ${$here}[0]{parser}, "\n\n";
    print ref $here, "\n", ${$here}[1]{A1}, "\n\n";