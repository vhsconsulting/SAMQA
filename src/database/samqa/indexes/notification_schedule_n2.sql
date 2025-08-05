create index samqa.notification_schedule_n2 on
    samqa.notification_schedule (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"d767969eafea705a487033dc047d28bd62e14469","type":"INDEX","name":"NOTIFICATION_SCHEDULE_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>NOTIFICATION_SCHEDULE_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NOTIFICATION_SCHEDULE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}