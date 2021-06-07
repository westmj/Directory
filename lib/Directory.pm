package Directory;
##  prove -lrv -j 4 t    and optionally: xt   ## (use the library, recurse directories, and multiple cores')
##  perlcritic --severity 2  --verbose 9  lib/Directory.pm
##  perltidy -l=100 -b  --indent-only lib/Directory.pm 
use v5.10; ## say
use strict;
use diagnostics; ## verbose errors
use warnings FATAL => qw( all );
use Encode            qw( encode decode );
use Data::Peek;   # Instead of Data::Dumper... call DDumper instead of Dumper ... use DPeek to look at encoding
BEGIN { $ENV{SPREADSHEET_READ_XLSX} = "Spreadsheet::ParseXLSX";} ## avoid Spreadsheet::XLSX bad reader see Merijn emails
use Spreadsheet::Read qw( ReadData);

our $VERSION = "0.01";

use Carp;
use Exporter;
our @ISA       = qw( Exporter );
our @EXPORT    = qw( roster  );
our @EXPORT_OK = qw(  );

sub new {   ##  perl -I ./lib  script/new.pl
    my ($class) = shift @_;  ## print "Inside new with \$class = '$class'\n";
    my $self = { test => 'tester' , 
                  workbook => {},
                  };  ##  print "Self is still only a reference to \$self  = '$self'\n";
    bless $self, $class; ## print "by blessing, \$self is now an bless (anonymous hash) associated with the class '$class': \$self = '$self'\n";
    return $self;  ## return the object
} ## new

sub _roster_mfs_xlsx {
  ## MFS Roster format as of 2021-06-June-01 
    my $self = shift;
    my $workbook = shift;
    ${$self}->{workbook} = $workbook ;
  }

sub roster {  ## supports .xlsx through Spreadsheet::Read with Spreadsheet::ParseXLSX at this time
    my $self = shift;

    my $file = (shift or 't/Test_Table.xlsx'); 	## or return;  ## wants a filename (source)  ## return if needs

    my %opt;  ## need to do something with this!  
    if (@_) { ## pull in options if in the call
        if (ref $_[0] eq "HASH")  { %opt = %{shift @_} }
        elsif (@_ % 2 == 0)          { %opt = @_          }
    ## $self->{roster} = {%opt}; 
    
    my ($workbook) = ReadData($file);
    ## print "\$workbook= ", DDumper $workbook; 
    if (1) { _roster_mfs_xlsx(\$self, $workbook); } 
    ## if (1) { $self->_roster_mfs_xlsx(\$workbook); } 

    }

} ## roster

1;
__END__

=encoding utf-8

=head1 NAME

Directory - taking a table of school information (students, parents, teachers, staff, etc.) and making a directory (PDF, odf, etc.)

=head1 SYNOPSIS

    use Directory;
    my $dir = Directory->new(); 
    my $roster = $dir->roster('test/Test_Table.xlsx') 
        or die "roster not read: $!\n";
    my $pdf = $dir->directory('Directory.pdf',   
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
    $roster = $dir->staged( sections => (classes, family, 
            staff, volunteers, school_committee,), 
        style => (ellipis => '#', ) , 
          )
        or die "directory presentation style not understood: $!\n"; 
    $odf = $dir->directory('Directory_full.odf'); 

    my $stored = $dir->storable('filename')
        or die "stored perl variable not written: $!\n";   
      ## from 'use Storable', store after a roster is read; returns success or failure 

    $roster = retrieved('filename')
        or die "stored perl variable not written: $!\n";   
      ## from 'use Storable', retrieve after a roster is read and storable; returns success or failure 

    ## my $sql = storeSQL('filename.sql')   ## under development 
    ##    or die "sqllite not written: $!\n";  
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

