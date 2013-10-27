#!/bin/perl -w

my $filename=shift;
my $top_srcdir=shift;
$top_srcdir=".." if not defined $top_srcdir;

#git
my$cygpath_top_srcdir=$top_srcdir;
if($cygpath_top_srcdir=`cygpath -ad $top_srcdir 2>/dev/null`)
{
  chomp $cygpath_top_srcdir;
  $cygpath_top_srcdir="\"$cygpath_top_srcdir\"";
}
my$GIT;
$GIT=`git log --pretty=format:'%h' -n 1u` or $GIT="unknown";
print "git version: $GIT\n";

sub text2ccode
{
  my$fileFullName = shift;
  $fileFullName =~ m/\/?([^\/]+)$/;
  my$fileName = $1;
  my$OutputCfile = "$fileName.c";
  my$cName = $fileName;
  $cName =~ s/\./_/g;
  open IF, "<${fileFullName}";
  open OCF, ">${OutputCfile}";
  printf(OCF "/* File automatically created by " . __FILE__ . "*/\n");
  printf(OCF "\n");
  printf(OCF "const char * %s = \"\"\n",${cName});
  while(<IF>)
  {
    my $line=$_;
    $line=~s/\r?$//;
    $line=~s/\n$//;
    $line=~s/\\/\\\\/g;
    $line=~s/"/\\"/g;
    $line=~s/\@GIT_VERSION=[^@]*\@/\@GIT_VERSION=$GIT\@/g;
    printf(OCF "\"%s\\n\"\n", $line);
  }
  printf(OCF ";\n");
  close IF;
  close OCF;
  print "created: ${OutputCfile}\n";
}

&text2ccode($filename);
