create index samqa.email_notifications_pk on
    samqa.email_notifications (
        notification_id
    );


-- sqlcl_snapshot {"hash":"f60a03e25bbdd1887c871dbcc900f89617c64d80","type":"INDEX","name":"EMAIL_NOTIFICATIONS_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMAIL_NOTIFICATIONS_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMAIL_NOTIFICATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>NOTIFICATION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}