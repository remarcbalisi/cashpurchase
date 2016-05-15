var orno = 0;
var customer = 0;

$(document).ready(function(){

	getProducts();
	showHome();
	getCustomers();
	getStaffs();

});

function hideAll(){

	$('#staff-list').hide();
	$('#home').hide();
	$('#add-products').hide();

}

function showStaff(){

	hideAll();
	$('#staff-list').show();

}

function showHome(){

	hideAll();
	getProducts();
	$('#home').show();

}

function getProducts(){

	$.ajax({
		type:"GET",
		url:"http://localhost:8000/products",
		contentType:"application/json; charset=utf-8",
		dataType:"json",

		success: function(results){

			$('#product-table').html(function(){

				var product_row = '';
				var product = '';

				for (var i = 0; i < results.lists.length; i++) {

					product = '<tr>'+
					 			'<td>'+ results.lists[i].id +'</td>'+
								'<td>'+ results.lists[i].description +'</td>'+
								'<td>'+ results.lists[i].price +'</td>'+
								'<td>'+ results.lists[i].discount +'%</td>'+
					 		  '</tr>';

					product_row = product_row+=product;

				}

				return product_row;

			});
		}
	});

}

function getCustomers(){

	$.ajax({
		type:"GET",
		url:"http://localhost:8000/customers",
		contentType:"application/json; charset=utf-8",
		dataType:"json",

		success: function(results){

			for(var r=0; r<results.count; r++){
				$('#customer_id').append('<option value = "' + results.lists[r].id + '" >' + results.lists[r].name + '</option>');
			}
		}
	});

}

function getStaffs(){

	$.ajax({
		type:"GET",
		url:"http://localhost:8000/staffs",
		contentType:"application/json; charset=utf-8",
		dataType:"json",

		success: function(results){

			for(var r=0; r<results.count; r++){
				$('#staff_id').append('<option value = "' + results.lists[r].id + '" >' + results.lists[r].name + '</option>');
			}
		}
	});

}

function addTransaction(){

	var customer_id = $('#customer_id').val();
	var staff_id = $('#staff_id').val();

	$.ajax({

		type:"POST",
		url:"http://localhost:8000/transaction/"+customer_id+"/"+staff_id,
		contentType:"application/json; charset=utf-8",
		dataType:"json",

		success: function(results){

			$("#transaction-success").append('<div class = "alert alert-success"><a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a><strong>Success!</strong> Transaction successfully added! Congrats!</div>');
			$("#transaction-form").hide();

			orno = results.orno
			getTransaction(results.orno);

			$('#item-purchased').show();

		}

	});

}

function getTransaction(orno){

	$("#item-purchased").show();

	$.ajax({

		type:"GET",
		url:"/transaction/" + orno,
		dataType:"json",

		success: function(results){
			$("#transaction-info").html('');

			$("#transaction-info").append("<p>Date: " + results.lists[0].date + "</p>" +
										  "<p>Amount Due: Php " + results.lists[0].amountdue + "</p>" +
										  "<p>Amount Paid: Php " + results.lists[0].amountpaid + "</p>" +
										  "<p>Discount: " + results.lists[0].discount + " %</p>");

			get_products();

			console.log('transaction-info');
			customer = results.lists[0].custno

		},

		error: function(error){
			console.log(error);
		},

	});

}

function purchase(){

	var product_id = $("#product-id").val();
	var quantity = $("#quantity").val();

	$.ajax({

		type:"POST",
		url:"/purchase/" + orno + "/" + product_id + "/" + customer + "/" + quantity,
		dataType:"json",

		success: function(results){
			if (results.status == "out of stock"){
				$("#purchase-success").html('');
				$("#purchase-success").append('<div class = "alert alert-danger"><a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a><strong>Warning!</strong> out of stock!</div>');
			}

			else{
				$("#purchase-success").html('');
				$("#purchase-success").append('<div class = "alert alert-success"><a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a><strong>Success!</strong> purchase successful!</div>');
			}

			console.log('purchase');
			getTransaction(orno);
		},

		error: function(error){
			console.log(error)
		},

	});

}

function get_products(){

	$.ajax({

		type:"GET",
		url:"/products",
		dataType:"json",

		success: function(results){
			$('#product-id').html('');
			for(var r=0; r<results.count; r++){
				$('#product-id').append('<option value = "' + results.lists[r].id + '" >' + results.lists[r].description + " (Php " + results.lists[r].price + ".00 )" + '</option>');
			}
		},

		error: function(results){
			console.log(results);
		},

	});

}

function add_products(){

	hideAll();
	$('#add-products').show();

	var description = $('#description').val();
	var price = $('#price').val();
	var qty_onhand = $('#qtyonhand').val();
	var stocklimit = $('#stocklimit').val();
	var sale_dis = $('#sale_dis').val();

	var data = JSON.stringify({'description':description, 'price':price, 'qtyonhand':qty_onhand, 'stocklimit':stocklimit, 'sale_dis':sale_dis});

	$.ajax({

		type:"POST",
		url:"http://localhost:8000/products",
		contentType: "application/json; charset=utf-8",
		data:data,
		dataType:"json",

		success: function(results){
			$("#add-products-success").html('');
			$("#add-products-success").append('<div class = "alert alert-success"><a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a><strong>Success!</strong>successfully add product!</div>');
		},

	});

}
