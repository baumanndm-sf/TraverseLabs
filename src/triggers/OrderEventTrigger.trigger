trigger OrderEventTrigger on Order_Event__e (after insert) {
List<Task> tasks = new List<Task>();
    
    // Get queue Id for case owner
    User user = [SELECT Id FROM User Where Id='00561000000ir1D'];
       
    // Iterate through each notification.
    for (Order_Event__e event : Trigger.New) {
        if (event.Has_Shipped__c == true) {
            // Create Case to dispatch new team.
            Task task = new Task();
            task.Priority = 'Medium';
            task.Status = 'New';
            task.Subject = 'Follow up on shipped order ' + event.Order_Number__c;
            task.OwnerId = user.Id;
            tasks.add(task);
        }
   }
    
    // Insert all cases corresponding to events received.
    insert tasks;
}