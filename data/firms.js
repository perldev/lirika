///version for common identification 



function open_doc_form_many(ev){
    xy=getScrollXY();
    $('#doc_form').css({'top':ev.clientY+xy[1],'right':window.innerWidth-500});
    if($('#doc_form').css('display')=='none'){   
        document.getElementById('doc_form').style.display='';
       // $('#next_field').css('display','none');
        $('#list_field').css('display','none');
    }else
        return

    var today=new Date();
    month=today.getMonth();
    month-=1;
    year=today.getFullYear();

    if(month<0){
        month=11;
        year-=1;
    }

    $('#month').attr('value',1+1*month);
    $('#year').attr('value',year);

    document.getElementById('next_field_many').style.display='';

}
function search_doc_firms_4many(ev){
    var ct_fid=$('#ct_fid').attr('value');
    var month=$('#month').attr('value');
    xy=getScrollXY();
    var year=$('#year').attr('value');
    var aa=$("input.simple_borders:checkbox");
    var size=aa.length;
    if(size==0){
    
        alert('Вы не выбрали ни одного элемента');
        return ;    
    }
 
    var rowid='0';
    for(var i=0;i<size;i++){
        if(aa[i].checked){
        rowid+=','+aa[i].value
        }

    }
    $.ajax({
        'url' : "/cgi-bin/ajax.cgi",
        'type' : 'POST', 
        'data' : 'do=get_doc_firms_4many&f_id='+ct_fid+'&month='+month+'&year='+year+'&rowid='+rowid,
        'success' : function(data,sts){
                     $('#list_field').html(data);
                     $('#list_field').css({'right':ev.clientX-200});
                     $('#list_field').show('slow');

                }
          });


}
function many_update_money_doc_in_list(dr_id){

    var aa=$("input.simple_borders:checkbox");
    var size=aa.length;
    if(size==0){
    
        alert('Вы не выбрали ни одного элемента');
        return ;    
    }
    arr_of_ctids=new Array();
    var rowid='0';
    for(var i=0;i<size;i++){
        if(aa[i].checked){
            rowid+=','+aa[i].value;
            arr_of_ctids.push(aa[i].value);
        }

    }
    $.ajax({
        'url' : "/cgi-bin/ajax.cgi",
        'type' : 'POST', 
        'data' : 'do=update_ctid_drid_many&dr_id='+dr_id+'&rowid='+rowid,
        'success' : function(data,sts){
                     $("input.simple_borders:checkbox").attr('checked',false);
                     info=$('#doc_'+dr_id).attr('value');
                     for(var i=0;i<size;i++){
                             $('#ident_form_'+arr_of_ctids[i]).html(info);
                     }
                     hide_doc_form();

                }
          });


}


function hide_doc_form(){

    $("#list_field").hide('fast');
 //   $("#next_field").hide('fast');
    $("#doc_form").hide('fast');
  //  $("#next_field_many").hide('fast');

}


function search_doc_firms_all(ev){


        var number=$('#ofid_number').attr('value');
        var ofid=$('#'+number).attr('value');
        
        var ct_fid=$('#ct_fid').attr('value');
        var month=$('#month').attr('value');
        xy=getScrollXY();
        var year=$('#year').attr('value');
        rowid=document.getElementById('rowid').value;
	if(document.getElementById('firm_add_input'))
	    rowid='';
        $.ajax({
        'url' : "/cgi-bin/ajax.cgi",
        'type' : 'POST', 
        'data' : 'do=get_docs_for_firm_all&of_id='+ofid+'&f_id='+ct_fid+'&month='+month+'&year='+year+'&rowid='+rowid,
        'success' : function(data,sts){
                     $('#list_field').html(data);
                    
                     $('#list_field').css({/*'top':ev.clientY*1+1*xy[1],*/'right':window.innerWidth-ev.clientX});
                     $('#list_field').show('slow');

                }
          });
}


//in list number_of_fid will be the represantation of ct_id field in database

function open_doc_form(ev,number_of_fid,fid){
    xy=getScrollXY();
    $('#doc_form').css({'top':ev.clientY+xy[1],'right':0})

    if($('#doc_form').css('display')=='none')
               document.getElementById('doc_form').style.display='';

   crnt=$('#rowid').attr('value');

   //if it was a double click
   if(number_of_fid == crnt) 
        return

//hide searching
  // $('#next_field').css('display','none');
   $('#list_field').css('display','none');
  // $('#next_field_many').css('display','none');
/*   $('#ct_fid').attr('value',fid);//it's not mistake - for working in the list*/
   $('#ofid_number').attr('value','ct_ofid'+number_of_fid);
   $('#drid_number').attr('value','ct_drid'+number_of_fid);
   $('#ident_form').attr('value','ident_form_'+number_of_fid);
   $('#rowid').attr('value',number_of_fid);


    var today=new Date();
    
    month=today.getMonth();
    month-=1;
    year=today.getFullYear();
    if(month<0){
        month=11;
        year-=1;

    }
    
    $('#month').attr('value',1+1*month);
    $('#year').attr('value',year);
    document.getElementById('next_field').style.display='';

}

function search_doc_firms(ev){
        var ct_fid=$('#ct_fid').attr('value');
        var number=$('#ofid_number').attr('value');
        var ofid=document.getElementById(number).value;
        if(!ofid){
            alert('Выберите фирму покупателя')
            return 
        }
        
        var ct_fid=$('#ct_fid').attr('value');
        var month=$('#month').attr('value');
        xy=getScrollXY();
        var year=$('#year').attr('value');
        var  rowid=document.getElementById('rowid').value;
	if(document.getElementById('firm_add_input'))
	    rowid='';
        $.ajax({
        'url' : "/cgi-bin/ajax.cgi",
        'type' : 'POST', 
        'data' : 'do=get_docs_for_firm&of_id='+ofid+'&f_id='+ct_fid+'&month='+month+'&year='+year +'&rowid='+rowid,
        'success' : function(data,sts){
                     $('#list_field').html(data);
                     $('#list_field').css({/*'top':ev.clientY*1+1*xy[1],*/'right':window.innerWidth-ev.clientX})
                     $('#list_field').show('slow');

                }
          });
}
function update_money_doc_in_list(dr_id){
    
        number=$('#ident_form').attr('value');
        $("#"+number).html( $('#doc_'+dr_id).attr('value') );
        number=$('#rowid').attr('value');
        

        $.ajax({
        'url' : "/cgi-bin/ajax.cgi",
        'type' : 'POST', 
        'data' : 'do=update_ctid_drid&ct_id='+number+'&dr_id='+dr_id,
        'success' : function(data,sts){
                    
                    show_form("list_field");
                   // show_form("next_field");
                    show_form("doc_form");

                }
          });
          

}

function update_money_doc(dr_id){
          var number=$('#drid_number').attr('value');
          $("#"+number).attr('value',dr_id);
          number=$('#ident_form').attr('value');
          $("#"+number).html( $('#doc_'+dr_id).attr('value') );
          show_form("list_field");
       //   show_form("next_field");
          show_form("doc_form");

}

function open_firms_form(ev,id_select){
    $('#firm_div').css({'top':ev.clientY,'left':0})
	//document.getElementById('id_select').value =id_select; 
    if($('#firm_div').css('display')=='none')
               document.getElementById('firm_div').style.display='';
}


function add_firm(){
    var name=document.getElementById('name').value;
    var okpo=document.getElementById('okpo').value;

    $.ajax({
        'url' : "/cgi-bin/ajax.cgi",
        'type' : 'POST', 
        'data' : 'do=add_firm&name='+name+'&okpo='+okpo,
        'success' : function (dat){
		    var patt=new RegExp('[ok]');
				
		    if(! patt.test(dat) ){
		        $('#error').html(dat);
		    }else{
		    	var new_firm=dat.replace('[ok]','');
		        var arr =new_firm.split(/,,,/); 

				hash_okpo[arr[1]]=arr[0];
				hash_idokpo[arr[0]]=arr[1];
				hash_id[arr[0]] = arr[2]+" (id#"+arr[0]+")";
				for(i=1;i<=39;i++)
				{
					select_on_okpo(document.getElementById('okpo_'+i),"ct_ofid"+i,"ct_aid"+i);
					if(document.getElementById('ct_ofid'+i).options.length==1)
						search_in_select_field(document.getElementById('search_'+i),"ct_ofid"+i,i,"ct_aid"+i);
				}
				//var sel = document.getElementById('ct_ofid'+document.getElementById('id_select').value);
				//sel[sel.options.length] = new Option(arr[2]+" (id#"+arr[0]+")",arr[0], false, true);
				//var name = document.getElementById('search_'+document.getElementById('id_select').value);
				//var okpo = document.getElementById('okpo_'+document.getElementById('id_select').value);
				//name.value = arr[2];
				//okpo.value = arr[1];
				show_form('firm_div');	
		    }
		    }
		  });
}