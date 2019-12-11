public without sharing class QueueDA {
	public static List<Group> getDefaultRoutingGroup(){
		return new List<Group>([SELECT Id
				FROM Group
				WHERE Name = :System.Label.Routing_Default_Queue_Name
				AND Type = :System.Label.ROUTING_DEFAULT_TYPE
                LIMIT 1]);
	}
	public static List<Group> getQueuesBasedOnNames(list<String> queueNames){
		return new List<Group>([SELECT Name
				FROM Group
				WHERE Name IN :queueNames
				AND Type = :System.Label.ROUTING_DEFAULT_TYPE]);
	}
}