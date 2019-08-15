function removeHTMLTags(str){
 
        var strInputCode = str;
   
        strInputCode = strInputCode.replace(/&(lt|gt);/g, function (strMatch, p1){
            return (p1 == "lt")? "<" : ">";
        });
    
        var strTagStrippedText = strInputCode.replace(/<\/?[^>]+(>|$)/g, "");
        return strTagStrippedText;

   
}
function show_traffic_of_this(event,drid,dr_fid,dr_aid,dr_date)
{
        var ob=document.getElementById(drid+'_traff');
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
            new_obj.innerHTML='<strong>��������� ����� ;) </strong>';
            new_obj.setAttribute('id',drid+'_traff');
            new_obj.style.position='fixed';//'absolute';
            var xy=getScrollXY();
	    
	    new_obj.style.left=event.clientX+100;//+xy[0]+10;
            //alert(event.y);
            new_obj.style.top=event.clientY-200;//+xy[1]+10;
            
            new_obj.style.display='';

            var l=document.getElementById('my_table')

            l.appendChild(new_obj);

            var str="do=get_money_traffic_list&dr_id="+drid+'&dr_fid='+dr_fid+'&dr_aid='+dr_aid+'&dr_date='+dr_date;

            var      REQ=getHttp();
            var ob_=new show_traffic_of_this_event(drid,REQ);

            SendRequest2(REQ,'ajax.cgi?'+str,'','GET',ob_.listener);
                
        
        
        
    }
    


}
function show_traffic_of_this_event(drid,req){
    var id=drid;  
    var REQ=req;
    this.listener=function(){

            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
/*                alert(REQ.responseText);*/
                var s=document.getElementById(id+'_traff');
                s.innerHTML=REQ.responseText;
            }       

    }

}


function show_deal_docs_event(drid)
{
    var id=drid;  

    this.listener=function(){

            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
                var s=document.getElementById(id+'_docs');
                s.innerHTML=REQ.responseText;
            }       

    }
}
function hide_form(id)
{
    $('#'+id).hide('slow');

}
function ajax_show_deals_doc(event,parent_obj,id)
{
    var ob=document.getElementById(id+'_docs');
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
            new_obj.innerHTML='<strong>��������� ����� ;) </strong>';
            new_obj.setAttribute('id',id+'_docs');
            new_obj.style.position='absolute';
            var xy=getScrollXY();
            new_obj.style.left=0;
            //alert(event.y);
            new_obj.style.top=event.clientY+50;
            
            new_obj.style.display='';

            var l=document.getElementById('my_table')

            l.appendChild(new_obj);

            var str="do=ajax_deal_docs&id="+id;

            var ob_=new show_deal_docs_event(id);

            SendRequest('ajax.cgi?'+str,'','GET',ob_.listener);
                
        
        
        
    }
    
    
}   
function unify_get_excel(index_cols,index_rows,index_cols_end)
{
    var obj=document.getElementById('my_table');
    var rows=obj.rows;
        
    var cels=rows[index_rows].cells;
    var str,tmp;
    str='';
    document.getElementById('file_id_url').style.display='';
    document.getElementById('file_id_url').innerHTML='�����...�����';

/*            alert(cels.length+' '+rows.length);*/
            for(var j=index_cols;j<index_cols_end;j++)
            {
                       if(!cels[j])
                            break; 
             
                        
                        
                        
                        tmp=cels[j].innerHTML;

                        tmp=tmp.replace(/&amp;/g,"");
                        tmp=tmp.replace(/&lt;/g,"<");
                        tmp=tmp.replace(/&gt;/g,">");
                        tmp=tmp.replace(/&quot;/g,"\"");
                        tmp=tmp.replace(/&apos;/g,"'");
                        tmp=tmp.replace(/&nbsp;/g," ");
                        tmp=tmp.replace(/&/g,'');
                        tmp=tmp.replace(/[;!\|]/g,'');
                        tmp=removeHTMLTags(tmp);
                        str+=tmp+"!";
            }
            str+="|";
        
            for(var i=index_rows+1;i<rows.length;i++)
            {
                cels=rows[i].cells;
                
                for(var j=index_cols;j<index_cols_end;j++)
                {
                        if(!cels[j])
                            break; 
             
                        
                        
                        
                        tmp=cels[j].innerHTML;

                        tmp=tmp.replace(/&amp;/g,"");
                        tmp=tmp.replace(/&lt;/g,"<");
                        tmp=tmp.replace(/&gt;/g,">");
                        tmp=tmp.replace(/&quot;/g,"\"");
                        tmp=tmp.replace(/&apos;/g,"'");
                        tmp=tmp.replace(/&nbsp;/g," ");
                        tmp=tmp.replace(/&/g,'');
                        tmp=tmp.replace(/[;!\|]/g,'');
                        tmp=removeHTMLTags(tmp);
                        str+=tmp+"!";
                
                }
                 
                str+="|";
              }
             
            //get_url
//     $.ajax({
//         url: 'ajax.cgi',             // ��������� URL �
//         dataType : "json",                     // ��� ����������� ������
//         success: function (data, textStatus) { // ������ ���� ���������� �� ������� success
//             document.write(data);      
// 
//         }
//     });
//           get_url
           SendRequest('ajax.cgi','do=export_excel&data='+str,'POST',get_url);
}
    function get_url()
    {
            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
                
                //very important thing there 
                var url=REQ.responseText;
                var obj=document.getElementById('file_id_url');
                obj.href=location.protocol+'//'+location.hostname+'/'+url;
                obj.innerHTML='����...���������';

            }

    }



function ajax_doc_del_deal(id)
{
	var str="do=ajax_del_deal&id="+id;
  	var r=confirm("�� ������������� ������ ������� ��� ������ �� ����  ������? ");
	var obj=document.getElementById(id);
	var table=document.getElementById('my_table');
	if(r==true)
    	{
		table.deleteRow(obj.rowIndex);
		$('#form_'+id).hide('slow');
		SendRequest('ajax.cgi',str,'POST',NULL_FUNC);

 
	}

}

function show_doc_tab_event(drid)
{
    var id=drid;  

    this.listener=function(){

            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
                var s=document.getElementById(id+'_tab');
                s.innerHTML=REQ.responseText;
            }       

    }
}

function show_doc_tab(par,drid)
{
       var obj=document.getElementById(drid+'_tab');
     if(obj)
     {
        
        if(obj.style.display=='none')
        {
               par.innerHTML='�������' 
               obj.style.display='';
        }    
        else
        {
              par.innerHTML='��������';  
              obj.style.display='none';
        }

     }else
     {
            var new_obj=document.createElement('div');
        
            new_obj.setAttribute('class','center_div_table_poup');
            new_obj.innerHTML='<strong>��������� ����� ;) </strong>';
            new_obj.setAttribute('id',drid+'_tab');
            new_obj.style.position='absolute';
            new_obj.style.display='';
            var but=document.getElementById('button_'+drid);
            var s=but.parentNode;
            s.appendChild(new_obj);
            but.innerHTML='�������';

            var str="do=ajax_deal_info&id="+drid;
            var ob=new show_doc_tab_event(drid);
            
            SendRequest('ajax.cgi?'+str,'','GET',ob.listener);
            
            
            

     }
    
        
     


}


function save_account_docs(this_obj,id)
{
	operators_show_note(id);

	var of=document.getElementById('current_tab');

	var sel=document.getElementById("accounts");
	var str=sel.options[sel.selectedIndex].text;
	var a_id=sel.options[sel.selectedIndex].value;
	of.innerHTML=str;	
	var dr_id=document.getElementById("dr_id").value;
		document.getElementById("dr_id").value='';
	of.id='';
	SendRequest('ajax.cgi?do=document_change_account_doc&ct_aid='+a_id+'&dr_id='+dr_id,'','GET',NULL_FUNC);
}

function change_account_docs(this_obj,id,aid)
{
	var obj=document.getElementById('comment_form_change_cat');

	document.getElementById("dr_id").value=id;
	document.getElementById("accounts").value=aid;

	this_obj.id="current_tab";


	var th_par=this_obj.parentNode;

	if(th_par!=obj.parentNode)
	{
		obj.style.display='none';
	}
	
	th_par.appendChild(obj);
	operators_show_note('form_change_cat');

	
}

function checkAll()
{
	
 	var x=document.getElementsByTagName("input");
	
	var z=0;
	  for(var i=0;i<x.length;i++)
  	  {
		if(x[i].type=='checkbox')
		{
			
			if(!z)
			{
				z++;
				continue;
			}


			x[i].checked=!x[i].checked;
			
		}

  	 }
}
function save_account(this_obj,id)
{
	operators_show_note(id);

	var of=document.getElementById('current_tab');

	var sel=document.getElementById("accounts");
	var str=sel.options[sel.selectedIndex].text;
	var a_id=sel.options[sel.selectedIndex].value;
	of.innerHTML=str;
	var dt_id=document.getElementById("dt_id").value;
	document.getElementById("dt_id").value='';
	of.id='';
	SendRequest('ajax.cgi?do=document_change_account&ct_aid='+a_id+'&dt_id='+dt_id,'','GET',NULL_FUNC);
}

function change_account(this_obj,id,aid)
{
	var obj=document.getElementById('comment_form_change_cat');

	document.getElementById("dt_id").value=id;
	document.getElementById("accounts").value=aid;

	this_obj.id="current_tab";


	var th_par=this_obj.parentNode;

	if(th_par!=obj.parentNode)
	{
		obj.style.display='none';
	}
	
	th_par.appendChild(obj);
	operators_show_note('form_change_cat');

	
}
function search_in_select_field_tupoi(obj,event,id)
{

    var sel=document.getElementById(id);
    var from=0;
    var to;
    var first=1;

    var opts=sel.options;
    to=opts.length;
    var tmp;


    var str=obj.value;
    str=str.toLowerCase();
   
    
        if(event.keyCode==40)
        {

            var i=sel.selectedIndex;
            from=++i;
    
        }else if(event.keyCode==38) {
            var i=sel.selectedIndex;
            to=--i;
            first=0;


        }

    
    var patt=new RegExp('^'+str);
    var fin=1;
    sel.selectedIndex=1;
    for(var i=from;i<to;i++)
    {
        tmp=opts[i].text;
        tmp=tmp.toLowerCase();
        if(patt.test(tmp)==true)
        {
            fin=0;
            sel.selectedIndex=i;
            if(first)
                return ;
            
        }
    }

    if(fin)
        sel.selectedIndex=1;

//     if(str.length<3)
//     {
//         
//         sel.selectedIndex=1;
//         return ;
// 
//     }
// 
// 
// 
//     var patt=new RegExp(str);
//     var fin=1;
//     sel.selectedIndex=1;
//     for(var i=0;i<opts.length;i++)
//     {
//         tmp=opts[i].text;
//         tmp=tmp.toLowerCase();
//         if(patt.test(tmp)==true)
//         {
//             fin=0;
//             sel.selectedIndex=i;
//             return ;
//             
//         }
//     }
//     if(fin)
//         sel.selectedIndex=1;


}

function search_in_select_field(obj,id)
{

	var sel=document.getElementById(id);

	var opts=sel.options;
	var tmp;


	var str=obj.value;
	str=str.toLowerCase();
	if(str.length<3)
	{
		return ;

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
function ajax_doc_del_trans(id)
{

	var str="do=ajax_del_doc_trans&id="+id;
	
  	var r=confirm("�� ������������� ������ ������� ��������? ");
	var obj=document.getElementById(id);
	var table=obj.parentNode;
	if(r==true){
	
		SendRequest('ajax.cgi?'+str,'','GET',NULL_FUNC);
		table.deleteRow(obj.rowIndex);   

	 
	}

}
function NULL_FUNC()                                                                                                                                         
{                                                                                                                                                            
                                                                                                                                                             
}   

function ajax_del_payment(obj,id)
{
	var str="do=delete_document_payment&id="+id;
  	var r=confirm("�� ������������� ������ ������� ��� ������? ");
	if(r==true)
    	{
		var par=obj.parentNode;
		create_my_element(par,'simple_tab','������ �������',null);
		par.removeChild(obj);
		SendRequest('ajax.cgi',str,'POST',NULL_FUNC);
		
 
	}

}

function DEBUG_FUNC()
{
        var ready=REQ.readyState;
		var data=null;
		if(ready==READY_STATE_COMPLETE)
		{
				//first firm_id,second new id
			document.write(REQ.responseText);
			
			//alert(id_);
			

		}		
}
function ajax_doc_reopen_deal(id)
{
        

    var str="do=ajax_reopen_doc&param="+id;
    var r=confirm("�� ������������� ������ ������� ������ ��� ������? ");
    var obj=document.getElementById(id);
    var table=document.getElementById('my_table');
    if(r==true)
        {
        $('#form_'+id).hide('slow');
        SendRequest('ajax.cgi?'+str,'','GET',NULL_FUNC);

     
    }
    
    

}

function ajax_doc_close_deal(id)
{
		

	var str="do=ajax_close_deal&param="+id;
  	var r=confirm("�� ������������� ������ ������� ������? ");
	var obj=document.getElementById(id);
	var table=document.getElementById('my_table');
	if(r==true)
    	{
		table.deleteRow(obj.rowIndex);
		$('#form_'+id).hide('slow');
		SendRequest('ajax.cgi',str,'POST',NULL_FUNC);

	 
	}
	
	

}
function doc_parent_my_submit_form()
{

	var key_field=document.getElementById('key_field').value;
	var amnt=document.getElementById('amnt').value;

	parent.document.getElementById('buffer_amnt').value=amnt;

	parent.document.getElementById('buffer_id').value=key_field;

	var cb=parent.document.getElementById('return_function');

	var evt = parent.document.createEvent("MouseEvents");
	evt.initMouseEvent("click", 
	true, true, 
	window,
	0, 
	0, 
	0,
	0,
	0, false, false, false, false, 0, null);

  	var canceled = !cb.dispatchEvent(evt);	
	

}
function ajax_doc_get_payment(id)
{
	
	var str="/cgi-bin/lite/inputdoc.cgi?do=list&parent_id=ident_form&param="+id;
	$('#ident_form_frame').attr({src : str });
	$('#ident_form').hide('slow').show('slow');
	$('#form_'+id).hide('slow');
	var object_=new my_submit_object2('ident_form');


	var ret =document.getElementById('return_function');
	addListener(ret,'click',object_.listener,false);
	return;

}
function my_submit_object2(id2)
{
	
	var indent_form=id2;

	this.listener=function()
	{
		$("#"+indent_form).hide('slow');	
		var sum=$("#buffer_amnt").attr("value");
		var id=$("#buffer_id").attr("value");
		var obj=document.getElementById(id);
		var whole_sum=get_sum_from_html(obj.cells[5]);
		var sum_comis=get_sum_from_html(obj.cells[7]);

		var sum_comis_payed=get_sum_from_html(obj.cells[8]);
		sum_comis_payed=to_prec2(1*sum_comis_payed+1*sum);
		obj.cells[8].innerHTML=sum_comis_payed;
		obj.cells[9].innerHTML=to_prec2(whole_sum*(sum_comis_payed/sum_comis));
		
	}


}
function to_prec2(number)
{
	return Math.floor(number*100)/100;


}

function my_back_doc()
{
		var par_form;
		
		if(par_form=document.getElementById('parent_id').value)
		{
			parent.document.getElementById(par_form).style.display='none';
		}

}