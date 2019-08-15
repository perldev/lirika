//there we open new div and iframe on it after working we must create a new menu 
// or show the mistake after sending request
function parent_my_submit_form()
{

	var a_name=document.getElementById('a_name').value;
	var a_id=document.getElementById('a_id').value;
	parent.document.getElementById('buffer_a_name').value=a_name;
	parent.document.getElementById('buffer_a_id').value=a_id;

	
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
function my_submit_form(id,ident_form)
{
	var obj=document.getElementById(ident_form);
	obj.style.display='none';

	var parent_obj=document.getElementById('form_'+id);
	
	document.getElementById('cel_'+id).className='table_gborders_whiteskin';
	
	

	$('#form_'+id).hide('slow');
	var tr=document.getElementById('row_'+id);
	create_account_title(tr);
	day_create_ident_menu(id);
}
	
function create_account_title(tr)
{
	var account;
	var a_name=document.getElementById('buffer_a_name').value;		
	var a_id=document.getElementById('buffer_a_id').value;

	if(a_id)
		account=a_name+'(#'+a_id+') ';
	else
		account='';

	tr.cells[0].innerHTML=account;
	document.getElementById('buffer_a_name').value='';
	document.getElementById('buffer_a_id').value='';

}
function clear_account_title(tr)
{
		tr.cells[0].innerHTML='';
}
function addListener(element, _type, expression, bubbling)
{

bubbling = bubbling || false;

 

	if(window.addEventListener) { // Standard


	element.addEventListener(_type, expression, bubbling);
	
	return true;
	
	} else if(window.attachEvent) { // IE

	
	element.attachEvent('on' + _type, expression);


	return true;
	
	} else return false;

}
function my_submit_object(_id,_ident_form)
{
	var id=_id;
	var ident_form=_ident_form;
	
	this.listener=function(){
		
		my_submit_form(id,ident_form);
	}
}
function class_for_ajax_ident_req(_ct_id,_id)
{
	var ct_id=_ct_id;
	var id=_id;
	this.listener=function(){
		ajax_ident_req(ct_id,id);
		
	}
	


}


function ajax_ident_req(ct_id,id){
 	//var par=obj.parentNode;
	
	    $('#ident_form_frame').attr({src : ct_id });
        //$(this).css({'background-color' : 'yellow', 'font-weight' : 'bolder'});
	    var scroolxy=getScrollXY();
	    $('#ident_form').css({'left':scroolxy[0]+'px','top':scroolxy[1]+'px'});
	    $('#ident_form').hide('slow').show('slow');
	    var object_=new my_submit_object(id,'ident_form');
	    var ret =document.getElementById('return_function');
	    addListener(ret,'click',object_.listener,false);
	    return;

/*
	$('#ident_form_frame').attr({src : ct_id });

	$('#ident_form').hide('slow').show('slow');

	var object_=new my_submit_object(id,'ident_form');

	var ret =document.getElementById('return_function');

	addListener(ret,'click',object_.listener,false);
	
	return;
*/

}
function my_back()
{
		var par_form;
		if(document.getElementById('__confirm'))
			history.go(-1)
		else if(par_form=document.getElementById('parent_id').value)
		{
			var obj=parent.document.getElementById(par_form);
			obj.style.display='none';
		}

}
//it must be changed

function clear_tag(id)
{
	
	var s=document.getElementById(id);
	s.innerHTML='';
	return s;
	var array=s.childNodes;
	var size=s.length;

	for(var i=0;i<size;i++)
	{
		s.removeChild(array[i]);
		
	}
	return s;



}
function create_my_element(_ob,_class,_title,_action)
{
	var tab = document.createElement('span');
	tab.setAttribute('class',_class);
	tab.innerHTML=_title;
	tab.onclick = _action;
 	_ob.appendChild(tab);
	
	
}
function ajax_action_req_back_day(obj,id)
{

	var c = new back_cells_day(obj,id);
	SendRequest('ajax.cgi','do=back_firm_req&id='+id,'POST',c.listener);


}
function back_cells_day(obj,_id)
{

	var id = _id;
	var parent_obj=obj;

  	this.listener=function(){

    		var ready=REQ.readyState;
		var data=null;
		if(ready==READY_STATE_COMPLETE)
		{
				//first firm_id,second new id
			var str=REQ.responseText;
			var id_=str.split(",");
			var new_menu=create_menu_non_ident(parent_obj,id_[1],id);
			//alert(id_);
			

		}		

  	}

}
function class_ajax_back_req(_obj,_id)
{
	var id = _id;
	var obj=_obj;
  	this.listener=function(){

    		ajax_action_req_back_day(obj,id);

  	}
}

function day_create_ident_menu(id)
{

	var _left=clear_tag('id_left_'+id);
	var _center=clear_tag('id_center_'+id);
	var _right=clear_tag('id_right_'+id);
	
	var back_action=new class_ajax_back_req('form_'+id,id);
	create_my_element(_center,'simple_tab','Откатить',back_action.listener);

}
///
function class_for_show_form(_base,_id)
{	
	var base=_base;
	var id=_id;

	this.listener=function(){
		
		show_form(base+id);
	}
	


}
function show_form(id)
{
	var obj=document.getElementById(id);
	if(!obj)
		return;

	if(obj.style.display=='none')
	{
		obj.style.display='';
	}else	
	{
		obj.style.display='none';
	}
}
function get_first_number(obj)
{
	var string;
	var num;
	for(var i=0;i<obj.cells.length;i++)
	{
		string=obj.cells[i].innerHTML;
		
		string=string.replace(/[ ]/,"");
		var num=string*1;
		if((num>0||num<0)&&num)
			return num 

	}
	

}


function create_menu_non_ident(ob,id_,old_id)
{
	var id = id_;
	var obj=ob;
		

	var obj=document.getElementById(ob);
	obj.parentNode.className='table_gborders';
	
	var tr;
	tr=document.getElementById('row_'+old_id);
 	clear_account_title(tr);
	tr.id='row_'+id;
	var tmp_number=get_first_number(tr);

	var td=document.getElementById('cel_'+old_id);
	td.id='cel_'+id;

	var new_form_listener=new class_for_show_form('form_',id);
	addListener(obj.parentNode,'click',new_form_listener.listener,false)
	obj.style.display='none';
	obj.id='form_'+id;
	var _left=clear_tag('id_left_'+old_id);
	var _center=clear_tag('id_center_'+old_id);
	var _right=clear_tag('id_right_'+old_id);

	_left.id='id_le ft_'+id;
	_center.id='id_center_'+id;
	_right.id='id_right_'+id;

	
		
	var iden_action;
	if(tmp_number<0)
	{	
		iden_action=new class_for_ajax_ident_req('/cgi-bin/lite/firm_output.cgi?do=edit&parent_id=ident_form&id='+id,id);
	}else
	{
		iden_action=new class_for_ajax_ident_req('/cgi-bin/lite/firm_input2.cgi?do=edit&parent_id=ident_form&id='+id,id);

	}

	create_my_element(_right,'simple_tab','идентифицировать',iden_action.listener);

	var confirm_action=new class_for_ajax_action_req_confirm(id);
	
	create_my_element(_center,'simple_tab','Отложить',confirm_action.listener);
	
	var trans_action=new class_for_ajax_action_req_next_day(id);

	create_my_element(_left,'simple_tab','Перенести',trans_action.listener);

	

	

}




function ajax_action_req_delete_object(id1,id)
{

	var id1 = id1;
	var id2 = id;
  	this.listener=function(){
		
		ajax_action_req_delete(id1,id2);

  	}

}

///finishong day JavaScript

