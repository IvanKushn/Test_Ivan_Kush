#!/usr/bin/perl -w

use DBI;

my $dbh = DBI->connect('DBI:mysql:mybase','root','1') or die "\n$DBI::errstr\n";

#$dbh->do('delete from message');
#$dbh->do('delete from log');

open (FILEIN,'out') or die "\n$!\n";

my $sth_mes = $dbh->prepare("insert into message (created,int_id,str,id)      values(?,?,?,?)");
my $sth_log = $dbh->prepare("insert into log     (created,int_id,str,address) values(?,?,?,?)");
my $count_mes = 0;
my $count_log = 0;
while(<FILEIN>) {
  chomp;
  my @cur_str = split(' ',$_);
  my $created       = $cur_str[0].' '.$cur_str[1];
  my $int_id        = '';
     $int_id        = $cur_str[2] if $cur_str[2] =~ /......-......-../;
  my ($s1,$s2,$str) = split(' ',$_,3);
  my $flag          = $cur_str[3];

  if ($flag eq '<=') {
    # Входящее сообщение
    my ($s3,$id) = split('id=',$str,2);                # Находим id
    $id = '' if not defined $id;
    ($id,$s3) = $id ne '' ? split(' ',$id,2):('','');  # Если есть адрес, отрезаем его
    $sth_mes->execute($created,$int_id,$str,$id);
    $count_mes++;
  } else {
    my $address = '';
    $address = $cur_str[4] if (($flag eq '=>') or ($flag eq '->') or ($flag eq '**') or ($flag eq '=='));
    $address = substr($cur_str[5],1,-1) if $address eq ':blackhole:'; 
    $sth_log->execute($created,$int_id,$str,$address);
    $count_log++;
  }
}

print "Загружено\n message: $count_mes\n     log: $count_log\n\n";
