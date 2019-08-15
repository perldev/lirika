#!/usr/bin/perl 
use strict;
use Encode;
use MyConfig;
use lib $MyConfig::path;
use warnings;
use SiteDB;
use SiteCommon;
use Mail::POP3Client;
use File::Find;
use Data::Dumper;

my $password='JjHUQFflGqp1BeQzZScRL';
my $pop = new Mail::POP3Client(USER => "evripid", PASSWORD => "zlovonie18", HOST => "pop.i.ua");
my $working_path='/tmp/';

mkdir("$working_path/working");

$working_path=$working_path."working/";
my $current='';
my $body='';
my $j=0;
my $EXP=2;
my $MIST=1000;
my %firms_trans=();

for (my $i=1; $i <= $pop->Count(); $i++) {  
 
   my $flg=0;
   my @ars;
   $body='';
   foreach my $line ($pop->Body($i)) {
    
   
    if ($line =~/filename=/){
           $flg=1; 
           next;
       }
      
       next       unless($flg);
       if($line=~/-{8}/){
          $flg=0;
          push @ars,$body;
         
       }else{
    	    
            $body.=$line;
            next;
       } 
   }

  
   $j++;
   use MIME::Base64; 
   my $decoded = MIME::Base64::decode($body);
     
   open(FL, ">$working_path"."$j.rar") or die $!;
   print FL $decoded;
   close FL;
    
   
#   $pop->Delete($i);
}


die "there isn't any photos on the server \n "  if($j==0);
$pop->Close();



foreach(1..$j){
    

    $body=$working_path."$_.rar";

    system("rar  -p$password e '$body' '*.*' $working_path > /dev/null");

    unlink($body);

    find(\&wanted,$working_path);

}


my $okpo=$dbh->selectall_hashref(q[SELECT * FROM firms WHERE f_okpo!='' AND f_okpo IS NOT NULL],'f_id');
    
$dbh->do("UPDATE firms SET is_confirm='not_processed'");
my @kwya=keys %$okpo;
my @errors;
my @susp;


foreach my $key1(@kwya){
    
    
    my $rows=$dbh->selectall_arrayref(q[SELECT ct_amnt,ct_comment 
				      FROM cashier_transactions 
                                      WHERE ct_fid=? 
                                      AND ct_date=DATE(DATE_SUB(current_timestamp,interval 1  day)) 
				      AND ct_status IN ('processed','created')
                                      ORDER BY 
                                      ct_amnt],undef,$key1);


    my @rr;
    my $name=$okpo->{$key1}->{f_name};
    if($firms_trans{ $okpo->{$key1}->{f_okpo} } ){
         @rr= @{$firms_trans{ $okpo->{$key1}->{f_okpo} } };
    }else{
	if(@$rows){
	    push @errors,$name;
	}
    
	next ;  
    }
    
    next    unless(@rr);
#    print Dumper \@rr,$rows;
    my $size=@rr;
    my $size2=@$rows;
    my ($sum1,$sum2,$nsum1,$nsum2)=(0,0,0,0);
    my $status='confirmed';
    
    
    for(my $i=0;$i<$size;$i++){
		$sum1+=abs($rr[$i]);
		 $nsum1+=$rr[$i];
                    
    }
    for(my $i=0;$i<$size2;$i++){                                                                                                                              
            $sum2+=abs($rows->[$i]->[0]);  
	    $nsum2+=$rows->[$i]->[0];                                                                                                                            
                                                                                                                                                             
    }
    
    
    
    
    if(abs($sum2-$sum1)>$MIST&&abs($nsum1-$nsum2)<$MIST){
    	    print "=====================================================================================\n";
    	    print "Suspicies find in $name \n";                                                                                                                               
	    my @rows=sort { abs($a->[0]) <=> abs($b->[0]) } @$rows;
	    my @rows1=sort { abs($a) <=> abs($b) } @{$firms_trans{ $okpo->{$key1}->{f_okpo} } };;
    	    print "In office \n";
	    foreach(@rows){
	        $_->[0]=format_float($_->[0]);
		print "$_->[0] - $_->[1]\n";
	    }
	    print "In banking system \n";                                                                                                                            
	    foreach(@rows1){         
		     $_=format_float($_);                                                                                                                         
	              print "$_ \n";                                                                                                                 
	    }   
	      print "=====================================================================================\n";  
    
    
    }
    
  if(abs($sum2-$sum1)<$MIST && abs($nsum1-$nsum2)>$MIST){                                                                                                    
 print "=====================================================================================\n";                                                                                                                                         
               print "Suspicies find in $name\n";                                                                                                                                
                my @rows=sort { abs($a->[0]) <=> abs($b->[0]) } @$rows;                                                                                          
                my @rows1=sort { abs($a) <=> abs($b) } @{$firms_trans{ $okpo->{$key1}->{f_okpo} } };;                                                            
                print "In office \n";                                                                                                                   
                foreach(@rows){                                                                                                                                  
		    $_->[0]=format_float($_->[0]);
                    print "$_->[0] - $_->[1]\n";                                                                                                                 
                }                                                                                                                                                
                print "In banking system \n";                                                                                                                            
                foreach(@rows1){
	    	      $_=format_float($_);                                                                                                                                 
                      print "$_ \n";                                                                                                                         
              }        	                                                                                                                                
		                                                                                                                                                                    
 print "=====================================================================================\n"; 		                                                                                                                                                                    
   }     

       
    
    if(abs($sum2-$sum1)>$MIST&&abs($nsum1-$nsum2)>$MIST){
    	$status='not_confirmed';
	 print "=====================================================================================\n"; 
	print "Error find in $name\n";
	 my @rows=sort { abs($a->[0]) <=> abs($b->[0]) } @$rows;                                                                                          
         my @rows1=sort { abs($a) <=> abs($b) } @{$firms_trans{ $okpo->{$key1}->{f_okpo} } };;                                                            
         print "In office \n";                                                                                                                           
         foreach(@rows){                        
	  $_->[0]=format_float($_->[0]);                                                                                                          
                     print "$_->[0] - $_->[1]\n";                                                                                                                 
         }                                                                                                                                                
    	     print "In banking system \n";                                                                                                                           
         foreach(@rows1){
               $_=format_float($_);                                                                                                                                 
	       print "$_ \n";                                                                                                                         
       }       	
	 print "=====================================================================================\n"; 
	




	
    }
    
    
    
    
    
    # print "error find \n" if($status eq 'not_confirmed');
    $dbh->do("UPDATE firms SET is_confirm='$status' WHERE f_id=?",undef,$key1);
    
    my $t=$okpo->{$key1}->{f_okpo};
    delete $firms_trans{ $t };
                                                                                                                               
	 
}
# Dumper $rows,$firms_trans{ $okpo->{$key1}->{f_okpo} } ; 



rmdir($working_path);



exit(0);


sub wanted{

        print "$File::Find::name ";
	if($File::Find::name=~/rar/||$File::Find::name eq $File::Find::dir){
#	    print "skip \n";
	    return;
	}
#	print "\n";
	
        open(FL,"$File::Find::name") or die $!;
        my @a=<FL>;
        close(FL);
        
	foreach my $str (@a){
                
	
	
            if($str=~/UAH/){
               my @str=split(/[ ]+/,$str);
               $current=int($str[-1]);
	       my @aaa;
               $firms_trans{$current}=\@aaa unless($firms_trans{$current});
               next;
            }
            if($str=~/^[\d]+/){#(/^[\d\ \`\.TRtr]+$/){
        	        
		    
                    my @str=split(/[ ]+/,trim($str));
		    
		    $str[-1]=~s/[^\d\.]//g;
        	    $str[-2]=~s/[^\d\.]//g;
		
		    $str[-1]="0$str[-1]0";
		    $str[-2]="0$str[-2]0";
		
		
		
		    
                my $sum=0;
                
		
		
                if($str[-2]*1){
                    $sum=$str[-2]*(-1);
                                   
                }else{
                    $sum=$str[-1]*1;
                }
		        die " not occured error $str  \n" unless($sum);

                push @{ $firms_trans{$current} },1*$sum;
                @{$firms_trans{$current}}=sort  { $a<=>$b} @{$firms_trans{$current}};
		
	        next;            
            }
            
        }
        
     unlink("$File::Find::name");

}
