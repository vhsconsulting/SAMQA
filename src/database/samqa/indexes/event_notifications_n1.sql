create index samqa.event_notifications_n1 on
    samqa.event_notifications (
        event_type,
        template_name
    );


-- sqlcl_snapshot {"hash":"27f44202d5b4c5a63cf217c6c7c7d66395791d70","type":"INDEX","name":"EVENT_NOTIFICATIONS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EVENT_NOTIFICATIONS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EVENT_NOTIFICATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EVENT_TYPE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TEMPLATE_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}