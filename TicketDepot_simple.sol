pragma solidity ^0.4.25;

contract TicketDepot {
    
   struct Event{
        address owner;
        uint64 ticketPrice;
        uint16 ticketsRemaining;
        mapping(uint16 => address) attendees;
    }

   
   uint16 numEvents;
   address owner;
   uint64 transactionFee;
   mapping(uint16 => Event) events;
   address wallet_contract;

   function TicketDepot(uint64 _transactionFee) {
       // Конструктор конктракта. Устанавливает transactionFee и owner
       owner = msg.sender;
       transactionFee = _transactionFee;
   }
   
   function createEvent(uint64 _ticketPrice, uint16 _ticketsAvailable) returns (uint16 eventID) {
       // Создает мероприятие с _ticketsAvailable билетами по цене _ticketPrice, 
       // а также устанавливает owner мероприятия
       owner = msg.sender;
       events[numEvents] = Event(owner, _ticketPrice, _ticketsAvailable);
       return numEvents++;
   }
   
   /*function balance_contract () returns (uint) {
       return wallet_contract.balance;
   }*/
 
   function buyNewTicket(uint16 _eventID, address _attendee) payable returns (uint) {
       // Позволяет купить билет: если послано достаточно денег, 
       // чтобы оплатить комиссию владельца контракта + сам билет,
       // то _attendee в attendees соответствующего event. Уменьшает количество доступных билетов.
       // Сразу переводит деньги owner мероприятия.
       
       require (events[_eventID].ticketsRemaining > 0 && msg.value >= (events[_eventID].ticketPrice + transactionFee));
       events[_eventID].owner.transfer(events[_eventID].ticketPrice);
       wallet_contract.send(transactionFee);
       events[_eventID].attendees[events[_eventID].ticketsRemaining] = _attendee;
       return events[_eventID].ticketsRemaining --;
   }
}
