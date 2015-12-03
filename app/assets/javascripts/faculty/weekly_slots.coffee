slotsClickHandler = ->
  $('.connect-slot').click (event) ->
    slot = $(event.target)

    # Mark (or unmark) selected class.
    slot.toggleClass('selected')
    slotValue = [slot.data('day'),slot.data('time')]

    if $('#list_of_slots').val().length > 0
      current_slots = JSON.parse($('#list_of_slots').val())
    else
      current_slots = []

    if slot.hasClass('selected')
      current_slots.push(slotValue)
    else
      index = findSlot(current_slots, slotValue)

      if index > -1
        current_slots.splice(index, 1);

    $('#list_of_slots').val(JSON.stringify(current_slots))
    console.log $('#list_of_slots').val()

findSlot = (list, slotValue) ->
  i = 0
  while i < list.length
    if String(list[i]) == String(slotValue)
      return i
    i++
  -1

markPresentSlots = ->
  if $('#list_of_slots').val().length > 0
    current_slots = JSON.parse($('#list_of_slots').val())
    console.log current_slots



$(document).on 'page:change', slotsClickHandler
$(document).on 'page:change', findSlot
$(document).on 'page:change', markPresentSlots
