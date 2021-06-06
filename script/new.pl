
    use strict;
    use warnings;
    use diagnostics;    ## verbose errors
    use warnings FATAL => qw( all );
    use Encode qw( encode decode );
    use Data::Peek;
    use Data::Dumper;  # Instead of Data::Dumper... call DDumper instead of Dumper ... use DPeek to look at encoding

    use Directory qw( roster );

    my $here = Directory->new;    ##  perl -I ./lib  script/new.pl
    print "\nIn the script, got the instance: '$here'\n";
    my $file = (shift or 't/Test_Table.xlsx'); 	## or return;  ## wants a filename (source)  ## return if needs
    $here->roster( 't/Test_Table.xlsx' , outside => 'outsider');
    print "DDumper of \$here: ", DDumper ($here); 
    print "Dumper of \$here: ", Dumper ($here); 
