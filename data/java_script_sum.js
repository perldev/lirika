var _sum=0;
var summed=[];
var title=document.title;
var is_sum=0;
function get_sum_from_html(o)
{
	 	var n=o.innerHTML;
        	n=n.replace(/<nobr[^>]*>/g,"");
		
		
		n=n.replace(/[^0-9\.\-]/g,"");
		                                                                                                   
		                 n=n.replace(/--/g,"-");   
		return n*1;

}
function sum2(o)
{
            is_sum=0;
            
            
}
function sum1(o){
            
             if(!is_sum)
                return;

            
            var n=o.innerHTML;
            n=n.replace(/<nobr[^>]*>/g,"");
//             n=n.replace(/ - -|- -|--|/g,"-"); 
            n=n.replace(/[^0-9\.\-]/g,"");
                                                                                                  
                 n=n.replace(/--/g,"-");            
           n=n*1;
           if (!o.className.match('summed')){
                       _sum+=parseInt(parseFloat(n)*100);
                       if (o.className)
                           o.oldclass=o.className;
                       else
                           o.className='';
                       o.className=o.className+' summed';
                       summed.push(o);
               } else {
                       _sum-=parseInt(parseFloat(n)*100);
		       
                       o.className=o.oldclass;
               }
	       var s=_sum/100;
	                      s=on_decs3(s);
			      
               document.title='(яслл = ' + s + ') ' + title;
 }

function sum(o){
             var n=o.innerHTML;
        	n=n.replace(/<nobr[^>]*>/g,"");
		n=n.replace(/[^0-9\.\-]/g,""); 
		n=n.replace(/--/g,"-"); 
//		    n=n.replace(/--/g,"-");      
//		    n=n.replace(/[^0-9\.\-]/g,"");
		    is_sum=1;
	       n=n*1;
	       if (!o.className.match('summed')){
                       _sum+=parseInt(parseFloat(n)*100);
                       if (o.className)
                           o.oldclass=o.className;
                       else
                           o.className='';
                       o.className=o.className+' summed';
                       summed.push(o);
               } else {
                       _sum-=parseInt(parseFloat(n)*100);
                       o.className=o.oldclass;
               }
	       var s=_sum/100;
	       s=on_decs3(s);
	       
               document.title='(яслл = ' + s + ') ' + title;
 }

 function clearsum(){
   var i;
   for (i in summed){
       summed[i].className=summed[i].oldclass;
       _sum=0;
       document.title=title;
   }
 }

function form_work(don)
{
	if(don=='clear')
	{
		clearsum();
	}else
	{
		document.getElementById('do').value=don;
		document.getElementById('my_form').submit()
	}
}




