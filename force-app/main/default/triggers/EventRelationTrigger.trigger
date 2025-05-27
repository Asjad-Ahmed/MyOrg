trigger EventRelationTrigger on EventRelationChangeEvent (after insert) {
	system.debug('after insert ran'+ trigger.new);
}