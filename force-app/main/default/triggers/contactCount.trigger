 trigger contactCount on Contact (after insert,after update,after delete,after undelete) {
    set<id>accids = new set<id>();
    if(trigger.isafter && (trigger.isInsert || trigger.isundelete)){
        if(!trigger.new.isEmpty()){
            for(contact con : trigger.new ){
                if(con.accountId != null){
                    accids.add(con.accountId);
                }
            } 
        }
    }
        if(trigger.isafter && trigger.isupdate ){
            for(contact c : trigger.new){
                contact oldcon = trigger.oldmap.get(c.id);
                if(oldcon.accountID != c.accountId && oldcon.accountId != null){
                    accids.add(oldcon.accountId);
                    accids.add(c.accountId);
                }
                else{
                    accids.add(c.accountId); // collected account ids.
                }
            }
        }
        if(trigger.isafter && trigger.isdelete){
            for(contact oc : trigger.old){
                if(oc.accountId != null)
                accids.add(oc.accountId);
            }
        }
        map<id,account>accmap = new map<id,account>();
        if(!accids.isEmpty()){
           list<AggregateResult>agr = [ select AccountId ids,count(id) cn from contact  where accountid in : accids group by AccountId];
            for(AggregateResult ag : agr){
                Account acc = new account();
                acc.id = (ID) ag.get('ids');
                acc.Total_number_of_contacts__C = (integer) ag.get('cn');
                accmap.put(acc.id,acc);
            }
            if(!accmap.isEmpty()){
                update accmap.values();
                
            }
        }

    }