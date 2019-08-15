var REQ;
        var NORMAL_WIDTH=1024;
		var READY_STATE_COMPLETE=4;
		function getHttp()
		{
			var req=null;
			if(window.XMLHttpRequest)
			{
					
				req=new XMLHttpRequest();
				return req;
			}else if (window.ActiveXObject)	
			{
				req=new ActiveXObject("Microsoft.XMLHTTP");
				return req;
			}else
			{
				alert("sorry,change you browser please");
				return req;
			}
		
        }
///
        function is_id_defined(id){
        
            return document.getElementById(id);

        }

        function sum_this(obj,num,col){
                
                 var tbl=document.getElementById('my_table');
                 if(!tbl)
                    return;                    
                var rows=tbl.rows;
                size=rows.length;
                
                for(var j=num;j<size;j++)
                {
                    var cells=rows[j].cells;
                    sum(cells[col]);
                }
                 
                sum2();
            
                if(obj.className.match('summed'))
                    obj.className='table_gborders';
                else
                     obj.className='summed';
                 

        }

		function checkAllOper(obj,id)
		{
           var x=document.getElementsByTagName("input");
			  for(var i=0;i<x.length;i++)
		  	  {
				if(x[i].id==id)
				{
					x[i].checked=obj.checked;
					
				}

		  	 }
		}
		function SendRequest(url,params,HttpMethod,listener)
		{
			if(!HttpMethod)
				HttpMethod='POST';
			
			 REQ=getHttp();
			if(REQ)
			{
				REQ.onreadystatechange=listener;
				REQ.open(HttpMethod,url,true);
				REQ.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				REQ.send(params);
			}
		
		}
        function SendRequest2(REQ,url,params,HttpMethod,listener)
        {
            if(!HttpMethod)
                HttpMethod='POST';
            
            if(REQ)
            {
                REQ.onreadystatechange=listener;
                REQ.open(HttpMethod,url,true);
                REQ.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
                REQ.send(params);
            }else{
                alert("I cant create browser");
            }
        
        }
function close_deals(){
    document.getElementById('do').value='close_deals';
    document.getElementById('my_form').submit();


}
function check_all_in(obj){
	
	if(obj.checked){
		$('input[@name="ct_id"]:checkbox').attr({'checked':true})

	}else{
		 $('input[@name="ct_id"]:checkbox').attr({'checked':false})
	}
	


}


//editing ct_comment for cash requests
function sort_by_common_number(table_id,from,ev,obj){

    var flag=document.getElementById('flag').value;
    if(flag==-1)    
        return ;

    var sort_func;
    if(flag==1)
    {
        obj.innerHTML='Отсортировать по убыв';
        sort_func=my_sort_func_dec;
        flag=0;

    }else{
        
        sort_func=my_sort_func;
        obj.innerHTML='Отсортировать по возв';
        flag=1;
    }

    document.getElementById('flag').value=-1;
   

    var size=document.getElementById('calc_size').value;
    var my_array=new Array();
    var buffer_array= new Array();
    var i;

    for(i=1;i<=size;i++){
        var new_obj=document.getElementById('calc_'+i);
        my_array.push(new_obj);
    }
   
        my_array=my_array.sort(sort_func);


    
    var my_table=document.getElementById(table_id);
    var rows=my_table.rows;
    size=my_array.length;

    
    for (i=0;i<size;i++){
        var row=rows[i+from].innerHTML;
        var cl= rows[i+from].className;       
        var id_= rows[i+from].id;       
       
 
        var row1=document.getElementById('account_'+my_array[i].name);
     
        if(row1.id==id_)
                continue;
      

        var row_new=row1.innerHTML;
        var class_new= row1.className;       
        var id_new= row1.id;   

        rows[i+from].innerHTML=row_new;
        rows[i+from].className=class_new;
        rows[i+from].id=id_new;
        
        row1.className=cl;
        row1.innerHTML=row;
        row1.id=id_;

        
    }
        
    

    document.getElementById('flag').value=flag;
    



}
function my_sort_func_dec(a,b){
    return  b.value-a.value;


}
function my_sort_func(a,b){
    return  a.value-b.value;
}







function changing_comis(ct_amnt,fsid,ct_comis,ct_common_amnt,ct_aid){
    
    var fsid_=fsid;
    var ct_amnt_=ct_amnt;
    var ct_comis_=ct_comis;
    var ct_common_amnt_=ct_common_amnt;
    var ct_aid_=ct_aid;
    
    
    var services_percents=new Array();
    var obj=this;    
    var val_fsid=0;
    var val_ct_amnt=0;
    var val_ct_comis=0;
    var val_ct_common_amnt=0;

    document.getElementById(fsid_).value='';

    this.amnt_changed=function(){

             val_ct_comis=get_element(ct_comis_,1);
             var c=get_element(ct_amnt_,1);
             val_ct_amnt=c;

            var sum=1*val_ct_amnt+1*(val_ct_comis*(val_ct_amnt/(1-val_ct_comis/100)/100));
            sum=Math.ceil(sum*100)/100;
            set_element(ct_common_amnt_,sum); 
    

    }
    this.getReq_services=function(){
                    var ready=REQ.readyState;
                    var data=null;
                    if(ready==READY_STATE_COMPLETE)
                    {
                        data=REQ.responseText;
                        obj.fill_array_services(data);
                        //very important thing there 
                        obj.service_changed();
                        
                        start_=0;
                    }
        

    }
    this.fill_array_services=function(data){
                        //read xml      
                        if (window.ActiveXObject)
                        {
                            var doc=new ActiveXObject("Microsoft.XMLDOM");
                            doc.async="false";
                            doc.loadXML(data);
                        }// code for Mozilla, Firefox, Opera, etc.
                        else
                        {
                            var parser=new DOMParser(); 
                            var doc=parser.parseFromString(data,"text/xml");
                        }
                        
                        
                        var x=doc.documentElement;
                        var users=x.getElementsByTagName("user");
                        var services=x.getElementsByTagName("service");
                        var percents=x.getElementsByTagName("percent");
                        for(var i=0;i<users.length;i++)
                        {
                            
                            var tmp=new Array();
                            tmp[0]=users[i].childNodes[0].nodeValue*1;
                            tmp[1]=services[i].childNodes[0].nodeValue*1;
                            if(percents[i].childNodes[0]&&percents[i].childNodes[0].nodeValue)
                                        tmp[2]=percents[i].childNodes[0].nodeValue*1;
                            
                            services_percents.push(tmp);
                            
                        }
                        
                        
                        //  
                        
                    
                    
                }
                
            
                this.search_if_exist=function(id,service)    
                {
                    if(!id||!service)
                        return;
                        id=id*1;
                        service=service*1;
                        for(var i=0;i<services_percents.length;i++)
                        {
                            
                            if(1*services_percents[i][0]==id&&1*services_percents[i][1]==service)
                            {   
                                return services_percents[i][2]*1;
                            }
                
                        }
                    
                    return null; 
                }


                this.service_changed=function()
                {
            
            
                    var selected_service=document.getElementById(fsid_).value;
                    if(!fsid_)
                        return;
                   

                    var  id_val;
                    if(document.getElementById(ct_aid_+'__select'))
                    {
                        id_val=document.getElementById(ct_aid_+'__select').value;
                        document.getElementById(ct_aid_).value=id_val;
                    }
                    else if(document.getElementById(ct_aid_).value)
                        id_val=document.getElementById(ct_aid_).value;


                    var val=this.search_if_exist(id_val,selected_service);
		    
                    if(!val&&val!=0)
                         SendRequest("ajax.cgi","do=get_account_services_percent&service="+selected_service,'POST',this.getReq_services);
                    else
                    {
                         set_element(ct_comis_,val);
                        this.comis_changed();
                    }
            
            
                }

                this.comis_changed=function()
                {
                    this.amnt_changed();
            
                }
                this.common_amnt_changed=function()
                {
                                    
                                    val_ct_comis=get_element(ct_comis_,1);
                                    val_ct_common_amnt=get_element(ct_common_amnt_,1);
                                
                                    if(!val_ct_comis)
                                    {
                                        document.getElementById(ct_amnt_).value=val_ct_common_amnt;
                                        return;
                    
                                    }
            
                                    var k=(100-val_ct_comis)/val_ct_comis;
                                
                                    var amnt=val_ct_common_amnt-(val_ct_common_amnt/k);
                                    amnt=Math.ceil(amnt*100)/100;
                                    set_element(ct_amnt_,amnt);
            
                }
            
            }
//used in 
        function show_select_form(obj,id,cash){
            var ob=document.getElementById('comment_edit_cash_form');
            $('#comment_edit_cash_form').hide('slow');

            var pa=ob.parentNode;
            pa.removeChild(ob);

            var pb=obj.parentNode;
            pb.appendChild(ob);


            $('#change_ct_id').attr({ 'value' : id });
            document.getElementById('change_ct_fid').value=cash;
            $('#comment_edit_cash_form').show('slow');
                        
        }
        function edit_cash_firm_req(){
            var id=$('#change_ct_id').attr('value');
            var new_val=$('#change_ct_fid').attr('value');
            $.post('ajax.cgi','do=edit_cash_office&id='+id+'&cash_office='+new_val,
            function (dat){
                $('#not_processed_'+id).css({'display' : 'none'});
            } ,'html'); 
          
        }
        function edit_cron_req(idForm){
            var id=$('#change_c_id').attr('value');
            var field=$('#change_field').attr('value');
            var new_val=$('#val').attr('value');
            
            $.post('ajax.cgi','do=edit_cron_rule&id='+id+'&field='+field+'&val='+new_val,
            function (dat){
            	var patt=new RegExp('ok,|:|:|');
        
                if( patt.test(dat) )
            	{
            		var res=dat.replace('ok,|:|:|','');

                    results=res.split(/\|\:\|\:\|/);
                    var  id = results[0];
                    var  val = results[1];
                    //alert(id);
                    var o = document.getElementById(id);
                    o.innerHTML= val;
                    
                    //alert(val);
            	}
            	else
            	{
            		alert(dat);
            	}
                $('#'+idForm).css({'display' : 'none'});
            } ,'html'); 
          
        }

        function update_cron_field(field,obj){
            var id=$('#change_ct_id').attr('value');
            var new_val=$('#change_ct_fid').attr('value');
            $.post('ajax.cgi','do=edit_cash_office&id='+id+'&cash_office='+new_val,
            function (dat){
                $('#not_processed_'+id).css({'display' : 'none'});
            } ,'html'); 

        }
        
        function delete_firewall_rule(obj,id){
            $.post('ajax.cgi','do=del_firewall_rule&id='+id,
            function (dat){
                    $('#rule_'+id).css({ 'display':'none' });
            },'html');
        }
        function delete_cron_rule(obj,id){
            $.post('ajax.cgi','do=del_cron_rule&id='+id,
            function (dat){
                    $('#rule_'+id).css({ 'display':'none' });
            },'html');
        }
        function ajax_action_firewall_delete_object(i){
            var i_=i;
            this.listener=function(){
                      delete_firewall_rule(null,i_); 
            }
            
        }
        function ajax_action_cron_delete_object(i){
            var i_=i;
            this.listener=function(){
                      delete_cron_rule(null,i_); 
            }
            
        }

        function clear_firewall_rule_form(){
            $('#fs_comment').attr({'value':'Новое правило'});
            $('#fs_rule').attr({'value':''});
            $('#fs_ip').attr({'value':''});
            $('#fs_port').attr({'value':''});
            $('#fs_number').attr({'value':''});

        }
        function add_firewall_rule(){
                var com=document.getElementById('fs_comment').value;
              
                var number=document.getElementById('fs_number').value;


                var rule=document.getElementById('fs_rule').value;
            	
                var ip=document.getElementById('fs_ip').value;
             

                var prt=document.getElementById('fs_port').value;
                          
                $.post('ajax.cgi','do=add_firewall_rule&fs_src_ip='+ip+'&fs_rule='+rule+'&fs_port='+
                prt+'&fs_comment='+com+'&fs_number='+number,
                function (dat){
    
                    var patt=new RegExp('ok');
        
                    if(! patt.test(dat) ){
        
                        $('#error').html(dat);
                    
                    }else{
                
                    $("#firewall_div").hide('slow');
                        var new_id=dat.replace('ok,','');
                        ids=new_id.split(/,/);
                        var new_number= ids[1]*1;
                        var new_id=ids[0]*1;

                        var table=document.getElementById('my_table');
                        var tables=table.rows;
                        var insert_row=tables.length;

                        for(var i=3;i<tables.length;i++){

                            cells=tables[i].cells;
							
                            var s=cells[0].innerHTML*1;

                            if(s>new_number){
                            
                                insert_row=i;
                                break;
                            }


                        }
                		
                        var row=table.insertRow(insert_row);

                        row.setAttribute('id','rule_'+new_id);
                        	
                        var opts_0=row.insertCell(0);
                        opts_0.setAttribute('class','table_gborders');

                        opts_0.innerHTML=new_number;
						
                        var opts_1=row.insertCell(1);
                        opts_1.setAttribute('class','table_gborders');
                        var d=new Date();

                        opts_1.innerHTML=d.getDate()+'.'+(d.getMonth()*1+1)+'.'+(d.getFullYear())+" "+d.toLocaleTimeString();

                        var opts_2=row.insertCell(2);
                        opts_2.setAttribute('class','table_gborders');

                        var opts_3=row.insertCell(3);
                        opts_3.setAttribute('class','table_gborders');
						
                        var opts_4=row.insertCell(4);
                        opts_4.setAttribute('class','table_gborders');

                        var opts_5=row.insertCell(5);
                        opts_5.setAttribute('class','table_gborders');
                        
                        

                        var opts_6=row.insertCell(6);
                        opts_6.setAttribute('class','table_gborders');

                        var opts_7=row.insertCell(7);
                        opts_7.setAttribute('class','table_gborders');

                    
                        opts_2.innerHTML=com;

                        opts_3.innerHTML="<strong>"+RULES_HASH[rule]+"</strong>";

                        opts_4.innerHTML=prt;
                        opts_5.innerHTML=ip;
                
                        var tab = document.createElement('span');
                        tab.setAttribute('class','simple_tab');
                        tab.innerHTML='Удалить';
                        var del_obje=new ajax_action_firewall_delete_object(new_id);
                        tab.onclick = del_obje.listener;
                        opts_7.appendChild(tab);            
                
        
                    }
        
        
                
    
                } ,'html'); 
                
    
                        
    
    
        }
    
		
		function add_cron_rule(){
                var com=document.getElementById('c_comment').value;
                var comand=document.getElementById('c_comand').value;
                var min=document.getElementById('c_minute').value;
                var h=document.getElementById('c_hour').value;
                var d=document.getElementById('c_day').value;
                var m=document.getElementById('c_month').value;
                var d_of_w=document.getElementById('c_day_of_week').value;
             
                $.post('ajax.cgi','do=add_cron_rule&c_comment='+com+'&c_comand='+comand+'&c_minute='+
                min+'&c_hour='+h+'&c_day='+d+"&c_month="+m+"&c_day_of_week="+d_of_w,
                function (dat){
    				
                    var patt=new RegExp('ok');
        			
                    if(! patt.test(dat) ){
        
                        $('#error').html(dat);
                    
                    }else{
                	
                    $("#cron_div").hide('slow');
                        var new_id=dat.replace('ok,','');
                        ids=new_id.split(/,/);
                        var new_id=ids[0]*1;
						
                        var table=document.getElementById('my_table');
                        var tables=table.rows;
                        var insert_row=tables.length;

                        //for(var i=3;i<tables.length;i++){

                            //cells=tables[i].cells;

                            //var s=cells[0].innerHTML*1;

                            //if(s>new_number){
                            
                                //insert_row=i;
                                //break;
                            //}
                        //}
                		
                        var row=table.insertRow(insert_row);

                        row.setAttribute('id','rule_'+new_id);
						
                        var opts_0=row.insertCell(0);
                        opts_0.setAttribute('class','table_gborders');

                        opts_0.innerHTML=new_id;

                        var opts_1=row.insertCell(1);
                        opts_1.setAttribute('class','table_gborders');
                        var da=new Date();

                        opts_1.innerHTML=da.getDate()+'.'+(da.getMonth()*1+1)+'.'+(da.getFullYear())+" "+da.toLocaleTimeString();

                        var opts_2=row.insertCell(2);
                        opts_2.setAttribute('class','table_gborders');
						opts_2.innerHTML=com;
                        var opts_3=row.insertCell(3);
                        opts_3.setAttribute('class','table_gborders');
						opts_3.innerHTML=comand;
                        var opts_4=row.insertCell(4);
                        opts_4.setAttribute('class','table_gborders');
						opts_4.innerHTML=min;

                        var opts_5=row.insertCell(5);
                        opts_5.setAttribute('class','table_gborders');
                        opts_5.innerHTML=h;

                        

                        var opts_6=row.insertCell(6);
                        opts_6.setAttribute('class','table_gborders');
                       	opts_6.innerHTML=d;

                        var opts_7=row.insertCell(7);
                        opts_7.setAttribute('class','table_gborders');
                       	opts_7.innerHTML=m;
                        var opts_8=row.insertCell(8);
                        opts_8.setAttribute('class','table_gborders');
                       	opts_8.innerHTML=d_of_w;
                       	var opts_9=row.insertCell(9);
                        opts_9.setAttribute('class','table_gborders');
                        var tab = document.createElement('span');
                        tab.setAttribute('class','simple_tab');
                        tab.innerHTML='Удалить';
                        var del_obje=new ajax_action_cron_delete_object(new_id);
                        tab.onclick = del_obje.listener;
                        opts_9.appendChild(tab);
                    }
        
        
                
    
                } ,'html'); 
                
    
                        
    
    
        }

		
		
        function show_edit_form(obj,id)
        {
            
            if(!id)
                id='comment_form';

            var ob=document.getElementById(id);
    
            $('#'+id).hide('slow');


            var pa=ob.parentNode;
            pa.removeChild(ob);            

            var pb=obj.parentNode
            pb.appendChild(ob);
    
            var str=obj.innerHTML;
            str=str.replace(/[\t ]/,'');
            $('#ct_comment').attr({ value: str });
            $('#'+id).show('slow');
            $('#ct_id').attr({ value: obj.id });

    
        }

        
        
        function show_sum_edit_form(obj,id,id2)
        {
            
            if(!id)
                id='comment_form';

            var ob=document.getElementById(id);
    
            $('#'+id).hide('slow');


            var pa=ob.parentNode;
            pa.removeChild(ob);            

            var pb=obj.parentNode
            pb.appendChild(ob);
    
            var str=obj.innerHTML;
            str=str.replace(/[\t ]/g,'');
            $('#ct_amnt').attr({ value: str });
            $('#'+id).show('slow');
            $('#ct_id').attr({ value: id2 });

    
        }
        
        
 

        function edit_cash_req(id)
        {
               var val=$('#ct_comment').attr('value');
               var id='#'+$('#ct_id').attr('value');
               $(id).html(val);
               $(id).attr({title:val});
               $('#comment_form').hide('slow');
               SendRequest('ajax.cgi','do=ajax_edit_comment&id='+$('#ct_id').attr('value')+'&ct_comment='+val,'POST',NULL_FUNC);

        }
        function edit_amnt_req(id)
        {
               var val=$('#ct_amnt').attr('value');
               //var id='#sum_'+$('#ct_id').attr('value');
               //$(id).html(val);
               //$(id).attr({title:val});
               $('#amnt_form').hide('slow');
               SendRequest('ajax.cgi','do=ajax_edit_amnt&id='+$('#ct_id').attr('value')+'&ct_amnt='+val,'POST',after_edit_amnt_req);

        }
        function after_edit_amnt_req(drid)
		{
            var ready=REQ.readyState;
            if(ready==READY_STATE_COMPLETE)
            {
            	if(REQ.responseText!='error')
            	{
            		var arr = REQ.responseText.split("|",2);
	            	var id='#sum_'+arr[0];
	        	    $(id).html(arr[1]);
	                $(id).attr({title:arr[1]});
            	}
	            //alert(REQ.responseText);
            }       
		}

///deleting header rate

       function del_header_rate_record(id){
 		
            var r=confirm("Вы точно хотите удалить запись  #"+id+" \n");
            if (r==true){
                id_="row_"+id;
                var ob=document.getElementById(id_);
                var pb=ob.parentNode;
                pb.removeChild(ob); 
                SendRequest('ajax.cgi','do=ajax_del_header_rate&id='+id,'POST',NULL_FUNC);
           }  else {
                return ;                            
            }
        

        }

//searchig sums in firm payments
    function	on_decs3(str21){
        
        
	var str=new String(str21);
	
        var dot=str.indexOf(".");
        var str1;
	
	if(dot>0)    
		str1=str.slice(0,dot);
	else
		str1=str;
		
        var size=str1.length;
    
	var new_str='';
        var i;
	
	for(i=size;i>0&&i>3;i-=3){
	      
	      new_str=str1.slice(i-3,i)+new_str;
    	      new_str=" "+new_str;
	}
	new_str=str.slice(0,i)+new_str;
	if(dot>0)
	    new_str=new_str+str.slice(dot);
	return new_str;
    }

	    function get_founded()
		{
				var ready=REQ.readyState;
				var data=null;
				if(ready==READY_STATE_COMPLETE)
				{
					data=REQ.responseText;
					fill_array_founded_firms(data);	
	
				}	
	
	
		}
        function getScrollXY() {
        var scrOfX = 0, scrOfY = 0;
        if( typeof( window.pageYOffset ) == 'number' ) {
            //Netscape compliant
            scrOfY = window.pageYOffset;
            scrOfX = window.pageXOffset;
        } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
            //DOM compliant
            scrOfY = document.body.scrollTop;
            scrOfX = document.body.scrollLeft;
        } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
            //IE6 standards compliant mode
            scrOfY = document.documentElement.scrollTop;
            scrOfX = document.documentElement.scrollLeft;
        }
            return [ scrOfX, scrOfY ];
        }
       
    function my_float()
    {
         var header=document.getElementById('float_header');
         if(!header)
            return ;
    

        var dimens=getScrollXY();
        if(dimens[1]<400)
            header.style.display='none';
        else
            header.style.display='';
    }   




function ajax_show_spents_event(drid)
{
    var id=drid;  

    this.listener=function(){

            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
                var s=document.getElementById(id+'_spents');
//alert(REQ.responseText);
         s.innerHTML=REQ.responseText;
            }       

    }
}

function ajax_show_spents(event,id)
{
    var ob=document.getElementById(id+'_spents');
    if(ob)    
    {
         
        if(ob.style.display=='none')
        {
               ob.style.display='';
        }    
        else
        {
              ob.style.display='none';
        }         
    }else
    {
            var new_obj=document.createElement('div');
         
            new_obj.setAttribute('class','center_div_table_poup_no_limit');
            new_obj.innerHTML='<strong>подождите думаю ;) </strong>';
            new_obj.setAttribute('id',id+'_spents');
            new_obj.style.position='absolute';
            var xy=getScrollXY();
            new_obj.style.left=0;
            //alert(event.y);
            new_obj.style.top=event.clientY+50;
            
            new_obj.style.display='';

            var l=document.getElementById('my_table')

            l.appendChild(new_obj);
            var str="do=ajax_show_spents&id="+id;

            var ob_=new ajax_show_spents_event(id);

            SendRequest('ajax.cgi',str,'POST',ob_.listener);
            
        
        
        
    }
}



        
		function fill_array_founded_firms(data)
		{
				
			
				if(window.ActiveXObject)
  				{
  					var doc=new ActiveXObject("Microsoft.XMLDOM");
					doc.async="false";
  					doc.loadXML(data);
  				}// code for Mozilla, Firefox, Opera, etc.
				else
  				{
  					var parser=new DOMParser();	
  					var doc=parser.parseFromString(data,"text/xml");
  				}
				
				
				var x=doc.documentElement;
				var records=x.getElementsByTagName("record");
				var accounts=x.getElementsByTagName("user");
				var firms=x.getElementsByTagName("firm");
				var my_table_=document.getElementById('add_form_table');
					
				for(var i=0;i<firms.length;i++)
				{
					
					var my_table=my_table_.insertRow(size+2);
					my_table.className='table_gborders';
					var y=my_table.insertCell(0);
					y.className='table_gborders';
                    y.setAttribute('colspan',2);
					var z=my_table.insertCell(1);
					z.className='table_gborders';
                    z.setAttribute('colspan',2);
					var f=my_table.insertCell(2);	
                    f.setAttribute('colspan',2);
					f.className='table_gborders';

					
					z.innerHTML=records[i].childNodes[0].nodeValue;
					f.innerHTML=firms[i].childNodes[0].nodeValue;
				if(accounts[i].childNodes[0]&&accounts[i].childNodes[0].nodeValue)
				{
					y.innerHTML=accounts[i].childNodes[0].nodeValue;
				}else
				{
					y.innerHTML='';
				}
					
				}
				if(firms.length==0)
				{
					
					var my_table=my_table_.insertRow(size+2);
					my_table.className='table_gborders';
				
					var z=my_table.insertCell(0);

					z.className='table_gborders';

				
					z.innerHTML=" Совпадений за предыдущие  дни не найдено..";
					 z.setAttribute('colspan',6);

				}
			



		}
	
	


	function search_sum(sum,currency) 
	{
		var rows=document.getElementById('add_form_table').rows;
		if(rows.length==size)
		{
			var my_table=document.getElementById('add_form_table').insertRow(rows.length);
			my_table.className='table_gborders';
			
			var y111=my_table.insertCell(0);
			y111.setAttribute('colspan',6);
			y111.className='table_gborders';
			y111.innerHTML="Поиск похожих сумм ...";
			var my_table1=document.getElementById('add_form_table').insertRow(rows.length);
			my_table1.className='table_gborders';
			var y1=my_table1.insertCell(0);
			y1.className='table_gborders';
            y1.setAttribute('colspan',2);

			var z1=my_table1.insertCell(1);
			y1.innerHTML="Клиент :";
			z1.innerHTML="Подробности :";	
            z1.setAttribute('colspan',2);
			z1.className='table_gborders';
			var z2=my_table1.insertCell(2);
			z2.className='table_gborders';
            z2.setAttribute('colspan',2);
			z2.innerHTML='Фирма :';
		}
		SendRequest('ajax.cgi','do=search_amnt_bn&ct_amnt='+sum+'&ct_currency='+currency,'POST',get_founded);
		
	

	}	

function select_clear(sel){
        var len=sel.length;
                
        for(var i=0;i<len;i++)
        sel.remove(0);
}


function set_element(id,val)
{
		if(!document.getElementById(id))		
				return ;
			
		 if(document.getElementById(id).type)
					{	
						 document.getElementById(id).value=val;
					}			
		else if(document.getElementById(id).innerHTML||document.getElementById(id).innerHTML=='')
					{
						document.getElementById(id).innerHTML=val;
					}
					else
					{
						document.getElementById(id).value=0;
					}
					
		}
function select_change()
{

	return false;
}
function get_normal_date(date_name)
{

	var  my_id=date_name+'_Day_ID';
    var opt=document.getElementById(my_id).options;
	var day=opt[document.getElementById(my_id).selectedIndex].text;
	var month=document.getElementById(date_name+'_Month_ID').value;
	var year=document.getElementById(date_name+'_Year_ID').value;
	
	month=month*1+1;
	if(month<=9)	
		 month='0'+month;
	if(1*day<=9)	
		 day='0'+day;

	var date=year+'-'+month+'-'+day;
	return date;


}
function calculate_exchange(amnt,rate,from,to)
{
	var rate_form;
	if(rate_forms[from]&&rate_forms[from][to])
        {
                                rate_form=rate_forms[from][to];  
        }else
	{
				rate_form=1;
	}	
	rate=Math.pow(rate,rate_form);
	return Math.floor(((rate)*amnt)*100)/100;
}
function calculate_rate(rate,from,to){
	var rate_form;
        if(rate_forms[from]&&rate_forms[from][to]){
	        rate_form=rate_forms[from][to];
	}else{
	        rate_form=1;
	}
	    rate=Math.pow(rate,rate_form);
	    return rate;
}
							
							
function get_element(id,type)
{	
  
  
					if(!document.getElementById(id))		
						return 0;
						var str;
					
						if(document.getElementById(id).type)
							str=document.getElementById(id).value;		
						else if(document.getElementById(id).innerHTML)
							str=document.getElementById(id).innerHTML;
						else
							str=0;

				if(type)
				{
				      
				      		
				      if(str!='')
					{
						str=str.replace(/[ ]/,'');
						str=str.replace(/[,]/,'.');
						set_element(id,str);
					}
					return  str;
				
				}else
				{
					return str;
				}
					
}
function select_add_option(sel, value, text){

          var y=document.createElement('option');
          y.text=text;
          y.value=value;
          try
          {
            sel.add(y,null); // standards compliant
          }
          catch(ex)
          {
            sel.add(y); // IE only
          }
}

function selectedValue(selectObj){
  return selectObj.options[selectObj.selectedIndex].value;
}
function  selectedName(selectObj){
	var val=selectedValue(selectObj);
	var len=accounts.length;
	
  	for(var i=0;i<len;i++){
    	var account = accounts[i];
  	       if(account[0]==val)
      			return account[1];
		
    		}
}

function accounts_id_event(id){
  var id_obj = document.getElementById(id);
  var sel_obj = document.getElementById(id+'__select');

  var id_val = id_obj.value;

  select_clear(sel_obj);

  
  if(id_val=='')
  {
	  	var len=accounts.length;
  		for(var i=0;i<len;i++){
    		var account = accounts[i];
  	        if(account)
      			select_add_option(sel_obj, account[0], account[2]);
		
    		}
	  var search_obj = document.getElementById(id+'__search');
 	  search_obj.value=selectedName(sel_obj);
	
	  return;
  
  }

  var len=accounts.length;
   
  for(var i=0;i<len;i++){
    var account = accounts[i];

    if(account)
    if(account[0] == id_val){
      select_add_option(sel_obj, account[0], account[2]);
    }
  }
if(search_obj)
  search_obj.value=selectedName(sel_obj);
  var selected_service=document.getElementById('ct_fsid');
	if(selected_service)
		change_services();
  return true;
}

function trim(val){   
   //val = val.replace(/^(\s*)(.*)(\s*)$/, "$2");
   return val;
}
function clear_search_select(){
    

}
function select_account_from_value(obj,ind){
    var of_fid=obj.value;
    var a_id=OUT_FIRMS[of_fid];
    var account_title='';
    if(!a_id){
         account_title='неизвестен';
    }else{
         account_title= ACCOUNTS[a_id];
     }
    $('#account_'+ind).html(account_title);
}
function search_in_select(obj,id,event){


    var sel=document.getElementById(id);
    var opts=sel.options;
    var tmp;


    var str=obj.value;
    str=str.toLowerCase();
    
        if(event.keyCode==8)
        {
                  sel.selectedIndex=0;
                  
        }
    if(str.length<2){
        return ;
    } 

       
        if(event.keyCode==40)
        {

            var i=sel.selectedIndex;
            from=++i;
    
        }else if(event.keyCode==38) {
            var i=sel.selectedIndex;
            to=--i;
            first=0;


        }

    var patt=new RegExp("^"+str);
    var fin=1;
    for(var i=0;i<opts.length;i++)
    {
        tmp=opts[i].text;
        tmp=tmp.toLowerCase();
        if(patt.test(tmp)==true)
        {
            fin=0;
            sel.selectedIndex=i;
            
        }
    }
    if(fin)
        sel.selectedIndex=0;


}
function change_comis(ind){

      var ct_amnt=$('#ct_amnt_'+ind).attr('value');
      var percent=$('#percent_'+ind).attr('value');
       if(!percent)
            return;
       if(!ct_amnt)
            return;   

      ct_amnt=ct_amnt.replace(" ","");
      percent=percent.replace(" ","");
      ct_amnt=ct_amnt.replace(",",".");
      percent=percent.replace(",","."); 
      if(!(percent*1))
           return;
      
      if(!(ct_amnt*1))
           return;
    
      var sum_comis=(ct_amnt/100)*percent;
      var common_sum=ct_amnt-Math.abs(sum_comis);
      $('#sum_comis_'+ind).html(sum_comis);
      $('#common_'+ind).html(common_sum);
      return ;
}


function accounts_search_event(id){
  var id_obj = document.getElementById(id);
  var search_obj = document.getElementById(id+'__search');
	
  var sel_obj = document.getElementById(id+'__select');
  var search = ''+search_obj.value;
  search = trim(search);
  search = search.toLowerCase();

  if(search == '') return true;
	
	

  select_clear(sel_obj);

  var len=accounts.length;  
  var id_val = 0;
  for(var i=0;i<len;i++){

    var account = accounts[i];
    if(account)
    if(account[1].toLowerCase().indexOf(search) == 0){
	
      select_add_option(sel_obj, account[0], account[2]);

      if(id_val == 0) id_val=account[0];
    }
  }

  if(id_val) id_obj.value = id_val;

	if(document.getElementById('ct_fsid'))
		change_services();

  return true;
}


function accounts_select_event(id){
  var id_obj = document.getElementById(id);

  var sel_obj = document.getElementById(id+'__select');
  var search_obj = document.getElementById(id+'__search');



  var id_val = selectedValue(sel_obj);
  //search_obj.value=sel_obj.value;
  id_obj.value = id_val;
	
   if(document.getElementById('ct_fsid'))
   {	   
	
	
	var selected_service=document.getElementById('ct_fsid');
	if(selected_service)
	{
		
		change_services();
				
	}else
	{  	
		select_clear(sel_obj);
		var len=accounts.length;
  		for(var i=0;i<len;i++)
		{
    			var account = accounts[i];
  	      		select_add_option(sel_obj, account[0], account[2]);
		
    		}	
	
	}
    
    }
  return true;
}
/*
id_left_$row
id_center_$row
id_right_$row.id
*/			
//SendRequest('ajax.cgi','do=set_col_all&col_status=no&a_id='+a_id,'POST',getReq);

function del_cells(id,id1)
{
	this.id = id;
	this.id1 = id1;

  	this.listener=function(){

    		var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
								
document.getElementById('id_left_'+id1).innerHTML='';
document.getElementById('id_center_'+id1).innerHTML='<span class="simple_tab">удалена</span>';
document.getElementById('id_right_'+id1).innerHTML='';

			}		

  	}


	
	

}


function save_cat(this_obj,id)
{
	operators_show_note(id);
	var of=document.getElementById('current_tab');
	var sel=document.getElementById("accounts_cats");
	var str=sel.options[sel.selectedIndex].text;

	var ac_id=sel.options[sel.selectedIndex].value;
	var ct_aid=document.getElementById('ct_aid').value;
	str=str.replace(/-/g,'');
	str=trim(str);
	of.innerHTML=str;
	of.id='';
	
	SendRequest('ajax.cgi','do=change_cat_account&ct_aid='+ct_aid+'&ac_id='+ac_id,'POST',NULL_FUNC);
}
function change_cat(this_obj,id,ac_id)
{
	var obj=document.getElementById('comment_form_change_cat');
	this_obj.id="current_tab";
	var th_par=this_obj.parentNode;
	if(th_par!=obj.parentNode)
	{
		obj.style.display='none';
	}
	
	th_par.appendChild(obj);
	document.getElementById("ct_aid").value=id;
	document.getElementById("accounts_cats").value=ac_id;
	operators_show_note('form_change_cat');

	
}
function next_day(id)
{
	this.id = id;
  	this.listener=function(){

    			var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				document.getElementById('id_left_'+id).innerHTML='перенесена';
				document.getElementById('form_'+id).style.display='none';

			}		

  	}
	

}
function ajax_action_req_next_day(id)
{
	var c = new next_day(id);
	SendRequest('ajax.cgi','do=send_req_next_day&id='+id,'POST',c.listener);
	
	
}
function cancel_pay_req(id)
{
	this.id = id;
  	this.listener=function(){

    			var ready=REQ.readyState;

			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				var s=document.getElementById('id_center_'+id);
				s.innerHTML='отменена';
				document.getElementById('form_'+id).style.display='none';
				var par=s.parentNode.parentNode.parentNode.parentNode.parentNode;
				par.className='table_gborders';
			}		

  	}
	

}
function ajax_action_req_cancel(id)
{
	var c = new cancel_pay_req(id);
	SendRequest('ajax.cgi','do=cancel_pay_req&id='+id,'POST',c.listener);
	
	
}
function confirm_pay_req(id)
{
	this.id = id;
  	this.listener=function(){

    		var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				var s=document.getElementById('id_center_'+id);
				s.innerHTML='перенесена';
				document.getElementById('form_'+id).style.display='none';
				var par=s.parentNode.parentNode.parentNode.parentNode.parentNode;
				par.className='table_gborders_confirm';
			}		

  	}
	

}
function ajax_action_req_confirm(id)
{
	var c = new confirm_pay_req(id);
	SendRequest('ajax.cgi','do=confirm_pay_req&id='+id,'POST',c.listener);
	
	
}
function ajax_action_req_delete_object(id1,id)
{

	var id1 = id1;
	var id2 = id;
  	this.listener=function(){
		
		ajax_action_req_delete(id1,id2);

  	}

}
function back_cells(id)
{

	this.id = id;

  	this.listener=function(){

    		var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{


			var id_=REQ.responseText					
			var tab = document.createElement('span');
			tab.setAttribute('class','simple_tab');
			tab.innerHTML='удалить';
			var del_obje=new ajax_action_req_delete_object(id_,id);
// 			addListener( "OnClick", openTooltipFunc );
			tab.onclick = del_obje.listener;
			document.getElementById('id_left_'+id).appendChild(tab);
/*
document.getElementById('id_left_'+id).innerHTML='<span class="simple_tab" onclick="ajax_action_req_delete(\''+ id_ +'\')" >пїЅпїЅпїЅпїЅпїЅпїЅпїЅ</span>';*/
document.getElementById('id_center_'+id).innerHTML='<a  class="table_gborders_href" href="?do=edit&amp;id='+ id_ +'">изменить</a>';
			
document.getElementById('id_right_'+id).innerHTML="<a  class='table_gborders' href='?do=re_iden&amp;id="+ id_ +"'>идентифицировать</a>";

			}		

  	}

}
function remove_nobr_comment(){

    

    $('table#my_table td nobr').each(function(){
   
	if($(this).attr('id')!='client_firm')
	{

		if($(this).attr('class'))
		    $(this).removeClass('comment');
		else 
		    $(this).addClass('comment'); 

	    }
	 }
	 );
	
    //$("nobr.comment_no").each(function(){                                                                                                                       
//        $(this).removeClass('comment_no');                                                                                                                      
//        $(this).addClass('comment');                                                                                                                      
//        });    




}


function exc_back(id1)
{

	var id = id1;
  	this.listener=function(){

    		var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				if(document.getElementById('center_id_'+id))
					document.getElementById('center_id_'+id).innerHTML='удален';
				if(document.getElementById('center_id_'+id+'simple'))
					document.getElementById('center_id_'+id+'simple').innerHTML='удален';

	
			}		

  	}

}

function ajax_action_exc_back(id)
{
	var c = new exc_back(id);
	SendRequest('ajax.cgi','do=ajax_exc_back&id='+id,'POST',c.listener);
}

function transit_del(id1,id2)
{

	this.id1 = id1;
	this.id2 = id2;
  	this.listener=function(){
	var ready=REQ.readyState;
	var data=null;
		if(ready==READY_STATE_COMPLETE)
		{
			document.getElementById('center_id_'+id1+'_'+id2).innerHTML='удален';
		}		

  	}

}


//ct_id1=$thing.ct_id1&amp;ct_id2=$thing.ct_id2
function ajax_action_transit_del(id1,id2)
{
	
	var c = new transit_del(id1,id2);
	SendRequest('ajax.cgi','do=del_transit&ct_id1='+id1+'&ct_id2='+id2,'POST',c.listener);

}
function firm_exc_del(id1)
{

	this.id1 = id1;

  	this.listener=function(){
	var ready=REQ.readyState;
	var data=null;
		if(ready==READY_STATE_COMPLETE)
		{
/*			alert(REQ.responseText)*/
			document.getElementById('center_id_'+id1).innerHTML='удален';
		}		

  	}

}

function ajax_action_firm_exc_del(id)
{

	var c = new firm_exc_del(id);
	SendRequest('ajax.cgi','do=del_conv&id='+id,'POST',c.listener);

}



function make_payments(this_obj,p_count_e,p_count_u,f_id,id,tlt)
{
	var obj=document.getElementById('comment_'+id);
	var par=obj.parentNode;
	var th_par=this_obj.parentNode;
	if(th_par!=par)
		obj.style.display='none';
	th_par.appendChild(obj);
	
	document.getElementById('pay_dialog_num_usd').value=p_count_u;
	document.getElementById('pay_dialog_num_eur').value=p_count_e;

	document.getElementById('pay_default_alert').innerHTML='';
	document.getElementById("pay_dialog_title").innerHTML=tlt;
	document.getElementById("pay_dialog_id").value=f_id;
  	var opts=document.getElementById("pay_dialog_currency").options;

	for (i=0;i<opts.length;i++)
    	{	
    		if(opts[i].text=='USD')
		{
			opts[i].value=p_count_u;
			continue;
		}
		if(opts[i].text=='EUR')
		{
			opts[i].value=p_count_e;
			continue;
		}	
	
    	}
	on_pay_change();
	operators_show_note(id);

}
function check_similar()
{
	var table=document.getElementById('my_table');
	var rows=table.rows;
	var processed=new Array();
	var inputs=new Array();
	var proced=new Array();
    var coms=new Array();
	var currencies=new Array();
	var h = new RegExp("пїЅпїЅпїЅ");
	var u = new RegExp("USD");
	var e =	new RegExp("EUR");

	var tmp;
	var tmp2;	
	var amnt;
	var amnt1;
	var amnt2;
	var inner_index=-1;
	var currency;
	var first;
	var second;	
    var comment;
    var firm_name;
        
	for(var i=6,z=0;i<rows.length;z++,i++)
	{
		processed.push(0);
        currencies.push('');
        coms.push('');
        proced.push(0);
        inputs.push(null);

        


		var amnt1=rows[i].cells[2].innerHTML;
		first=amnt1;
		amnt1=amnt1.replace(/[^0-9\.\-]/g,"");
		var amnt2=rows[i].cells[13].innerHTML;
		second=amnt2;
		amnt2=amnt2.replace(/[^0-9\.\-]/g,"");
		tmp=Math.abs(amnt1*1);
		tmp2=Math.abs(amnt2*1);
		if(!isNaN(tmp)&&tmp!=0)
		{
			
			currency=get_currency(h,u,e,first);
			amnt=amnt1;

		}else if(!isNaN(tmp2)&&tmp2!=0)
		{		
			currency=get_currency(h,u,e,second);
			amnt=amnt2;
		}else
		{
			continue;	
				
		}
        currencies[z]=currency;
        processed[z]=amnt;
        

        var cells=rows[i].cells[0].childNodes;
		tmp=0;
		for(var j=0;j<cells.length;j++){

			if(cells[j].nodeName=='INPUT'||cells[j].nodeName=='input')
			{
				 inputs[z]=cells[j]; 
                 if(inputs[z].checked)
                     proced[z]=1;

			}
		
		}
    
        cells=rows[i].cells[14].childNodes;
        
        for(var j=0;j<cells.length;j++)
        {
            if(cells[j].nodeName=='nobr'||cells[j].nodeName=='nobr')
            {
                comment=cells[j].innerHTML;
                comment=comment.toLowerCase();
                break;
                    
            }
        
        }
        cells=rows[i].cells[15].childNodes;
       
         coms[z]=comment;
       
        for(var j=0;j<cells.length;j++)
        {
            if(cells[j].nodeName=='span'||cells[j].nodeName=='span')
            {
                firm_name=cells[j].innerHTML;
                firm_name=comment.toLowerCase();
                firm_name=firm_name.replace(/\(#\d+\)/, "");
                break;
                    
            }
        
        }
    
        
		tmp=-1;
		if(proced[z]!=1)
		    tmp=search_in_processed(currencies,proced,processed,-1*amnt,currency,coms,firm_name);


		if(tmp>=0)
		{
			//alert(inputs.length+","+processed.length);
			inputs[tmp].checked=true;
			inputs[z].checked=true;
			proced[z]=1;
			proced[tmp]=1;
		}
			
		

	}
	alert('Найднные,похожие,несверенные  суммы отмечены');


}


function search_in_processed(currencies,proced,arr,variab,currency,coms,comment)
{
        var patt=new RegExp(comment);
		for(var j=0;j<arr.length;j++)
		{
            
			if(proced[j]==0&&currencies[j]==currency&&arr[j]==variab&&patt.test(coms[j]))
			{
				return j;			
			}
		
		}	
	return -1;
}
function  levDistance(s1,s2)
{
    var  lengthS1 = s1.length;
    var  lengthS2 = s2.length;
    var  tab = new Array(lengthS1 + 1)
    for(var dd=0;dd<=lengthS1;dd++)
    {
        tab[dd]= new Array(lengthS2 + 1);
    }

    var  i, j, diff;
    for( i = 0; i <= lengthS1; i++ )
        tab[i][0] = i;
    for( j = 0; j <= lengthS2; j++ )
        tab[0][j] = j;
    for( i = 1; i <= lengthS1; i++ )
    {
        for( j = 1; j <= lengthS2; j++ )
        {
            if ( s1.charAt( i - 1 ) == s2.charAt( j - 1 ) )
                diff = 0;
            else
                diff = 1;
            tab[i][j] = Math.min( Math.min(tab[i-1][j] + 1,       // insertion
                                 tab[i][j-1] + 1),      // deletion
                                 tab[i-1][j-1] + diff); // substitution
        }
    }

    return tab[lengthS1][lengthS2];
}



function get_currency(h,u,e,vars)
{
    if(h.test(vars))
        return 'UAH';
    if(u.test(vars))
        return 'USD';
    if(e.test(vars))
        return 'EUR';

    
}   
function show_form(id)
{
	var obj=document.getElementById(id);
        if(!obj)
            return;
   
	if(obj.style.display=='none')
	{
         $('#'+id).show('slow');
       
	}else	
	{
          $('#'+id).hide('slow');
	}
}


function show_cron_form(id,c_id,field,ob)
{
	var obj=document.getElementById(id);
        if(!obj)
            return;
	//
	var obj1=document.getElementById('change_c_id');
	var obj2=document.getElementById('change_field');
    $('#change_c_id').attr({'value':c_id});
    $('#change_field').attr({'value':field});
    $('#val').attr({'value':$.trim(ob.innerHTML)});
	
	
	
	if(obj.style.display=='none')
	{
         $('#'+id).show('slow');
       
	}else	
	{
          $('#'+id).hide('slow');
	}
}

function   submit_form_day(runmode){

    $('#day_runmode').attr({'value':runmode});
    return true;


}
function show_account_graph(id,objq){
        
        $('#search_account').attr({ 'value': id });
        var date=new Date();


        year=date.getFullYear();
        month=date.getMonth()+1;

        document.getElementById('account_month').value=month;
        document.getElementById('account_year').value=year;

        $('#account_image').attr({'src': 'reports.cgi?do=get_accounts_income&a_id='+id+'&month='+month+'&year='+year });
        $('#account_image').show('slow');

        show_form_ext(objq,'graph_div');

}
function show_account_income(){
        var aid=$('#search_account').attr('value');
        var month=$('#account_month').attr('value');
        var year=$('#account_year').attr('value');
        $('#account_image').attr({'src': 'reports.cgi?do=get_accounts_income&a_id='+aid+'&month='+month+'&year='+year });
        $('#account_image').hide('slow');
        setTimeout("$('#account_image').show('slow');",3000);
        


}

function show_form_ext(objq,id){


    var obj=document.getElementById(id);
        if(!obj)
            return;
    var scroll=getScrollXY();    
    obj.style.position='absolute';
    obj.style.top=objq.clientY+scroll[1];
    obj.style.left=objq.clientX+scroll[0]+10;
    if((objq.clientX+scroll[0]+680)>NORMAL_WIDTH){
        obj.style.left=NORMAL_WIDTH-750;
    }
   
    if(obj.style.display=='none')
    {
	obj.style.display='';     
    //$('#'+id).show('slow');
       
    }else   
    {
	obj.style.display='none';
          //$('#'+id).hide('slow');
    }
}

function del_transfer(id1)
{

	var id = id1;

  	this.listener=function(){

    			var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{	
				if(document.getElementById('center_id_'+id))
					document.getElementById('center_id_'+id).innerHTML='удален';
				if(document.getElementById('center_id_'+id+'transaction'))
					document.getElementById('center_id_'+id+'transaction').innerHTML='удален';
			}

  	}

}
function do_pay(this_obj1,p_count_e1,p_count_u1,f_id1,id_1,tlt1)
{

	var this_obj=this_obj1;
	var p_count_u=p_count_u1;
	var p_count_e=p_count_e1;
	var f_id=f_id1;
	var id_=id_1;
	var tlt=tlt1;
	//
  	this.act=function()
	{
	//alert(this_obj+','+p_count_e+','+this.p_count_u+','+this.f_id+','+this.id_+','+this.tlt);
		make_payments(this_obj,p_count_e,p_count_u,f_id,id_,tlt);
  	}

}
function on_pay_change()
{

	var number=document.getElementById('pay_dialog_currency').value;
	var amnt=document.getElementById('pay_default_sum').value;
	var alr=document.getElementById('pay_default_alert');
	alr.innerHTML='';
	if(number==0)
		alr.innerHTML='по данной валюте платежи уже проставлены<br/>';
	document.getElementById('pay_dialog_amnt').value=amnt*number;
}

function do_payments(this_obj,id)
{

	document.getElementById('pay_default_alert').innerHTML='';
	date=get_normal_date('date');
      
	
	var sel=document.getElementById('pay_dialog_currency');

	
	var currency=sel.options[document.getElementById('pay_dialog_currency').selectedIndex].text;
	
	var f_id=document.getElementById("pay_dialog_id").value;
	
	var amnt=document.getElementById("pay_dialog_amnt").value;

	operators_show_note(id);
	
	var s=this_obj.parentNode;
	s=s.parentNode;
	cells=s.childNodes;
	var old_span;
	for(var i=0;i<cells.length;i++)
	{	
		if(cells[i].nodeName=='SPAN'||cells[i].nodeName=='span')	
		{
			old_span=cells[i];
		}
		
	}
	
	
	var opts=sel.options;
	var p_usd;
	var p_eur;
	p_usd=0;
	p_eur=0;
	for(var i=0;i<opts.length;i++)
	{
		
		if(opts[i].text=='USD')
		{
			p_usd=opts[i].value;
	
		}else 	if(opts[i].text=='EUR')
		{
			p_eur=opts[i].value;

		}

	}
	amnt.replace(/,/,'.');
	if(amnt<0)
	{
	
		alert('Сумма не соответсвует формату');
		return ;
	}

	if((currency=='USD'&&p_usd==0)||(currency=='EUR'&&p_eur==0))
	{
		alert('Все платежи проставлены!');
		var tab = document.createElement('span');
		tab.setAttribute('class','simple_tab');
		tab.innerHTML='Все платежи проставлены';
		s.appendChild(tab);
		s.removeChild(old_span);
		return 	
		
	}
		if(currency=='USD')
		{
			p_usd=0;
		}
		if(currency=='EUR')
		{
			p_eur=0;
		}
		

			if(p_eur==0&&p_usd==0)
			{
				var tab = document.createElement('span');
				tab.setAttribute('class','simple_tab');
				tab.innerHTML='Платежи проставлены';
				s.appendChild(tab);
				s.removeChild(old_span);
		
	
			}else
			{	
				var tab = document.createElement('span');
				tab.setAttribute('class','simple_tab');
				tab.innerHTML='Проставить платежи';
				var id_="dialog_payment";
				
				var my_obj=new
				do_pay(tab,p_eur,p_usd,f_id,id_,document.getElementById("pay_dialog_title").innerHTML);
				tab.onclick = my_obj.act;
			//do_pay.listener();
				s.appendChild(tab);
				s.removeChild(old_span);
				
			}
			var num_pmts=document.getElementById('pay_dialog_num_usd').value;
			
			SendRequest('ajax.cgi','do=make_payments&id='+f_id+'&date='+date+'&currency='+currency+'&amnt='+amnt+'&pay_dialog_num_usd='+num_pmts,'POST',list_pays);
			//
	
	
		
}
function list_pays()
{
			var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				//alert(REQ.responseText);
				alert('Платеж(и) проставлен(ы)');
			}	

}

function  show_notes(e)
{
	document.getElementById('comment_none').style.display='block';
	document.getElementById('comment_none').style.left=e.x+8;
	document.getElementById('comment_none').style.top=e.y+8;
}
function hide_notes()
{
	document.getElementById('your_show_notes').display='none';

}
function operators_show_note(id)
{

	if(document.getElementById('comment_'+id).style.display == 'none')
	{
		document.getElementById('comment_'+id).style.display='block';
	}else
	{
		document.getElementById('comment_'+id).style.display='none';
	}
}

function operators_show_note_ext(id)
{

	if(document.getElementById(id).style.display == 'none')
	{
		document.getElementById(id).style.display='block';
	}else
	{
		document.getElementById(id).style.display='none';
	}
}



function drop_payments(f_id)
{
	
	var day=document.getElementById('date_Day_ID').value;
	var month=document.getElementById('date_Month_ID').value;
	var year=document.getElementById('date_Year_ID').value;

	if(month<9)	
		 month='0'+month;

	if(day<9)	
		 day='0'+day;

	date=year+'-'+month+'-'+day;	

	

	//SendRequest('ajax.cgi','do=drop_payments&id='+f_id+'&date='+date,'POST',drop_payments_);

}
function ajax_action_transfer_del_by_transaction(id)
{
	var c = new del_transfer(id);
	SendRequest('ajax.cgi','do=delete_transfer_by_transaction&id='+id,'POST',c.listener);

}

function ajax_action_transfer_del(id)
{

	var c = new del_transfer(id);
	SendRequest('ajax.cgi','do=delete_transfer&id='+id,'POST',c.listener);


}
function  ajax_action_req_delete(id,id1)
{
    if(!id1)
	id1=id;
	var c = new del_cells(id,id1);
	SendRequest('ajax.cgi','do=delete_firm_req&id='+id,'POST',c.listener);


}	
function ajax_action_req_back(id)
{
	var c = new back_cells(id);
	SendRequest('ajax.cgi','do=back_firm_req&id='+id,'POST',c.listener);


}

function back_cells_from(id1)
{

	var id = id1;

  	this.listener=function(){

    		var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				document.getElementById('center_id_'+id+'input').innerHTML='Удалено';
			}		

  	}

}

function ajax_action_req_back_from(id)
{
	var c = new back_cells_from(id);
	SendRequest('ajax.cgi','do=back_firm_req&id='+id,'POST',c.listener);


}


