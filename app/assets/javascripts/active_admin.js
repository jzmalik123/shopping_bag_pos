//= require active_admin/base
//= require active_admin/searchable_select

if(window.location.href.search('admin/orders') != -1){
  function toNumber(value) {
    const number = Number(value)
    return Number.isFinite(number) ? number : 0
  }

  function calculateAmount(field) {
    const arr = $(field).attr('id').split('_')
    const index = arr[arr.length - 2]
  
    const rate = toNumber($(`#order_order_items_attributes_${index}_rate`).val())
    const weight = toNumber($(`#order_order_items_attributes_${index}_weight`).val())
    const quantity = toNumber($(`#order_order_items_attributes_${index}_quantity`).val())
  
    const amount_field = $(`#order_order_items_attributes_${index}_amount`)
    if(rate !== 0 && weight !== 0 && quantity !== 0){
      amount_field.val(rate * quantity * weight)
      updateOrderFields()
    }
  }
  
  function updateOrderFields(){
    const order_items_count = $('.has_many_fields').length
    let order_total_amount = 0
    let order_total_weight = 0
    let order_total_quantity = 0
    for(let index = 0; index < order_items_count; index++){
      const quantity = toNumber($(`#order_order_items_attributes_${index}_quantity`).val())
      const weight = toNumber($(`#order_order_items_attributes_${index}_weight`).val())
      const amount = toNumber($(`#order_order_items_attributes_${index}_amount`).val())

      order_total_quantity += quantity
      order_total_weight += (weight * quantity)
      order_total_amount += amount
    }
    $('#order_total_quantity').val(order_total_quantity)
    $('#order_total_amount').val(order_total_amount)
    $('#order_total_weight').val(order_total_weight)
    $('#order_received_amount').val('')
    $('#order_remaining_balance').val('')
  }
  
  function updateRemainingBalance(field){
    const order_total_amount = toNumber($('#order_total_amount').val())
    const previous_balance = toNumber($('#order_previous_balance').val())
    const order_received_amount = toNumber($('#order_received_amount').val())
    $('#order_remaining_balance').val(order_total_amount + previous_balance - order_received_amount)
  }
  
  $(document).ready(function() {
    // Prevent accidental +/-1 changes from mouse wheel on focused number inputs.
    $(document).on('wheel', 'input[type=number]', function(e) {
      e.preventDefault()
      $(this).blur()
    })

    function getConfigurationValue(configuration_key){
      $.ajax({
        url: `/admin/configurations/get_value/default_sale_rate_${configuration_key}`,
        method: 'GET',
        dataType: 'json',
        success: function(response) {
          $('#order_previous_balance').val(response['balance'])
        }
      });
    }

    if(!window.location.href.search('edit')){
      getCustomerPreviousBalance()
    } else {
      selected_bag = $('#order_bag_category_id').find('option:selected').html()
      selected_bag = selected_bag.replaceAll(' ','_').toLowerCase()
      getConfigurationValue(selected_bag)
    }

    $('#order_customer_id').on("change", function(){
      if($(this).val() == 1){
        $('#order_customer_name_input').show()
      }else{
        $('#order_customer_name_input').hide()
      }
      getCustomerPreviousBalance()
    })
  
    $('#payment_source_id').on("change", function(){
      balance = $(this).find('option:selected').data("balance")
      $('#payment_previous_balance').val(balance)
      $('#payment_source_type').val($(this).find('option:selected').data("source-type"))
    })
  
    function getCustomerPreviousBalance(){
      $.ajax({
        url: `/admin/customers/${$('#order_customer_id').val()}/previous_balance`,
        method: 'GET',
        dataType: 'json',
        success: function(response) {
          $('#order_previous_balance').val(response['balance'])
        }
      });
    }
  })
} else if(window.location.href.search('vendor_orders') != -1){
  function toNumber(value) {
    const number = Number(value)
    return Number.isFinite(number) ? number : 0
  }

  function calculateAmount(field) {
    const arr = $(field).attr('id').split('_')
    const index = arr[arr.length - 2]
  
    const rate = toNumber($(`#vendor_order_vendor_order_items_attributes_${index}_rate`).val())
    const quantity = toNumber($(`#vendor_order_vendor_order_items_attributes_${index}_quantity`).val())
  
    const amount_field = $(`#vendor_order_vendor_order_items_attributes_${index}_amount`)
    if(rate !== 0 && quantity !== 0){
      amount_field.val(rate * quantity)
      updateOrderFields()
    }
  }
  
  function updateOrderFields(){
    const order_items_count = $('.has_many_fields').length
    let order_total_amount = 0
    let order_total_weight = 0
    for(let index = 0; index < order_items_count; index++){
      order_total_amount += toNumber($(`#vendor_order_vendor_order_items_attributes_${index}_amount`).val())
    }
    $('#vendor_order_total_amount').val(order_total_amount)
    $('#vendor_order_total_weight').val(order_total_weight)
    $('#vendor_order_received_amount').val('')
    $('#vendor_order_remaining_balance').val('')
  }
  
  function updateRemainingBalance(field){
    const order_total_amount = toNumber($('#vendor_order_total_amount').val())
    const previous_balance = toNumber($('#vendor_order_previous_balance').val())
    const order_received_amount = toNumber($('#vendor_order_received_amount').val())
    $('#vendor_order_remaining_balance').val(order_total_amount + previous_balance - order_received_amount)
  }
  
  $(document).ready(function() {
    // Prevent accidental +/-1 changes from mouse wheel on focused number inputs.
    $(document).on('wheel', 'input[type=number]', function(e) {
      e.preventDefault()
      $(this).blur()
    })

    getVendorPreviousBalance()
    $('#vendor_order_vendor_id').on("change", function(){
      getVendorPreviousBalance()
    })
  
    function getVendorPreviousBalance(){
      $.ajax({
        url: `/admin/vendors/${$('#vendor_order_vendor_id').val()}/previous_balance`,
        method: 'GET',
        dataType: 'json',
        success: function(response) {
          $('#vendor_order_previous_balance').val(response['balance'])
        }
      });
    }
  })
} else if(window.location.href.search('payments') != -1){
  $(document).ready(function() {

    $('#payment_source_id').on("change", function(){
      balance = $(this).find('option:selected').data("balance")
      $('#payment_previous_balance').val(balance)
      $('#payment_source_type').val($(this).find('option:selected').data("source-type"))
    })
  })
}
