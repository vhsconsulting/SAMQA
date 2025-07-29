create index samqa.notification_schedule_n1 on
    samqa.notification_schedule (
        notif_template_id
    );


-- sqlcl_snapshot {"hash":"65073671ad910ce5ac3e7721733e13a13f0f51f4","type":"INDEX","name":"NOTIFICATION_SCHEDULE_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>NOTIFICATION_SCHEDULE_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NOTIFICATION_SCHEDULE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>NOTIF_TEMPLATE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}