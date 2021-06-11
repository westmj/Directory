use v5.14; ## say and Class::Tiny
use strict;
no strict 'refs';
use diagnostics; ## verbose errors
use warnings FATAL => qw( all );
package Directory;
##  prove -lrv -j 4 t    and optionally: xt   ## (use the library, recurse directories, and multiple cores')
##  perlcritic --severity 2  --verbose 9  lib/Directory.pm
##  perltidy -l=100 -b  --indent-only lib/Directory.pm 
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

use Class::Tiny qw( workbook people caregiver role pages );

sub _c { my $str = shift;  ## remove leading and trailing spaces, and private informaation (marked privado)
    if (!defined $str) {return();};
    $str =~ s/\[\s*privado[^]]*\]\s*//smgx; # privado private.... if inside:  [privado ... ]
    $str =~ s/^\s+|\s+$//sxmg ;
    if ($str eq q{?}) {$str =''};
    return($str)
} ; ## sub _c    print "'", c( " \t trim white space  before and after  \n\t  "),  "'\n";

sub _a { my $str = shift; if (!defined $str) {return();}; if ($str =~  s/(.*)(.)(.*)\s\(\1(.)(\3)\)/$1$4$3/smx) { }      return($str); } ; # treat accented first names and accented second characters such as Olger and Yerica for alphobetizing

sub new {   ##  perl -I ./lib  script/new.pl
    my ($class) = shift @_;  ## print "Inside new with \$class = '$class'\n";
    my $self = {  workbook => [],
        people => {},
        caregiver => {},
        role => {},
        pages => {},
        output => "",
      };  ##  print "Self is still only a reference to \$self  = '$self'\n";
    bless $self, $class; ## print "by blessing, \$self is now an bless (anonymous hash) associated with the class '$class': \$self = '$self'\n";
    return $self;  ## return the object
} ## new

sub roster_test_tiny {
    my $self = shift;
    my $workbook = shift;
    ${$self}->{workbook} = $workbook ;
    my (%role2sheet) = (   # associates a role with a table (spreadsheet, worksheet) in the workbook.
        'worksheet1' => 1,
      );
    ## %role2sheet = ( 'test' => 1 ) ;
    foreach my $role (sort keys %role2sheet) { # loop through the worksheets in the workbook
        my $worksheet = $role2sheet{$role}; warn $worksheet; ## warn DDumper $self;
        my ($maxrow) = ${$self}->workbook->[$worksheet]{maxrow};
        warn "maxrow $maxrow";  ##  ${ @{ $$roster }[$role2sheet{$role}] }{'maxrow'};
        ## my ($used_row, $row )  = (1, ) ; # the rows in the spreadsheet, should be used, but some are empty.  let's squawk
        foreach my $row (2 .. $maxrow   ) {  # loop through the rows of people in each worksheet and store their information
            ## next unless ( ${ @{ $$roster }[$role2sheet{$role}] } {'cell'}[1][$row] );  # anything in this row?
            ## $used_row++; #count the rows that actually have data in them (skipping the header row that is titles)
        } ## $row of table
    } ## $role (table) of workbook
}  ## roster_test_tiny

sub roster_test {
    my $self = shift;
    my $workbook = shift;
    ${$self}->{workbook} = $workbook ;
    my (%role2sheet) = (   # associates a role with a table (spreadsheet, worksheet) in the workbook.
        'Administration' => 1,
        'Teachers' => 2,
        '  Kinder' => 3,
        '  Prepa' => 4,
        ' 1er Grado | 1st Grade' => 5,
        ' 2do Grado | 2nd Grade' => 6,
        'School Committee' => 8,
        'Volunteers' => 7,
      );
    my %attr_identifier = ( 'first' => 1, 'last' => 2 ); ## construct $identifier below 
    my $cols_2_attr_ref =  { 'person' =>  { '1' => 'first', '2' => 'last' , '3' => 'id', '10' => 'address', '19' => 'host', '5' => 'email', '8' => 'phone', '17' => 'annotation_summary', }, # associates a 'personal'/person category of information with a column number in the table
'sponsor'  => {'12' => 'father', '13' => 'mother', '14' => 'guardians', },  # associates caregivers of a person with that person by the column type
'role' => {'17' => 'annotation',},  # stores annotations to a person by their full name... convenient to get the full names in a category
      } ;  warn "\$cols_ref ($cols_2_attr_ref) = ". DDumper $cols_2_attr_ref;
    my %sheet2role = reverse %role2sheet;
    ## %role2sheet = ( 'test' => 1 ) ;
    foreach my $worksheet (sort keys %sheet2role) { # loop through the worksheets in the workbook
        ## my $worksheet = $role2sheet{$role}; warn $worksheet; ## warn DDumper $self;
        my ($maxrow) = ${$self}->workbook->[$worksheet]{maxrow};
        my ($sheet_name) = ${$self}->workbook->[$worksheet]{label};
        warn "worksheet # $worksheet; role '$sheet2role{$worksheet}' label '$sheet_name' maxrow $maxrow";  ##  ${ @{ $$roster }[$rroleole2sheet{$role}] }{'maxrow'};
        ## my ($used_row, $row )  = (1, ) ; # the rows in the spreadsheet, should be used, but some are empty.  let's squawk
        foreach my $row (2 .. $maxrow   ) {  # loop through the rows of people in each worksheet and store their information
            my $identifier = _c(${$self}->workbook->[$worksheet]{cell}[ $attr_identifier{'first'}][$row]) .' ' .
                _c(${$self}->workbook->[$worksheet]{cell}[ $attr_identifier{'last'}][$row]) ;  # form a "primary key" from the first name and last name
            warn "    \$identifier = '$identifier'";
            foreach my $col ( sort keys %{ ${$cols_2_attr_ref}{person} }    ) {
              if ($row ==2  and  defined(${$self}->workbook->[$worksheet]{cell}[$col][$row]) ) {
                  warn "     \$identifier = '$identifier', person column '$col' of type '${$cols_2_attr_ref}{person}{$col}' has value '". ${$self}->workbook->[$worksheet]{cell}[$col][$row] . "' \n";
                }
                elsif ($row ==2 ) {warn "    \$identifier = '$identifier', person column '$col' of type '${$cols_2_attr_ref}{person}{$col}' has value 'undef' \n";}
            }
            foreach my $col ( sort keys %{ ${$cols_2_attr_ref}{sponsor} }    ) {
                if ($row ==2  and  defined(${$self}->workbook->[$worksheet]{cell}[$col][$row]) ) {warn "    sponsor column '$col' of type '${$cols_2_attr_ref}{sponsor}{$col}' has value '". ${$self}->workbook->[$worksheet]{cell}[$col][$row] . "' \n";}
                elsif ($row ==2 ) {warn "    sponsor column '$col' of type '${$cols_2_attr_ref}{sponsor}{$col}' has value 'undef' \n";}
            }
            foreach my $col ( sort keys %{ ${$cols_2_attr_ref}{role} }    ) {
                if ($row ==2  and  defined(${$self}->workbook->[$worksheet]{cell}[$col][$row]) ) { ## cell has content 
                  warn "    role column '$col' of type '${$cols_2_attr_ref}{role}{$col}' has value '". ${$self}->workbook->[$worksheet]{cell}[$col][$row] . "' \n";
                  
                }
                elsif ($row ==2 ) {warn "    role column '$col' of type '${$cols_2_attr_ref}{role}{$col}' has value 'undef' \n";}
            }
            ## next unless ( ${ @{ $$roster }[$role2sheet{$role}] } {'cell'}[1][$row] );  # anything in this row?
            ## $used_row++; #count the rows that actually have data in them (skipping the header row that is titles)
        } ## $row of table
    } ## $role (table) of workbook
}  ## roster_test

sub roster_mfs_xlsx {  ## slurp in the MFS roster and read people, caregivers, and roles
    ## MFS Roster format as of 2021-06-June-01 
    my $self = shift;
    my $workbook = shift;
    ${$self}->{workbook} = $workbook ;
    my (%role2sheet) = (   # associates a role with a table (spreadsheet, worksheet) in the workbook.
        'Administration' => 1,
        'Teachers' => 2,
        '  Prekinder' => 3,
        '  Kinder' => 4,
        '  Prepa' => 5,
        ' 1er Grado | 1st Grade' => 6,
        ' 2do Grado | 2nd Grade' => 7,
        ' 3er Grado | 3rd Grade' => 8,
        ' 4to Grado | 4th Grade' => 9,
        ' 5to Grado | 5th Grade' => 10,
        ' 6to Grado | 6th Grade' => 11,
        ' 7mo Grado | 7th Grade' => 12,
        ' 8vo Grado | 8th Grade' => 13,
        ' 9no Grado | 9th Grade' => 14,
        '10mo Grado | 10th Grade' => 15,
        '11mo Grado | 11th Grade' => 16,
        '12mo Grado | 12th Grade' => 17,
        'GAP Students' => 18,
        'School Committee' => 21,
        'Volunteers' => 20,
      );
    my ($cols) =  {
'person' =>  {'first' => 1 , 'last' => 2 , 'id' => 3 , 'address' => 10, 'host' => 19, 'email' => 5, 'phone' => 8 , 'annotation_summary' => 17, }, # associates a 'personal'/person category of information with a column number in the table
'sponsor'  => {'father' => 12, 'mother' => 13, 'guardians' => 14, },  # associates caregivers of a person with that person by the column type
'role' => {'annotation' => 17,},  # stores annotations to a person by their full name... convenient to get the full names in a category
      } ;
    foreach my $role (sort keys %role2sheet) { # loop through the worksheets in the workbook
        my $worksheet = $role2sheet{$role}; warn $worksheet; ## warn DDumper $self;
        my ($maxrow) = ${$self}->workbook->[$worksheet]{maxrow};
        warn "maxrow $maxrow";  ##  ${ @{ $$roster }[$role2sheet{$role}] }{'maxrow'};
        ## my ($used_row, $row )  = (1, ) ; # the rows in the spreadsheet, should be used, but some are empty.  let's squawk
        foreach my $row (2 .. $maxrow   ) {  # loop through the rows of people in each worksheet and store their information
            ## next unless ( ${ @{ $$roster }[$role2sheet{$role}] } {'cell'}[1][$row] );  # anything in this row?
            ## $used_row++; #count the rows that actually have data in them (skipping the header row that is titles)
        } ## $row of table
    } ## $role (table) of workbook
} ## roster_mfs_xlsx

sub roster {  ## supports .xlsx through Spreadsheet::Read with Spreadsheet::ParseXLSX at this time
    my $self = shift;
    my $file = (shift or 't/Test_Table.xlsx'); 	## or return;  ## wants a filename (source)  ## return if needs
    my %opt;  ## need to do something with this!
    if (@_) { ## pull in options if in the call
        if (ref $_[0] eq "HASH")  { %opt = %{shift @_} }
        elsif (@_ % 2 == 0)          { %opt = @_          }
        ## $self->{roster} = {%opt}; 

        my ($workbook) = ReadData($file);  warn "\nReadData on file $file\n";
        ## print "\$workbook= ", DDumper $workbook; 
        if ($file eq 't/Test_Table.xlsx') { roster_test(\$self, $workbook); }
        elsif ($file eq 't/tiny.xlsx') { roster_test_tiny(\$self, $workbook); }
        else { roster_mfs_xlsx(\$self, $workbook); }
        ## if (1) { $self->roster_mfs_xlsx(\$workbook); } 
    }
} ## roster

sub read {
    my $self = shift;

} ## read

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

