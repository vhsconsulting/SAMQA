create index samqa.notification_schedule_n3 on
    samqa.notification_schedule (
        schedule_name
    );


-- sqlcl_snapshot {"hash":"ea41052d05fd904d34fa8f77ade08a37dd98effd","type":"INDEX","name":"NOTIFICATION_SCHEDULE_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>NOTIFICATION_SCHEDULE_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NOTIFICATION_SCHEDULE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SCHEDULE_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}