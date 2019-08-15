package MyConfig;
use strict;
use Exporter;
our @ISA = ("Exporter");
our @EXPORT = qw(
	$path 
	trim
	
); #exported subs


our $path='/usr/local/www/lib';
sub trim {                                                                                                                                                   
    @_ = @_ ? @_ : $_ if defined wantarray;                                                                                                                  
                                                                                                                                                                 
        for (@_ ? @_ : $_) { s/\A\s+//; s/\s+\z// }                                                                                                              
	                                                                                                                                                             
	    return wantarray ? @_ : "@_";                                                                                                                            
	    }                                                                                                                                                            
	           

1;
