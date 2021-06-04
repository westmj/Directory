package Directory;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";



1;
__END__

=encoding utf-8

=head1 NAME

Directory - taking a table of school information (students, parents, teachers, staff, etc.) and making a directory (PDF, odf, etc.)

=head1 SYNOPSIS

    use Directory;
    my $roster = roster('test/Test_Table.xlsx') 
        or die "roster not read: $!\n";
    my $pdf = directory('Directory.pdf',   
      ## minimally the default version of Directory filename in PDF
        type => parent ,   
      ## hash of selected styles; e.g. type is parent or staff with defaults
        pictures => 0 ,    
      ## further elaboration of styles such as 
      ## including pictures; could be no; or (1 or yes)
            ) 
        or die "directory (PDF) not written: $!\n";
    my $odf = directory('Directory.odf') 
        or die "directory (open document format) not written: $!\n";  
      ## returns filename or failure (null)
    $roster = staged( sections => (classes, family, 
            staff, volunteers, school_committee,), 
        style => (ellipis => '#', ) , 
          )
        or die "directory presentation style not understood: $!\n"; 
    $odf = directory('Directory_full.odf'); 

    my $stored = storable('filename')
        or die "stored perl variable not written: $!\n";   
      ## from 'use Storable', store after a roster is read; returns success or failure 
    my $sql = storeSQL('filename.sql')
        or die "sqllite not written: $!\n";  
      ## returns null, or the default filename of the SQLite representation of the read roster

=head1 DESCRIPTION

Directory comes out of the task of rationalizing workflow in the Monteverde Friends School, 
where a roster of student information was kept in a google spreadsheet (easily exported as .xlsx)
and there was a need for a Parent Directory (previously made by hand each year from that roster)

=head1 LICENSE

Copyright (C) Michael West.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Michael West E<lt>mwjwest@gmail.comE<gt>

=cut

