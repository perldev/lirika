#!/usr/bin/perl
use strict;
use lib q(./blib);
#use AI::subclust;
use Data::Dumper;
use DBI;
use POSIX;
#use AI::NeuralNet::Simple;
#use  AI::NeuralNet::BackProp;
print "Content-Type: text/html; charset=Windows-1251\n\n";
#print SM "Content-Type: text/plain; charset=Windows-1251\n\n";
#print "Content-Type: text/html;charset=\"cp1251\"\n\n";

my $RELEVENT_MISTAKE=0.75;

my $dsn = "DBI:mysql:host=localhost;database=fsb";


my $dbh=DBI->connect($dsn, 'fsb_user', 'randomnumber', { RaiseError => 1});
                                                                                                                                       
$dbh->do(q[SET names cp1251]);                                                                                                         
                                                                                                                                       
$dbh->do(q[SET charset cp1251]);    

my $max=$dbh->selectrow_array(q[SELECT count(*) FROM joke]);

my $comment=$dbh->selectrow_array(q[SELECT 
	comment 
	FROM joke WHERE id=?],undef,int(rand($max)));

#print $ENV{'QUERY_STRING'};
#exit(0);
my %PARAMS;

parseURL(\%PARAMS);

my $search=$PARAMS{number};
$PARAMS{comment}=~s/["' ]//g;
#print $search;
#exit(0);
my $ref;
=pod
if($PARAMS{comment})
{
#    print $PARAMS{comment};
#    print qq[SELECT as_amnt,as_desc,as_native_desc FROM amnt_search WHERE as_desc like '%$PARAMS{comment}%'];
    $ref=$dbh->selectall_arrayref(qq[SELECT as_amnt,as_desc,as_native_desc 
    FROM amnt_search WHERE as_desc like '%$PARAMS{comment}%']);
    print Dumper $ref;
    exit(0);
    
}else
{
=cut
     $ref=$dbh->selectall_arrayref(qq[SELECT as_amnt,as_desc,as_native_desc FROM amnt_search]);      
#}
$dbh->disconnect();
my $tmp;
my @array;
foreach(@$ref)
{
	$tmp=dis_($search,$_->[0]);
	push @array,{amnt=>$_->[0],desc=>$_->[1],url=>$_->[2]}  if(!$PARAMS{number}||($tmp<=$RELEVENT_MISTAKE&&$_->[1]=~/$PARAMS{comment}/));
	$tmp=10;
}
print return_result(\@array);

exit(0);

sub dis_
{
	
	my ($n,$n1)=@_;
	$n=int(abs($n));
	$n1=int(abs($n1));
	return 0 if($n1==$n);
	my @num1=split(//,$n);
	my @num2=split(//,$n1);
	my @res;
	my $sum=0;
	my $i=0;
	return  1 if(scalar(@num1)!=scalar(@num2));
	my $ava;
	map{$ava+=$_} @num1;
	$ava/=scalar(@num1);
	my $max=0;
	my $disp=0;
	foreach(@num1)
	{
		$max=abs($ava-$_) if($max<(abs($ava-$_)));
		$disp+=abs($ava-$_);
		
	}
	$disp/=scalar(@num1);
	my $ava2=0;
	my $max2=0;
	my $disp2=0;
	my $jump;
	foreach(@num2)
	{
		 return 1 if(abs($_)>$ava+$max);
		 $ava2+=abs($_);
	}
	$ava2/=scalar(@num2);
	foreach(@num2)
	{
		$disp2+=abs($ava2-$_);
	}
	$disp2/=scalar(@num2);
	my $mistake=10/scalar(@num1);
	my $sum_mist=0;
	for(my $i=0;$i<scalar(@num1);$i++)
	{
	
		$sum_mist+=$mistake*($num1[$i]!=$num2[$i]);

	}
	return $sum_mist if($sum_mist<$RELEVENT_MISTAKE&&($disp2!=$disp&&$ava!=$ava2));

	
	return 0.313 if($disp2==$disp&&$ava==$ava2);
	
	#return 0.737 if($disp2!=$disp&&$ava==$ava2);	

	return $sum_mist;
}
sub parseURL 
{
	my $form=shift;
	my($in, $pair, @pairs, $name, $value);

	# get incoming data
   	if ($ENV{'REQUEST_METHOD'} eq 'GET') {
   		@pairs = split(/&/, $ENV{'QUERY_STRING'});
   		}
    elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
    	read(STDIN, $in, $ENV{'CONTENT_LENGTH'});
       	@pairs = split(/&/, $in);
		}
	
	foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
#		print "$name,$value\n";
#translate plus to space
		$value =~ tr/+/ /;

		#translate hex values to alphanumeric
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C',hex($1))/eg;

		#assign name/value pairs to hash
		$form->{$name} = $value;
#		print Dumper $form;		
		
		}

#	exit(0);

}

sub return_result
{
	my $ref=shift;
	my $params='';
	map { $params.=qq[
	  <tr class="table_gborders">
	<td  class="table_gborders" align="left" width="30%">
	<a target='blank' class="table_gborders" href='$_->{url}'>$_->{amnt}</a>
        </td>
        <td  colspan="4" class="table_gborders" width='70%'align="left">
	$_->{desc}	
        </td></tr>
	]}  @$ref;

my $text=qq[
<html><head>
<meta charset="cp1251"><title>Поиск</title>
<style type="text/css">
body {margin:0px}
.linx {font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#FFFFFF; text-decoration:underline;}
.linx:hover {font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#000000; text-decoration:underline;}
.simple_text{border:0;font-size: 13px;border:0; margin:0px; padding: 4px}
.menu_text {font-family: sans-serif; font-size:11px; color:#FFFFFF;cursor:pointer;font-weight:bolder;background-color:#006493;padding:4px;margin-top:1px;border:1px solid black;text-decoration:none}

.menu_text:hover {font-family:Arial; font-size:11px; color:#FFFFFF;cursor:pointer;font-weight:bolder;color:black;background-color:white;padding:4px;margin-top:1px;text-decoration:none}
.menu_text_selected {font-family:Arial; font-size:11px; color:#FFFFFF;cursor:pointer;font-weight:bolder;color:black;background-color:white;padding:4px;margin-top:1px;text-decoration:none}

.page_text {font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#000000;}
table.table_gborders_big{background-color:gray;margin:10px;border-spacing:1px;border:0;padding:1px}
td.table_gborders_big{background-color:white;border:0;font-size: 15px;border:0; margin:0px; padding: 4px}
table.top_menu{border:0px;padding:0px;margin:0px}
table.top_menu tr{background:none}
table.top_menu td{padding:5px;margin:3px}
div.menu{line-height:26px}

span.simple_tab{margin:11px;font-family:Arial, Helvetica, sans-serif; font-size:11px; color:rgb(100, 140, 159); text-decoration:none;cursor:pointer}
span.simple_tab_inner{margin:11px;font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#3053B9; text-decoration:none;cursor:pointer}


div.center_div_table_poup{margin-left:0px;margin-right:5px;margin-top:5px;margin-bottom:5px;
background-color:#ADD8E6;padding:7px;border:1px solid black;filter:alpha(opacity=80);
  opacity:0.8;width:30%}
div.textarea{position:relative;left:4px;background-color:white;margin:4px;padding:4px;border:1px solid black;font-size:11px;display:none}

table.table_gborders{background-color:gray;border-spacing:1px;border:0;padding:1px}
td.table_gborders{background-color:white;border:0;font-size: 13px;border:0; margin:0px; padding: 4px}
th.table_gborders{background-color:#CCCCCC;font-size: 13px;margin:0px; border:0;padding: 4px}

td.table_gborders_gray{background-color:#CCCCCC;font-size: 13px;margin:0px; border:0;padding: 4px}

td.table_gborders_main{background-color:white;border:0;font-size: 13px;border:0; margin:0px; padding-top:4px;padding-bottom:4px;padding: 6px;}
.table_gborders{color:#000000;}
.simple_tab{cursor:pointer}


.table_gborders_green{background-color:#00FF4B;font-size: 13px;margin:0px; border:0;padding: 4px }
.table_gborders_not_ex_green{background-color:#A3DEB5;font-size: 13px;margin:0px; border:0;padding: 4px }


.table_gborders_deleted{background-color:#C5C5C5;font-size: 13px;margin:0px; border:0;padding: 4px }
.table_gborders_red2{background-color:#CC1122;font-size: 13px;margin:0px; border:0;padding: 4px }
.table_gborders_blue{background-color:#D4E7F9;font-size: 13px;margin:0px; border:0;padding: 4px }
.table_gborders_vial{background-color:#C4CCE9;font-size: 13px;margin:0px; border:0;padding: 4px }
#tooltip{
background:#FFFFFF;
border:1px solid #666666;
color:#333333;
font:menu;
margin:0px;
padding:3px 5px;
position:absolute;
visibility:hidden
}td.sum
{
	cursor:pointer;
}td.summed
{
	cursor:pointer;
}td.long{
	overflow:hidden
}td.table_gborders_red2 summed{
	background-color: #ffff80;
}
th.table_gborders_red{background-color:#CCCCCC;font-size: 13px;margin:0px; border:0;padding: 4px}

td.table_gborders_red{background-color:#F4D5D5;border:0;font-color: ;font-size: 13px;border:0; margin:0px; padding: 4px}

tr.table_gborders_red{color: #F4D5D5;}

td.table_gborders_veryred{background-color:#D79C9C;border:0;font-color: ;font-size: 13px;border:0; margin:0px; padding: 4px}
td.table_gborders_red summed{
	background-color: #ffff80;cursor:pointer
}
td.table_gborders_whiteskin{background-color:#FFEEC4;border:0;font-color: ;font-size: 13px;border:0; margin:0px; padding: 4px}



td.table_gborders_verygreen{background-color:#E6FF92;border:0;font-color: ;font-size: 13px;border:0; margin:0px; padding: 4px}


.table_gborders_red{color:black;}
a.table_gborders_red{margin:10px;font-family:Arial, Helvetica, sans-serif; font-size:11px; color:rgb(100, 140, 159); text-decoration:none;}
a.table_gborders_red:hover{font-family:Arial, Helvetica, sans-serif; font-size:11px; color:white; text-decoration:underline;}

a.table_gborders{margin:11px;font-family:Arial, Helvetica, sans-serif; font-size:11px; color:rgb(100, 140, 159); text-decoration:none;}
a.table_gborders:hover{font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#000000; text-decoration:underline;}

a.table_gborders_href{margin:11px;font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#5B6570; text-decoration:none;}
a.table_gborders_href:hover{font-family:Arial, Helvetica, sans-serif; font-size:11px; color:#000000; text-decoration:underline;}
img.history{cursor:pointer}

.simple_borders{border:solid;border-width:1px;border-color:gray;font-size: 13px; padding: 1px;font-weight:-1}
input.simple_borders{border:solid;border-width:1px;border-color:gray;font-size: 13px; padding: 1px;font-weight:-1;margin:1px}
.table_gborders{ background-color:white;border:0;font-size: 13px;border:0; margin:0px; padding: 4px}
td.reg_error_borders{width: 35%;}
table.table_gborders_none{background-color:white;border-spacing:5px;border:0;padding:10px;width:55%}
td.table_gborders_none{background-color:white;border-spacing:5px;border:0;padding:1px;}
.button{background-color:#709FB5;padding:4px;font-size:12px;border:solid;border-width:1px;border-color:black;cursor:pointer;border-style: ridge}
.center_div{width:70%;margin-top:10px;background-color:#ADD8E6;padding:10px}
.center_div_table{margin-left:0px;margin-right:5px;margin-top:5px;margin-bottom:5px;
background-color:#ADD8E6;padding:3px}
/*.center_div_table #header{margin-left:0px;margin-right: 10px;margin-top:10px;margin-bottom:10px;background-color:#ADD8E6;padding:10px}*/

.center_div_table_left{width:20%;margin-left:40px;margin-top:10px;background-color:#ADD8E6;padding:10px}
td.summed{
	background-color: #ffff80;cursor:default
}
td.summ{
	background-color: inherit;cursor:default
}
span.div_tab {cursor:pointer};
img.toggle_sum{
	width:16px;
	height:16px;
	display: block;
	float:right;
	cursor:pointer;
}
div.toolbar{
	background-color: #ccc;
}
input.toolbutton{
	border:solid 1px #888;
	margin: 3px;
	background-color: #fff;
	padding: 2px;
}
nobr.comment{
	width:150px;cursor:pointer;overflow:hidden;display:block;
}
<!--  -->
</style>



</head><body>



<center>
 <div class="center_div_table">

<div id="header">
<table class="table_gborders_big" align="center">
<tbody><tr class="table_gborders_big">
<td class="table_gborders_big">
<form action='network.cgi' method='GET' >

<table class="table_gborders">
<tr class="table_gborders">
<td class="table_gborders">
<strong>Число:</strong></td>
<td class="table_gborders"><input class='simple_borders' type='text' value="$PARAMS{number}" name='number'></td>
<td class="table_gborders">
<strong>Назначение:</strong></td><td class="table_gborders"><input name="comment" class='simple_borders' type='text' value='$PARAMS{comment}'>
</td>
</tr>
<tr class="table_gborders">
<td colspan="4" class="table_gborders">
<input class='simple_borders' type='submit' value='Искать...' name='Искать...'><strong><a class='table_gborders' href='index.cgi'>Назад</a></strong></form>
</td>
</tr>
</table>

</td>
</tr>	
<tr class="table_gborders_big">
<td class="table_gborders_big">
$comment
</td>
</tr>
</tbody></table>

</div>
  <table class="table_gborders" width="60%">

  <tbody><tr class="table_gborders">
    <td class="table_gborders" colspan="5">
        <strong>Результаты поиска...<!--Фирмы--></strong>       
    </td>
  </tr> 

$params
  
</tbody></table>
</div>  

</center>
<div style="left: -91px; top: -91px;" id="tooltip"></div></body></html>
];



 return $text;
}




# Create a new network with 1 layer, 5 inputs, and 5 outputs.

=pod
        my $net = new AI::NeuralNet::BackProp(2,5,1);
        
        # Add a small amount of randomness to the network
        $net->random(0.01);

        # Demonstrate a simple learn() call
        #my @inputs = ( 0,0,1,1,1 );
        #my @outputs = ( 1,0,1,0,1 );
        
        #print $net->learn(\@inputs, \@outputs),"\n";
	my @data = ( 
                #       Mo  CPI  CPI-1 CPI-3    Oil  Oil-1 Oil-3    Dow   Dow-1 Dow-3   Dow Ave (output)
                [       1,1  ],[1],
                [       0,0   ],[1],
    		[       0,1   ],[0],
		[       1,0   ],[0],      
  		[       2,2  ],[1],
                [       3,3   ],[1],
    		[       4,4   ],[1],
		[       5,5   ],[1],
  		[       5,4  ], [.8],
                [       4,5   ],[.8],
    		[       3,5   ],[0],
		[       2,5   ],[0],    
        );
        $net->learn_set(\@data);

	my @map = ([1,1]);
        
        my $result = $net->run(\@map);

	print Dumper $result;

	exit(0);
        # Create a data set to learn
        my @set = (
                [ 2,2,3,4,1 ], [ 1,1,1,1,1 ],
                [ 1,1,1,1,1 ], [ 0,0,0,0,0 ],
                [ 1,1,1,0,0 ], [ 0,0,0,1,1 ]    
        );
        
        # Demo learn_set()
        my $f = $net->learn_set(\@set);
        print "Forgetfulness: $f unit\n";
        
        # Crunch a bunch of strings and return array refs
        my $phrase1 = $net->crunch("I love neural networks!");
        my $phrase2 = $net->crunch("Jay Lenno is wierd.");
        my $phrase3 = $net->crunch("The rain in spain...");
        my $phrase4 = $net->crunch("Tired of word crunching yet?");

        # Make a data set from the array refs
        my @phrases = (
                $phrase1, $phrase2,
                $phrase3, $phrase4
        );

        # Learn the data set    
        $net->learn_set(\@phrases);
        
        # Run a test phrase through the network
        my $test_phrase = $net->crunch("I love neural networking!");
        my $result = $net->run($test_phrase);
        
        # Get this, it prints "Jay Leno is  networking!" ...  LOL!
        print $net->uncrunch($result),"\n";

=cut


=pod
my $dsn = "DBI:mysql:host=localhost;database=fsb";


my $dbh=DBI->connect($dsn, 'root', 'andrew', { RaiseError => 1});

$dbh->do("SET charset cp1251;");

$dbh->do("SET names   cp1251;");

my ($max,$count)=$dbh->selectrow_array(q[SELECT max(amnt_number),count(*) FROM search_table]);

my $window=100;
my $search_amnt=1000;
$count=int($count/$window)+ceil($count%$window);
for(0 .. $count)
{
	my $ref=$dbh->selectall_arrayref(q[SELECT amnt_number,id FROM search_table LIMIT ].($_*$window).q[,].($_*$window+$window));
	my @Data;
	map {push @Data,[qq/$_->[0]/]} @{ $ref };
	push @Data,[qq/$search_amnt/];
	# 	my @Data  = [[qw/0.3 0.5/],[qw/0.3 0.6/],[qw/0.6 0.8/],[qw/0.02 0.6/]];
	my @bound = [[qw/0/],[qq/$max/]];
	my $subC = new AI::subclust(-data=>\@Data,-bounds=>@bound);
        my ($CLU,$S) = $subC->calculate();
	#print Dumper $CLU,$S;
	#print "-----------------\n";


}
$dbh->disconnect();
=cut

    	


=pod
my $net = AI::NeuralNet::Simple->new(4,100,1);
# teach it logical 'or'



for (1 .. 1000000) {
	
     $net->train([1,1,1,1],[1]);
     $net->train([1,1,0,0],[0]);
     $net->train([0,1,0,1],[1]);
     $net->train([1,0,1,0],[1]);
     $net->train([0,0,0,0],[1]);
     $net->train([0,0,0,1],[.5]);	
     $net->train([0,0,1,0],[.5]);	
     $net->train([1,1,1,0],[.5]);
     $net->train([1,1,0,1],[.5]);
     $net->train([0,0,1,1],[0]);
     

    

}
  printf "Answer: %d\n",   $net->winner([1,1,1,1]);
  printf "Answer: %d\n",   $net->winner([0,0,1,1]);
=cut

