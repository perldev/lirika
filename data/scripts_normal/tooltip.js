    var concl_array=new Array();
        var concl_array_whole=new Array();

        var concl_type=new Array();
        var services_percents=new Array();
        var start_;
        var redirect=0;
        function getReq()
        {
            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
                //very important thing there 
                var old_comment=REQ.responseText;
                if(redirect)
                {
                    window.location.href='?';
                }
            
                
            }
        
        }

function event_handle(_form_id,_obj,_id,_typ_e){

        var obj=_obj;
        var id=_id;
        var typ_e=_typ_e;
        var form_id=_form_id;
        this.handle=function(){
            
	    
	       $('#date_form_button').unbind('click'); 
                var val=$('#new_date').attr('value');
                SendRequest('ajax.cgi','do=change_ts_accounts_report&ts='+val+'&type='+typ_e+'&ct_id='+id,'POST',NULL_FUNC);
	              vals=val.split("-");
	             _obj.innerHTML=vals[2]+'.'+vals[1]+'.'+vals[0];
	             show_form(form_id);
	            return true;
	       }


}


function show_archives(id,ev){


    
    if(!is_id_defined('archive_list')){
          $('#my_table').append("<div class='center_div_table_poup' id='archive_list'></div>");
            $.post('ajax.cgi','do=get_last_archive_record&a_id='+id,function (dat){ 
            $('#archive_list').html(dat);

               $('#archive_list').css({'display':'','position': 'absolute','left': ev.clientX,'top':ev.clientY});        
    
            } ,'html');
    
    }else{
           show_form('archive_list');

    }





}
        

function show_form_date(obj,ev,form_id,id,typ_e){
    
    var handle=new event_handle(form_id,obj,id,typ_e);
    var form_id1='#'+form_id;
    var xy=getScrollXY();
    var _x=ev.clientX+xy[0];
    var _y = ev.clientY+xy[1];
    $(form_id1).css({ 'position' : 'absolute' ,'top' : _y  ,'left': _x });
    show_form(form_id);
    
    $('#date_form_button').bind('click',handle.handle); 
    

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
                obj.innerHTML='Файл...Сохранить';

            }

}


function get_excel(a_id)
{
    document.getElementById('file_id_url').style.display='';
    document.getElementById('file_id_url').innerHTML='Думаю...Ждите';
    SendRequest('accounts_reports.cgi','do=export_excel&ct_date=all_time&action=filter&ct_aid='+a_id,'POST',get_url);


}



function hide_alert_div()
{    var ready=REQ.readyState;
        if(ready==READY_STATE_COMPLETE){
                var alert_div=document.getElementById('alert_div');
                alert_div.style.display='none';
//		alert(REQ.responseText);    
                
        }
}
function send_mail(ev){

    
    var ct_aid=document.getElementById('ct_aid').value;
    var email=document.getElementById('own_email').value;
    document.getElementById('email_form').style.display='none';
    document.getElementById('alert_div').style.display=''; 
    SendRequest('ajax.cgi','ct_aid='+ct_aid+'&do=send_through_localhost&action=filter&ct_date=all_time&email='+email,'POST',hide_alert_div);

}
function show_account_info(ev,a_id){
    
    if(is_id_defined('account_info'))
    {
        show_form('account_info');
    
    }else{       

                var new_obj=document.createElement('div');
                new_obj.setAttribute('class','center_div_table_poup_no_limit');
                new_obj.innerHTML='Подождите...думаю';
                new_obj.setAttribute('id','account_info');
                new_obj.style.position='absolute';
                var xy=getScrollXY();
                new_obj.style.left=ev.clientX;
                //alert(event.y);
                new_obj.style.top=ev.clientY*1+1*xy[1];
                
                new_obj.style.display='';
    
                var l=document.getElementById('my_table')
    
                l.appendChild(new_obj);
            
                SendRequest('ajax.cgi','do=ajax_account_info&a_id='+a_id,'POST',getting_info);
    }

    
}
function getting_info()
{
        var ready=REQ.readyState;
        if(ready==READY_STATE_COMPLETE){
               new_obj=document.getElementById('account_info');
               new_obj.innerHTML=REQ.responseText;

//      alert(REQ.responseText);    
                
        }


}



function uncheck_row(number)
{

    this.number = number;
    this.listener=function(){
    var ready=REQ.readyState;
        if(ready==READY_STATE_COMPLETE)
        {
            var old_comment=REQ.responseText;
            var my_table=document.getElementById('my_table');
            var rows=my_table.rows;
            rows[number].cells[14].innerHTML=old_comment;
          

        }       

    }

}
//ct_id1=$thing.ct_id1&amp;ct_id2=$thing.ct_id2
function delete_from_array(arr,number)
{
             var size=arr.length-1;
            for(var i=number;i<size;i++)
            {
                arr[i]=arr[i+1];
            }
            

}


function uncheck(type_,id)
{
    var size=concl_array.length;
    
    for(var i=0;i<size;i++)
    {
    
        if(concl_array[i]==id&&concl_type[i]==type_)
        {
            concl_array[i]=concl_array[size-1];
            concl_type[i]=concl_type[size-1];
            concl_array_whole[i]=concl_array_whole[size-1];
            concl_array.pop();
            concl_type.pop();
            concl_array_whole.pop();
            return;
        }
        
    }
    

    var my_table=document.getElementById('my_table');
    var rows=my_table.rows;
    var str=type_+id;
    for(var i=0;i<rows.length;i++)
    {   
        if((rows[i].cells[0].childNodes[1]&&(rows[i].cells[0].childNodes[1].id==str))||(rows[i].cells[0].childNodes[0]&&(rows[i].cells[0].childNodes[0].id==str)))
        {
            number=i;
        }
                    
    
                    
    }
    var obj=new uncheck_row(number);
    var ct_aid=document.getElementById('ct_aid').value;

    var j=binary_search(hidden_arries,number);
    delete_from_array(hidden_arries,j);

    SendRequest('ajax.cgi','ct_aid='+ct_aid+'&do=set_col_no&id='+id+'&type='+type_,'POST',obj.listener);


}
function set_check_day(dat){
      var elems=document.getElementsByName(dat);
      size=elems.length;
   
      for(var i=0;i<size;i++){  
            if(!elems[i].id)
                continue;
            if(elems[i].checked){
                var str=elems[i].id;
                
                var patt1=/\d+/;
                var num=str.match(patt1);
                var patt11=/[^\d]+/;
                var type_=str.match(patt11);

                uncheck(type_,num);

                elems[i].checked=false;

            }else{
                 var str=elems[i].id;
                 
                 var patt1=/\d+/;
                 var num=str.match(patt1);
                 var patt11=/[^\d]+/;
                 var type_=str.match(patt11);

                 check(type_,num);
                 elems[i].checked=true;
            }
    
    
      }


}

function change_status_col_all(dom,a_id)
{
    if(dom.checked)
    {
        if(confirm("Вы уверенны,что хотите отметить как сверенные все записи"))
        {
            redirect=1;
            SendRequest('ajax.cgi','do=set_col_all&col_status=yes&a_id='+a_id,'POST',getReq);
            
        }else
        {
            alert('Ну и ладненько');
            dom.checked=false;
        }

    }else
    {
        if(confirm("Вы уверенны,что хотите отметить как несверенные все записи"))
        {
            redirect=1;
            SendRequest('ajax.cgi','do=set_col_all&col_status=no&a_id='+a_id,'POST',getReq);
        }else
        {
            alert('Ну и ладненько');
            dom.checked=true;
        }
    }


}
function binary_search(arr,str)
{
   var size=arr.length;
   var index=Math.floor(size/2);
   var left=0;
   var right=0;
   var i=0;
    if (arr[0]==str)
        return 0;

    for(;arr[index]!=str;){
      //document.write(index+","+arr[index]);
      //document.write("<br/>");
       i++;
       if(arr[index]>str)
       {
         right=size-index; 
         index=index-Math.floor((size-right-left)/2);
                 
       }else{
          
         left=index; 
         index=index+Math.floor((size-right-left)/2);

       }
    }
    return index;
}

function change_status_col(dom,type_,id)
{
    if(dom.checked)
    {
        //document.getElementById(type_+id).style.background='#00FF4B';
        check(type_,id);
        


    }else
    {
        //document.getElementById(type_+id).style.background='#A3DEB5';
        
        uncheck(type_,id);
    }
}
var hidden_arries=new Array();

function find_in_array(v)
{
    var size=concl_array_whole.length;
    for(var i=0;i<size;i++)
    {
        if(concl_array_whole[i]==v)
        {
            return 1;
        }
    }
    return -1;

}
function check(type_,id)
{

    concl_array.push(id);
    concl_type.push(type_);
    concl_array_whole.push(type_+id);
}

function set_concl_(ev)
{
    document.getElementById('group_form').style.display='none';
    set_concl(ev);
}


function set_concl(ev)
{

    var str_id=new String('');
    var size=concl_array.length;
    var comment=document.getElementById('col_comment').value;
    for(var i=0;i<size;i++)
    {
        str_id+='id'+i+'='+concl_array[i]+'&';
        str_id+='type'+i+'='+concl_type[i]+'&';
    }
    
//deleting everything in array
    for(var i=0;i<size;i++)
    {
        concl_array.shift();
        concl_type.shift();
    }
    

    var ct_aid=document.getElementById('ct_aid').value;

    var alert_div=document.getElementById('alert_div');
    show_alert(alert_div,ev.x,ev.y);
    
    comment=encodeURIComponent(comment);
    
    SendRequest('ajax.cgi','do=set_col&comment='+comment+'&col_status=yes&'+str_id+'&size='+size+'&ct_aid='+ct_aid,'POST',getReq_check);

}
function show_alert(alert_div,x_,y_)
{
    alert_div.style.display='block';
    alert_div.style.top=y_;
    alert_div.style.left=x_;
}

function getReq_check()
{
            var ready=REQ.readyState;
            var data=null;
            if(ready==READY_STATE_COMPLETE)
            {
                //very important thing there 
                
                var color=REQ.responseText;
                var my_table=document.getElementById('my_table');
                var rows=my_table.rows;
                var comment=document.getElementById('col_comment').value;
                document.getElementById('col_comment').value='';
                var inp=0;
                for(var i=0;i<rows.length;i++)
                {   
                    inp=0;
if((rows[i].cells[0].childNodes[1]&&(rows[i].cells[0].childNodes[1].checked)&&(inp=find_in_array(rows[i].cells[0].childNodes[1].id)))||(rows[i].cells[0].childNodes[0]&&(rows[i].cells[0].childNodes[0].checked)&&(inp=find_in_array(rows[i].cells[0].childNodes[0].id))))
                    {
                            
                            rows[i].style.display='none';
                            if(inp>0&&color)
                            {
                                rows[i].cells[14].innerHTML=color;
                                hidden_arries.push(i);

                            }else if(inp>0)
                            {
                                hidden_arries.push(i);

                            }
                    }
                    
    
                    
                }

                hidden_arries.sort(sortNumber);

                var alert_div=document.getElementById('alert_div');

                alert_div.style.display='none';


                var size=concl_array_whole.length;
                for(var i=0;i<size;i++)
                {
                            concl_array_whole.shift();
                }

                
                var o=document.getElementById('hid_unhide_button');
                o.name=0;
                show_verified(o);
    
                

        
            }


}
function show_grouped(i){
    
    var tbl=document.getElementById('my_table');
    var rows=tbl.rows;
    var nm=find_first_object(rows[i],'input');

    var elems=document.getElementsByName(nm.name);
        
    for(var j=(i+1),v=1;rows[j].cells[0].id;j++,v++){
        
            if(elems[v].checked){
                if( rows[j].style.display=='')
                    rows[j].style.display='none';
                else    
                    rows[j].style.display='';
            
            }


    }
    


}
function find_first_object(obj,tag_name){
        
   tag_name=String.toLowerCase(tag_name);
    var arr=obj.childNodes;
    var size=arr.length;
    for(var j=0;j<size;j++){
        d=arr[j];
        if(String.toLowerCase(d.nodeName)==tag_name)
           return d;
        else {
            d=find_first_object(d,tag_name);
            if(d)
                return d;
        }
    
    }    
        
    return ;

    
}
function sortNumber(a,b)
{
return a - b;
}
function get_client_oper_info()
{
    var from=get_normal_date('ct_date_from');
    var to=get_normal_date('ct_date_to');
    var ct_aid=document.getElementById('ct_aid').value;
    SendRequest('ajax.cgi','do=get_client_oper_info_ajax&ct_date_to='+to+'&ct_date_from='+from+'&ct_aid='+ct_aid,'POST',proccess_client_info);
    


}
function loadXMLString(txt) 
{
        try //Internet Explorer
        {
                xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
                xmlDoc.async="false";
                xmlDoc.loadXML(txt);
                return(xmlDoc); 
        }
        catch(e)
        {
        try //Firefox, Mozilla, Opera, etc.
            {
                    parser=new DOMParser();
                    xmlDoc=parser.parseFromString(txt,"text/xml");
                    return(xmlDoc);
            }
        catch(e) {alert(e.message)}
        }
        return(null);
}
function proccess_client_info()
{
        var ready=REQ.readyState;
        if(ready==READY_STATE_COMPLETE)
        {
            var info=REQ.responseText;
//          alert(info);
            xmlDoc=loadXMLString(info);
        if(xmlDoc.getElementsByTagName("cash_in_uah")[0])
            document.getElementById('cash_in_uah').innerHTML=xmlDoc.getElementsByTagName("cash_in_uah")[0].childNodes[0].nodeValue;
        else
            document.getElementById('cash_in_uah').innerHTML='0';
        if(xmlDoc.getElementsByTagName("cash_out_uah")[0])
            document.getElementById('cash_out_uah').innerHTML=xmlDoc.getElementsByTagName("cash_out_uah")[0].childNodes[0].nodeValue;
        else
            document.getElementById('cash_out_uah').innerHTML='0';
        if(xmlDoc.getElementsByTagName("cash_in_usd")[0])
            document.getElementById('cash_in_usd').innerHTML=xmlDoc.getElementsByTagName("cash_in_usd")[0].childNodes[0].nodeValue;
        else
            document.getElementById('cash_in_usd').innerHTML='0';
        if(xmlDoc.getElementsByTagName("cash_out_usd")[0])
            document.getElementById('cash_out_usd').innerHTML=xmlDoc.getElementsByTagName("cash_out_usd")[0].childNodes[0].nodeValue;
        else
            document.getElementById('cash_out_usd').innerHTML='0';
        if(xmlDoc.getElementsByTagName("cash_in_eur")[0])
            document.getElementById('cash_in_eur').innerHTML=xmlDoc.getElementsByTagName("cash_in_eur")[0].childNodes[0].nodeValue;
        else
            document.getElementById('cash_in_eur').innerHTML='0';
        if(xmlDoc.getElementsByTagName("cash_out_eur")[0])
            document.getElementById('cash_out_eur').innerHTML=xmlDoc.getElementsByTagName("cash_out_eur")[0].childNodes[0].nodeValue;
        else
            document.getElementById('cash_out_eur').innerHTML='0';


        if(xmlDoc.getElementsByTagName("bn_in_uah")[0])
            document.getElementById('bn_in_uah').innerHTML=xmlDoc.getElementsByTagName("bn_in_uah")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_in_uah').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_out_uah")[0])
            document.getElementById('bn_out_uah').innerHTML=xmlDoc.getElementsByTagName("bn_out_uah")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_out_uah').innerHTML='0';
        
        if(xmlDoc.getElementsByTagName("bn_in_usd")[0])
            document.getElementById('bn_in_usd').innerHTML=xmlDoc.getElementsByTagName("bn_in_usd")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_in_usd').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_out_usd")[0])
            document.getElementById('bn_out_usd').innerHTML=xmlDoc.getElementsByTagName("bn_out_usd")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_out_usd').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_in_eur")[0])
            document.getElementById('bn_in_eur').innerHTML=xmlDoc.getElementsByTagName("bn_in_eur")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_in_eur').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_out_eur")[0])
            document.getElementById('bn_out_eur').innerHTML=xmlDoc.getElementsByTagName("bn_out_eur")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_out_eur').innerHTML='0';
        
        if(xmlDoc.getElementsByTagName("bn_in_uah_com")[0])
            document.getElementById('bn_in_uah_com').innerHTML=xmlDoc.getElementsByTagName("bn_in_uah_com")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_in_uah_com').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_out_uah_com")[0])
            document.getElementById('bn_out_uah_com').innerHTML=xmlDoc.getElementsByTagName("bn_out_uah_com")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_out_uah_com').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_in_usd_com")[0])
            document.getElementById('bn_in_usd_com').innerHTML=xmlDoc.getElementsByTagName("bn_in_usd_com")[0].childNodes[0].nodeValue;
            else
            document.getElementById('bn_in_usd_com').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_out_usd_com")[0])
            document.getElementById('bn_out_usd_com').innerHTML=xmlDoc.getElementsByTagName("bn_out_usd_com")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_out_usd_com').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_in_eur_com")[0])
            document.getElementById('bn_in_eur_com').innerHTML=xmlDoc.getElementsByTagName("bn_in_eur_com")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_in_eur_com').innerHTML='0';
        if(xmlDoc.getElementsByTagName("bn_out_eur_com")[0])
            document.getElementById('bn_out_eur_com').innerHTML=xmlDoc.getElementsByTagName("bn_out_eur_com")[0].childNodes[0].nodeValue;
        else
            document.getElementById('bn_out_eur_com').innerHTML='0';
        
            
        }       

    }



function show_verified(object)
{
    var my_table=document.getElementById('my_table');
    var rows=my_table.rows;


    if(object&&object.name=='1')
    {
        /*if(hidden_arries.length>0)
        {*/
            for(var i=0;i<hidden_arries.length;i++)
            {
                    rows[ hidden_arries[i] ].style.display='';
            }

        
        /*}else
        {
            
        }*/     
        object.name=0;
        object.value="Скрыть сверенные";
    
    }else
    {
        object.name=1;
        object.value="Отобразить сверенные";
        for(var i=0;i<hidden_arries.length;i++)
        {
                    rows[ hidden_arries[i] ].style.display='none';
        }


    }





}