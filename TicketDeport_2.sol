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
   
   
   function get_address(uint16 _id, uint16 _ticketId) returns (address) {
       return events[_id].attendees[_ticketId];
   }
   
   function balance_contract () returns (uint) {
       return wallet_contract.balance;
   }
 
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


   // ***** Вторая часть задания *****
      struct Offering{
        address buyer;
        uint64 price;
        uint256 deadline;
    }
    mapping(bytes32 => Offering) offerings;   
    
    modifier onlyOwner(address owner) {
        require(msg.sender == owner);
        _;
    }
    
    
    function get_offering(uint16 _eventID, uint16 _ticketID) returns (address) {
        bytes32 offerID = sha3(_eventID + _ticketID);
        return offerings[offerID].buyer;
    }


   function offerTicket(uint16 _eventID, uint16 _ticketID, uint64 _price, address _buyer, uint16 _offerWindow) public onlyOwner(events[_eventID].attendees[_ticketID]){
       // Позволяет владельцу билета выставить свой билет 
       //на продажу по цене _price в течение _offerWindow блоков
       
       bytes32 offerID = sha3(_eventID + _ticketID); // Подсказка: рекомендую использовать вот такой offerID
       offerings[offerID] = Offering(_buyer, _price, block.number + _offerWindow);
       
   }

   function buyOfferedTicket(uint16 _eventID, uint16 _ticketID, address _newAttendee) payable {
       // Позволяет купить билет, если продажа еще не закончилась 
       // и переведенная сумма достаточная.
       // Обновляет значение attendee, указывая нового вместо старого, 
       // а также сразу переводит деньги продавцу
       bytes32 offerID = sha3(_eventID + _ticketID);
       require(block.number <= offerings[offerID].deadline);
       require(msg.value >= (offerings[offerID].price + transactionFee));
       events[_eventID].owner.transfer(offerings[offerID].price);
       wallet_contract.transfer(transactionFee);
       events[_eventID].attendees[_ticketID] = _newAttendee;
       
   } 
 
}
